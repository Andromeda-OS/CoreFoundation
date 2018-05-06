/*
 *  CFNotificationCenter.c
 *  CFNotificationCenters
 *
 *  Created by Stuart Crook on 23/02/2009.
 */

#include <CoreFoundation/CFPropertyList.h>
#include <CoreFoundation/CFNumber.h>
#include <CoreFoundation/CFMessagePort.h>
#include <CoreFoundation/CFStream.h>
#include <CoreFoundation/CFString.h>

#include "CFRuntime.h"
#include "CFPriv.h"
#include "CFInternal.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include <notify.h>
#include <CoreFoundation/CFMachPort.h>


typedef CF_ENUM(CFIndex, CFNotificationCenterType) {
    kCFNotificationCenterLocal,
    kCFNotificationCenterDistributed,
    kCFNotificationCenterDarwin,
};

typedef struct __CFObserver {
    struct __CFObserver *next;
    CFIndex retainCount;
	CFHashCode name; // name, hashed for speed. 0 if NULL
	const void *object; // can be NULL
	const void *observer; // may be NULL
	CFNotificationCallback callback; // set to NULL when unlinked
	CFNotificationSuspensionBehavior sb;
} __CFObserver;

struct __CFNotificationCenter {
	CFRuntimeBase _base;
	CFNotificationCenterType type;
	CFIndex suspended; // <- move into base bits?
    CFIndex observersCount;
	__CFObserver *firstObserver;
    CFLock_t lock;
};

#pragma mark - Distributed Notification Center Internal

// STRUCTURES FOR DISTRIBUTED CENTER HERE
// message ids recognised by ddistnoted
// TODO: move these into a shared header we can give to ddistnoted
// TODO: add URL to git repo here
typedef CF_ENUM(SInt32, CFDistributedMessageID) {
    kCFDistributedMessageIDNotification,
    kCFDistributedMessageIDRegisterPort,
    kCFDistributedMessageIDUnregisterPort,
    kCFDistributedMessageIDRegisterNotification,
    kCFDistributedMessageIDUnregisterNotification,
};

#define CF_DIST_SIZE	32
#define CF_QUEUE_SIZE	32

typedef struct __CFDistNotification {
    struct __CFDistNotification *next;
	CFHashCode hash;
	CFHashCode object;
	CFIndex count;
} __CFDistNotification;

typedef struct __CFQueueRecord {
    struct __CFQueueRecord *next;
	CFStringRef name;
	const void *object; // will be a CFStringRef...
	const void *observer;
	CFDictionaryRef userInfo;
	CFNotificationCallback callback;
} __CFQueueRecord;

typedef struct __CFDistributedCenterInfo {
	CFMessagePortRef local;
	CFMessagePortRef remote;
	long session;
	CFHashCode uid;
	CFRunLoopSourceRef rls;
    __CFDistNotification *firstNotification;
    __CFQueueRecord *firstRecord;
} __CFDistributedCenterInfo;

static __CFDistributedCenterInfo __CFDistInfo = { NULL, NULL, 0, 0, NULL, NULL, NULL };

// these structures come from the ddistnoted project -- beter keep their definitions synced
// TODO: add the repo url here as well
typedef struct dndNotReg {
	CFHashCode uid;
	CFHashCode name;
	CFHashCode object;
} dndNotReg;

typedef struct dndNotHeader {
	long session;
	CFHashCode name;
	CFHashCode object;
	CFIndex flags;
} dndNotHeader;

#pragma mark - Darwin Notification Center Internal

/*
 *	Darwin notifications
 *
 *	There are two ways we could organise recieving notify messages via Mach ports. The
 *	method we are using here is to use a single port for all messages, with an int token
 *	in the message header used to identify the notification name.
 *
 *	The alternative, which we may have to consider if the number of notifications in
 *	general use swamps a single port's message queue, is to allocate one Mach port per
 *	notification name.
 */

typedef struct __CFDarwinNotifications {
    struct __CFDarwinNotifications *next;
    CFHashCode hash; // TODO: also store string so we can drop the hash table
    int token;
	CFIndex count;
} __CFDarwinNotifications;

typedef struct __CFDarwinCenterInfo {	
	CFMachPortRef port;
	CFRunLoopSourceRef rls;
    __CFDarwinNotifications *first;
} __CFDarwinCenterInfo;

static __CFDarwinCenterInfo __CFDarwinInfo = { NULL, NULL, NULL };

#pragma mark - Common Internal

static CFMutableDictionaryRef __CFHashStore = NULL;
static CFLock_t __CFHashStoreLock = CFLockInit;

static const CFRuntimeClass __CFNotificationCenterClass = {
	0,
	"CFNotificationCenter",
	NULL,   // init
	NULL,	// copy
	NULL,   // __CFDataDeallocate,
	NULL,   // __CFDataEqual,
	NULL,   // __CFDataHash,
	NULL,	// 
	NULL,   // __CFDataCopyDescription
};

static CFTypeID __kCFNotificationCenterTypeID = _kCFRuntimeNotATypeID;

// This must be called from __CFInitialize in CFRuntime.h before notification centers can be used
__private_extern__ void __CFNotificationCenterInitialize(void) {
	__kCFNotificationCenterTypeID = _CFRuntimeRegisterClass(&__CFNotificationCenterClass);
	__CFHashStore = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, NULL, NULL );
}

CFTypeID CFNotificationCenterGetTypeID(void) {
    return __kCFNotificationCenterTypeID;
}

// shared creation method
CFNotificationCenterRef __CFCreateCenter(CFNotificationCenterType type) {
    
    CFIndex size = sizeof(struct __CFNotificationCenter) - sizeof(CFRuntimeBase);
    struct __CFNotificationCenter *memory = (CFNotificationCenterRef)_CFRuntimeCreateInstance(kCFAllocatorDefault, __kCFNotificationCenterTypeID, size, NULL);
    if (!memory) {
        return NULL;
    }
    
    memory->type = type;
    memory->suspended = false;
    memory->lock = CFLockInit;
    memory->firstObserver = NULL;
    
    return memory;
}

/*
 *    The __CFAdd and __Remove functions take an optional callback of this type which is called once
 *    for each observer added or removed. It runs under the current spinlock and gets over the
 *    problem of returning a list of notification to remove from the RemoveEvery function
 */
typedef void (*__CFAdderCallBack)( CFStringRef name, CFHashCode hash, CFHashCode object );
typedef void (*__CFRemoverCallBack)( CFHashCode name, CFHashCode object );

CFNotificationCenterRef __CFCreateCenter( CFIndex type );

void __CFAddObserver( CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior, __CFAdderCallBack cb );
void __CFRemoveObserver( CFNotificationCenterRef center, const void *observer, CFHashCode name, const void *object, __CFRemoverCallBack cb );
void __CFRemoveEveryObserver( CFNotificationCenterRef center, const void *observer, __CFRemoverCallBack cb );
void __CFInvokeCallBacks( CFNotificationCenterRef center, CFHashCode name, CFStringRef nameReturn, const void *object, const void *objectReturn, CFDictionaryRef userInfo, Boolean deliverNow );

void __CFPostDistributedNotification( CFNotificationCenterRef center, CFStringRef name, CFStringRef object, CFDictionaryRef userInfom, CFOptionFlags options );
void __CFPostDarwinNotification( CFNotificationCenterRef center, CFStringRef name );

void __CFAddQueue( CFStringRef name, const void *object, const void *observer, CFDictionaryRef userInfo, CFNotificationCallback callback, Boolean coalesce );
void __CFDeliverQueue( void );

Boolean _CFNotificationCenterIsSuspended( CFNotificationCenterRef center );
void _CFNotificationCenterSetSuspended( CFNotificationCenterRef center, Boolean suspended );

/*
 *    Add or remove a notification from the table of distributed notifications we are
 *    monitoring. When the first notification with a unique signature is added (or the
 *    last is removed) we make a call to the ddistnoted daemon to register (or unregister)
 *    for that notification.
 *
 *    When the first monitored notification is added (or the last is removed) we add the
 *    message port source to (or remove it from) the main runloop.
 */
CFDataRef __CFDistRecieve( CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info );
void __CFDistAddNotification( CFStringRef name, CFHashCode hash, CFHashCode object );
void __CFDistRemoveNotification( CFHashCode hash, CFHashCode object );

// Darwin Notification Center
void __CFDarwinAddNotification( CFStringRef name, CFHashCode hash, CFHashCode ignored );
void __CFDarwinRemoveNotification( CFHashCode hash, CFHashCode ignored );
void __CFDarwinCallBack(CFMachPortRef port, void *msg, CFIndex size, void *info);


#pragma mark - hashing

/*
 *	Strings (names for all notifications, and objects from distributed observers) are
 *	stored as hashes in the look-up tables, with strings stored in the __CFHashStore
 *	dictionary
 *
 *	Strings are copied into the dictionary. At present, they are never removed.
 */

// this should maybe be called "hashAndStore" - use CFHash() for just the hash
CFHashCode __CFNCHash(CFStringRef string) {
    if (!string) {
        return 0;
    }
	CFHashCode hash = CFHash(string);

    __CFLock(&__CFHashStoreLock);
    
    if (!CFDictionaryContainsKey(__CFHashStore, (const void *)hash)) {
		CFDictionaryAddValue( __CFHashStore, (const void *)hash, CFStringCreateCopy( kCFAllocatorDefault, string) );
    }

    __CFUnlock(&__CFHashStoreLock);
    
	return hash;
}

CFStringRef __CFNCUnhash(CFHashCode hash) {
	
    CFStringRef string = NULL;
    
    __CFLock(&__CFHashStoreLock);
    if (hash) {
		string = CFDictionaryGetValue(__CFHashStore, (const void *)hash);
    }
    __CFUnlock(&__CFHashStoreLock);
    
	return string;
}

#pragma mark - Managing Observers

// Increase the retain count for the observer
inline void __CFObserverRetain(__CFObserver *observer) {
    observer->retainCount++;
}

// Decrease the retain count and free the observer. This doesn't unlink the observer.
inline void __CFObserverRelease(__CFObserver *observer) {
    observer->retainCount--;
    if (!observer->retainCount) {
        free(observer);
    }
}

/*
 *    Add an observer to the notification centre. In the local case at least, the CF
 *    behaviour is to allow multiple indentical observers.
 */
void CFNotificationCenterAddObserver(CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior)
{
    // TODO: check how real CF deals with "" as names
    // TODO: also check if it actually disallows !name && !object combos
    
    // common causes of failure
    if (!center || CFGetTypeID(center) != __kCFNotificationCenterTypeID || !callBack) {
        return;
    }
    
    
    switch (center->type)
    {
        case kCFNotificationCenterLocal:
            __CFAddObserver(center, observer, callBack, name, object, 0, NULL);
            break;
            
        case kCFNotificationCenterDistributed:
            // TODO: this needs checking
            // For distributed centres, object should always be a string. We hash the string and use
            //    this value for all comparisons until notifications are delivered
            if( object != NULL )
            {
                if( CFGetTypeID((CFTypeRef)object) != CFStringGetTypeID() ) return;
                object = (const void *)__CFNCHash(object);
            }
            __CFAddObserver(center, observer, callBack, name, object, suspensionBehavior, __CFDistAddNotification);
            break;
            
        case kCFNotificationCenterDarwin:
            if (!name) {
                return;
            }
            __CFAddObserver(center, observer, callBack, name, NULL, 0, __CFDarwinAddNotification);
            break;
    }
}

void CFNotificationCenterRemoveObserver(CFNotificationCenterRef center, const void *observer, CFStringRef name, const void *object)
{
    if (!center || !observer || CFGetTypeID(center) != __kCFNotificationCenterTypeID || !center->firstObserver) {
        return;
    }
    
    CFHashCode hash = name ? CFHash(name) : 0;
    
    switch (center->type) {
        case kCFNotificationCenterDistributed:
            if (object) {
                if (CFGetTypeID(object) != CFStringGetTypeID()) return; // wouldn't have been added
                object = (void *)CFHash(object);
            }
            if (!name && !object) {
                __CFRemoveEveryObserver(center, observer, __CFDistRemoveNotification);
            } else {
                __CFRemoveObserver(center, observer, hash, object, __CFDistRemoveNotification);
            }
            break;
            
        case kCFNotificationCenterLocal:
            if (!name && !object) {
                __CFRemoveEveryObserver(center, observer, NULL);
            } else {
                __CFRemoveObserver(center, observer, hash, object, NULL);
            }
            break;
            
        case kCFNotificationCenterDarwin:
            if (!name) {
                __CFRemoveEveryObserver(center, observer, __CFDarwinRemoveNotification);
            } else {
                __CFRemoveObserver(center, observer, hash, NULL, __CFDarwinRemoveNotification);
            }
            break;
    }
}

void CFNotificationCenterRemoveEveryObserver(CFNotificationCenterRef center, const void *observer) {
    if (!center || !observer || CFGetTypeID(center) != __kCFNotificationCenterTypeID || !center->firstObserver) {
        return;
    }
    
    switch (center->type) {
        case kCFNotificationCenterLocal:
            __CFRemoveEveryObserver(center, observer, NULL);
            break;
        case kCFNotificationCenterDistributed:
            __CFRemoveEveryObserver(center, observer, __CFDistRemoveNotification);
            break;
        case kCFNotificationCenterDarwin:
            __CFRemoveEveryObserver(center, observer, __CFDarwinRemoveNotification);
            break;
    }
}


/*
 *	Add the observer info into the table of observers for the notification center, growing the
 *	table if need be. Duplicate observers with identical signatures are allowed.
 */
void __CFAddObserver( CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior, __CFAdderCallBack cb )
{
    __CFLock(&center->lock);
    
    __CFObserver *obs = malloc(sizeof(__CFObserver));
    
    obs->retainCount = 1;
	obs->name = __CFNCHash(name);
	obs->object = object;
	obs->observer = observer;
	obs->callback = callBack;
	obs->sb = suspensionBehavior;
	obs->next = NULL;
    
    // Add the new observer to the end of the list (to replicate macOS CF's apparent behaviour)
    __CFObserver **next = &center->firstObserver;
    while (*next) {
        next = &(*next)->next;
    }
    *next = obs;
    
    center->observersCount++;
    
    if (cb) {
        cb(name, obs->name, (CFHashCode)object);
    }
	
    __CFUnlock(&center->lock);
}

// Remove every instance of the observer where the name:object signature matches
void __CFRemoveObserver( CFNotificationCenterRef center, const void *observer, CFHashCode name, const void *object, __CFRemoverCallBack cb )
{
    __CFLock(&center->lock);
	
    __CFObserver *current = center->firstObserver;
    __CFObserver **previous = &center->firstObserver;
	
    while (current) {

        if (current->observer == observer
            && /* match name hash */ (!name || name == current->name)
            && /* match object */ (!object || object == current->object)) {

            *previous = current->next;
            
            current->callback = NULL;
            __CFObserverRelease(current); // May free observer
            center->observersCount--;
            
            current = *previous;

            if (cb) cb(name, (CFHashCode)object);
		
        } else {
            previous = &current->next;
            current = *previous;
        }
	}
	
    __CFUnlock(&center->lock);
}

// Remove every instance of the observer, no matter what the name:object signature
void __CFRemoveEveryObserver(CFNotificationCenterRef center, const void *observer, __CFRemoverCallBack cb) {

    __CFLock(&center->lock);

    __CFObserver *current = center->firstObserver;
    
    // TODO: write a test for this on macOS, because I don't think it should work like this
    
	while (current) {
        __CFObserver *next = current->next;

        current->callback = NULL;
        __CFObserverRelease(current); // May free observer
        center->observersCount--;

        current = next;
	}
	
    __CFUnlock(&center->lock);
}

/*
 *	Invoke the callback functions for the observers whose signature match the arguments.
 *
 *	This is a general routine which handles the special suspension behaviour of the
 *	distributed centre at the cost of extra un-needed checks while processing local
 *	and Darwin centre notifications.
 *
 *	I'm not entirely sure whether notifications sent with kCFNotificationDeliverImmediately
 *	should behave like notifications delivered to suspended observers with the deliver
 *	immediately behaviour and flush the notification queue... so at the moment it just
 *	jumps the queue and is delivered on its own.
 *
 *	The name and object arguments are used to find matching observers, while the nameReturn
 *	and objectReturn are passed to the observer's callbacks or queued.
 *		Local:			object == objectReturn
 *		Distributed:	object == hash, objectReturn == CFStringRef
 *		Darwin:			object == objectReturn == NULL
 */
void __CFInvokeCallBacks(CFNotificationCenterRef center, CFHashCode name, CFStringRef nameReturn, const void *object, const void *objectReturn, CFDictionaryRef userInfo, Boolean deliverNow) {

    __CFLock(&center->lock);
    
    __CFObserver **matched = calloc(center->observersCount, sizeof(__CFObserver *));
    __CFObserver **ptr = matched;
    CFIndex matches = 0;

    {
        __CFObserver *current = center->firstObserver;
        
        while (current) {
            // for an observer to qualify to recieve a notification, its signature needs to match
            //    both name and object, taking into account the NULL-case "match any name or object"
            if ( /* match name hash */ (!current->name || current->name == name)
                /* match object */ && (!current->object || current->object == object)) {
                
                __CFObserverRetain(current);
                *ptr++ = current;
                matches++;
            }
            current = current->next;
        }
    }
    
    ptr = matched;
    
    while (matches--) {
        
        __CFObserver *current = *ptr++;
        
        // callback is set to NULL when unlinking, incase
        if (current->callback) {
        
            // found a match, now do we deliver the notification?
            if (deliverNow /* non-dist short-circuit */ || !center->suspended) {

                // CFMachPort source suggested unlocking before invoking callbacks
                // This will allow the callback to modify the observers registered with the center
                // Which is why we copied the pointers from the linked list and check for unlinking
                __CFUnlock(&center->lock);
                current->callback(center, (void *)current->observer, nameReturn, objectReturn, userInfo);
                __CFLock(&center->lock);
                
            } else {
                switch (current->sb) {
                    case CFNotificationSuspensionBehaviorDrop:
                        break;
                    case CFNotificationSuspensionBehaviorCoalesce:
                        __CFAddQueue(nameReturn, objectReturn, current->observer, userInfo, current->callback, true);
                        break;
                    case CFNotificationSuspensionBehaviorHold:
                        __CFAddQueue(nameReturn, objectReturn, current->observer, userInfo, current->callback, false);
                        break;
                    case CFNotificationSuspensionBehaviorDeliverImmediately:
                        if (__CFDistInfo.firstRecord) {
                            __CFDeliverQueue();
                        }
                        current->callback(center, (void *)current->observer, nameReturn, objectReturn, userInfo);
                        break;
                }
            }
        }
        
        __CFObserverRelease(current);
    }
    
    free(matched);

    __CFUnlock(&center->lock);
}


/*
 *	Type-specific notification posting functions
 */

#pragma mark - Posting Notifications

void CFNotificationCenterPostNotification(CFNotificationCenterRef center, CFStringRef name, const void *object, CFDictionaryRef userInfo, Boolean deliverImmediately)
{
    CFOptionFlags options = deliverImmediately ? kCFNotificationDeliverImmediately : 0;
    return CFNotificationCenterPostNotificationWithOptions(center, name, object, userInfo, options);
}

void CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterRef center, CFStringRef name, const void *object, CFDictionaryRef userInfo, CFOptionFlags options)
{
    //fprintf(stderr, "Entering CFNotificationCenterPostNotificationWithOptions()\n");
    
    if (!center || !name || CFGetTypeID(center) != __kCFNotificationCenterTypeID) {
        return;
    }
    
    CFHashCode hash = CFHash(name);
    
    switch (center->type) {
        case kCFNotificationCenterLocal:
            if (center->firstObserver) {
                // TODO: dispatch async to the main thread if not already on it
                __CFInvokeCallBacks( center, hash, name, object, object, userInfo, TRUE );
            }
            break;
        case kCFNotificationCenterDistributed:
            __CFPostDistributedNotification( center, name, (CFStringRef)object, userInfo, options );
            //fprintf(stderr, "Leaving CFNotificationCenterPostNotificationWithOptions()\n");
            break;
        case kCFNotificationCenterDarwin:
            __CFPostDarwinNotification( center, name );
            break;
    }
}

#pragma mark - Local Notification Center

static CFNotificationCenterRef __CFLocalCenter = NULL;
static CFLock_t __CFLocalCenterLock = CFLockInit;

// The local notification center is used for synchronous intra-task communication and can always be created
CFNotificationCenterRef CFNotificationCenterGetLocalCenter(void) {
    __CFLock(&__CFLocalCenterLock);
    if(!__CFLocalCenter) {
        __CFLocalCenter = __CFCreateCenter(kCFNotificationCenterLocal);
    }
    __CFUnlock(&__CFLocalCenterLock);
    return __CFLocalCenter;
}


#pragma mark - Distributed Notification Center

static CFNotificationCenterRef __CFDistributedCenter = NULL;
static CFLock_t __CFDistributedCenterLock = CFLockInit;

/*
 *    The distributed center relies on the presence of a daemon (our ddistnoted on
 *    Darwin) to deliver inter-task notifications. This implementation tries to contact
 *    it via CFMessagePort, and fails if a connection cannot be made.
 */
CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void) {
    
    __CFLock(&__CFDistributedCenterLock);
    
    if (!__CFDistributedCenter) {
        // generate a 'unique' port name for the current task
        char uname[128];
        sprintf(uname, "ddistnoted-%s-%u", getprogname(), getpid());
        CFStringRef name = CFStringCreateWithCString( kCFAllocatorDefault, uname, kCFStringEncodingASCII );
        
        // create the local port now, because the daemon will look for it
        CFMessagePortContext context = { 0, NULL, NULL, NULL, NULL };
        CFMessagePortRef local = CFMessagePortCreateLocal( kCFAllocatorDefault, name, __CFDistRecieve, &context, NULL );
        
        if (!local) {
            fprintf(stderr, "CFNC: Couldn't create a local message port.\n");
            __CFUnlock(&__CFDistributedCenterLock);
            return NULL;
        }
        
        // create the remote port
        CFMessagePortRef remote = CFMessagePortCreateRemote( kCFAllocatorDefault, CFSTR("org.puredarwin.ddistnoted") );
        
        if (!remote) {
            fprintf(stderr, "CFNC: Couldn't connect to message port.\n");
            __CFUnlock(&__CFDistributedCenterLock);
            return NULL;
        }
        
        // squeeze our unique name, as ASCII, into a data object...
        CFIndex length = CFStringGetLength(name);
        UInt8 data[(++length + sizeof(long))];
        
        /*    Security sessions come via one of the security components, although
         I'm not sure which. Once we get everything working we may be able to
         actually get this working properly. */
        
        // if this isn't set -- and on other platforms -- we could maybe use userIds
        long session = getuid();
        if (!session) session = 1;
        
        CFStringGetCString(name, (char *)(data + sizeof(long)), length, kCFStringEncodingASCII);
        CFDataRef dataOut = CFDataCreate( kCFAllocatorDefault, (const UInt8 *)data, (length + sizeof(long)) );
        CFShow(name);
        CFShow(dataOut);
        
        // ...send the register message...
        CFDataRef dataIn = NULL;
        // this is where it is now failing...
        SInt32 result = CFMessagePortSendRequest( remote, kCFDistributedMessageIDRegisterPort, dataOut, 1.0, 1.0, kCFRunLoopDefaultMode, &dataIn);
        
        CFRelease(name);
        CFRelease(dataOut);
        
        if (result || !dataIn || !CFDataGetLength(dataIn)) {
            __CFUnlock(&__CFDistributedCenterLock);
            return NULL;
        }
        
        CFHashCode hash;
        CFRange range = { 0, sizeof(CFHashCode) };
        CFDataGetBytes(dataIn, range, (UInt8 *)&hash);
        
        // that seemed to work, so we'll try to allocate the centre object
        __CFDistributedCenter = __CFCreateCenter(kCFNotificationCenterDistributed);
        
        if (!__CFDistributedCenter) {
            printf("exit D\n");
            __CFUnlock(&__CFDistributedCenterLock);
            return NULL;
        }
        
        __CFDistInfo.local = local;
        __CFDistInfo.remote = remote;
        __CFDistInfo.session = session;
        __CFDistInfo.uid = hash;
        __CFDistInfo.rls = CFMessagePortCreateRunLoopSource( kCFAllocatorDefault, local, 0 );
        __CFDistInfo.firstNotification = NULL;
        __CFDistInfo.firstRecord = NULL;
    }

    __CFUnlock(&__CFDistributedCenterLock);
    
    return __CFDistributedCenter;
}

/*
 *    Set the suspended condition of the distributed notification centre (only). At the
 *    moment these will be left as no-ops, to be activated when we write the
 *    NSDitributedNotificationCenter class (which provides -setSuspended: and -suspended
 *    methods).
 *
 *    The docs suggested that these functions existed, and running nm over CoreFoundation
 *    revealed their names. I'm just guessing their prototypes at the moment, and hoping
 *    that nothing tries to call them directly.
 */
Boolean _CFNotificationCenterIsSuspended(CFNotificationCenterRef center) {
    return center->suspended;
}

void _CFNotificationCenterSetSuspended(CFNotificationCenterRef center, Boolean suspended) {
    // Only distributed notification centers can be suspended
    if (center->type != kCFNotificationCenterDistributed) {
        return;
    }
        
    __CFLock(&center->lock);
    
    if (center->suspended != suspended) { // changing state?
        center->suspended = suspended;
        // have we just un-suspended and are there notifications to deliver?
        if (!suspended && __CFDistInfo.firstRecord) {
            __CFDeliverQueue();
        }
    }

    __CFUnlock(&center->lock);
}


/*
 *    Post a notification to the ddistnoted daemon which runs the distributed
 *    notification centre.
 *
 *    ddistnoted uses name and object hashes, along with session ids, to route
 *    distributions. The data object contains a 3-item array containing the name,
 *    object string and userInfo dictionary. We have to send the name and object
 *    because an observer may not have previously hashed and stored either string.
 */
void __CFPostDistributedNotification( CFNotificationCenterRef center, CFStringRef name, CFStringRef object, CFDictionaryRef userInfo, CFOptionFlags options )
{
    CFPropertyListRef plist[3];
    plist[0] = name;
    
    // object must be a string when posting to a distributed centre
    CFHashCode objectHash;
    if(object == NULL)
    {
        objectHash = 0;
        plist[1] = kCFBooleanFalse; // used to signal a null entry
    }
    else
    {
        if(CFGetTypeID(object) != CFStringGetTypeID()) return;
        objectHash = __CFNCHash(object);
        plist[1] = object;
    }
    
    plist[2] = userInfo ?: (CFPropertyListRef)kCFBooleanFalse;
    CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void **)&plist, 3, NULL );
    
    // we don't need to store the strings these hashes represent
    CFHashCode nameHash = CFHash(name);
    dndNotHeader info = { __CFDistInfo.session, nameHash, objectHash, options };
    
    CFWriteStreamRef ws = CFWriteStreamCreateWithAllocatedBuffers( kCFAllocatorDefault, kCFAllocatorDefault );
    CFWriteStreamOpen(ws);
    CFWriteStreamWrite( ws, (const UInt8 *)&info, sizeof(dndNotHeader) );
    
    // write the property list, but don't worry if an error occurs
    CFPropertyListWriteToStream( array, ws, kCFPropertyListBinaryFormat_v1_0, NULL );
    
    CFWriteStreamClose(ws);
    CFDataRef data = CFWriteStreamCopyProperty( ws, kCFStreamPropertyDataWritten );
    CFRelease(ws);
    CFRelease(array);
    
    if( data == NULL ) return;
    
    CFMessagePortSendRequest( __CFDistInfo.remote, kCFDistributedMessageIDNotification, data, 1.0, 1.0, NULL, NULL );
}

/*
 *    recieves messages from the ddistnoted daemon
 *
 *    In a later version we're going to have to take note of the centre's suspended
 *    state, queuing and coalescing messages as needed
 */
CFDataRef __CFDistRecieve( CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info )
{
    //printf("local port done got a message.\n");
    
    // center hasn't been created at the time the callback's set, so just as easier to pull in the global
    CFNotificationCenterRef center = __CFDistributedCenter;
    
    CFIndex length = CFDataGetLength(data);
    if( length < sizeof(dndNotHeader) ) return NULL;
    
    CFReadStreamRef rs = CFReadStreamCreateWithBytesNoCopy( kCFAllocatorDefault, CFDataGetBytePtr(data), length, NULL );
    CFReadStreamOpen(rs);
    
    dndNotHeader header;
    CFReadStreamRead( rs, (UInt8 *)&header, sizeof(dndNotHeader) );
    
    // the rest of the data contains an array: [name, object, userInfo] with kCFBooleanFalse representing
    //    a missing object or userInfo
    CFPropertyListRef array = NULL;
    CFIndex format = kCFPropertyListBinaryFormat_v1_0;
    array = CFPropertyListCreateFromStream( kCFAllocatorDefault, rs, 0, kCFPropertyListImmutable, &format, NULL );
    if( (array == NULL) || (CFGetTypeID(array) != CFArrayGetTypeID()) ) return NULL;
    
    // now recover and set up the arguments to invoke callbacks. If either name or object hasn't been
    //    encountered (and hashed) before, add it to the hash store now, so that coalescing based on
    //    pointers will work later. If it ever needs to.
    CFStringRef name;
    if( (name = __CFNCUnhash(header.name)) == NULL ) // we haven't met this name before
    {
        __CFNCHash( CFArrayGetValueAtIndex(array, 0) );
        name = __CFNCUnhash(header.name);
    }
    
    CFStringRef object;
    if( header.object == 0 )
        object = NULL;
    else
        if( (object = __CFNCUnhash(header.object)) == NULL )
        {
            __CFNCHash( CFArrayGetValueAtIndex(array, 1) );
            object = __CFNCUnhash(header.object);
        }
    
    CFPropertyListRef userInfo = CFArrayGetValueAtIndex(array, 2);
    if( CFGetTypeID(userInfo) != CFDictionaryGetTypeID() ) userInfo = NULL;
    
    // we deliver now if the centre isn't suspended or the messages header says we should
    Boolean deliverNow = header.flags | kCFNotificationDeliverImmediately;
    
    __CFInvokeCallBacks(center, header.name, name, (const void *)header.object, (const void *)object, userInfo, deliverNow);
    
    if( userInfo != NULL ) CFRelease(userInfo);
    return NULL;
}

/*
 *    Add a notification to the table of registered notifications, optionally registering it with
 *    the ddistnoted daemon and adding the local message port's source to the main runloop
 *
 *    We can ignore name.
 */
void __CFDistAddNotification( CFStringRef name, CFHashCode hash, CFHashCode object ) {

    // Check whether we're already listening for this notification
    __CFDistNotification *current = __CFDistInfo.firstNotification;
    while (current) {
        if (current->hash == hash && current->object == object) {
            current->count++;
            return;
        }
        current = current->next;
    }
    
    // We need to register for this notification
    dndNotReg info = { __CFDistInfo.uid, hash, object };
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&info, sizeof(dndNotReg));
    if (!data) {
        return;
    }
    SInt32 result = CFMessagePortSendRequest(__CFDistInfo.remote, kCFDistributedMessageIDRegisterNotification, data, 1.0, 0.0, NULL, NULL);
    CFRelease(data);
    if (result != kCFMessagePortSuccess) {
        return;
    }
    
    __CFDistNotification *notification = malloc(sizeof(__CFDistNotification));
    
    notification->next = __CFDistInfo.firstNotification;
    notification->hash = hash;
    notification->object = object;
    notification->count = 1;
    
    if (!__CFDistInfo.firstNotification) {
        CFRunLoopAddSource(CFRunLoopGetMain(), __CFDistInfo.rls, kCFRunLoopCommonModes);
    }
    
    __CFDistInfo.firstNotification = notification;
}

// Invoked whenever an observer is removed from the Distributed Notification Center
void __CFDistRemoveNotification(CFHashCode hash, CFHashCode object) {
    
    __CFDistNotification *current = __CFDistInfo.firstNotification;
    __CFDistNotification **previous = &__CFDistInfo.firstNotification;
    
    while (current) {
        
        if (current->hash == hash && current->object == object) {
            
            // Found a matching notification
            current->count--;
            
            if (!current->count) {
                // Unlink and free this notification
                *previous = current->next;
                free(current);
                
                // Unregister for the notification
                dndNotReg info = { __CFDistInfo.uid, hash, object };
                CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&info, sizeof(dndNotReg));
                if (data) {
                    CFMessagePortSendRequest(__CFDistInfo.remote, kCFDistributedMessageIDUnregisterNotification, data, 1.0, 1.0, NULL, NULL);
                    CFRelease(data);
                }
                
                // Check whether we can disable the runloop source
                if (!__CFDistInfo.firstNotification) {
                    CFRunLoopRemoveSource(CFRunLoopGetMain(), __CFDistInfo.rls, kCFRunLoopCommonModes);
                }
            }
            
            return;
        }
        
        previous = &current->next;
        current = *previous;
    }
}

/*
 *    Manage the message queue, which is used to store distributed notifications
 *    when delivery has been suspended.
 */
void __CFAddQueue( CFStringRef name, const void *object, const void *observer, CFDictionaryRef userInfo, CFNotificationCallback callback, Boolean coalesce )
{
    CFRetain(userInfo);

    if (coalesce) { // do we check for this notification in the queue?

        __CFQueueRecord *current = __CFDistInfo.firstRecord;
        while (current) {
            // we're looking for exactl matches on name, object, observer and callback
            if (current->name == name && current->object == object
                && current->observer == observer && current->callback == callback)
            {
                CFRelease(current->userInfo);
                current->userInfo = userInfo;
                break;
            }
            current = current->next;
        }
    }
    
    __CFQueueRecord *record = malloc(sizeof(__CFQueueRecord));
    if (!record) {
        return;
    }

    record->next = __CFDistInfo.firstRecord;
    record->name = name;
    record->object = object;
    record->observer = observer;
    record->callback = callback;
    record->userInfo = userInfo;
    
    __CFDistInfo.firstRecord = record;
}

void __CFDeliverQueue( void ) {
    
    __CFQueueRecord *current = __CFDistInfo.firstRecord;
    __CFDistInfo.firstRecord = NULL; // Detatch the queue so callbacks are free to alter it

    while (current) {
        
        __CFUnlock(&__CFDistributedCenter->lock);
        current->callback( __CFDistributedCenter, (void *)current->observer, current->name, current->object, current->userInfo );
        __CFLock(&__CFDistributedCenter->lock);

        __CFQueueRecord *next = current->next;
        
        CFRelease(current->userInfo);
        free(current);

        current = next;
    }
}

#pragma mark - Darwin Notification Center

static CFNotificationCenterRef __CFDarwinCenter = NULL;
static CFLock_t __CFDarwinCenterLock = CFLockInit;

/*
 *    The Darwin notification center passes inter-task notifications via the notifyd
 *    daemon, with which it comunicates using the functions in <notify.h> for sending
 *    and a runloop-attached Mach port for recieving. I think this is Darwin-specific,
 *    altough other BSDs may have a similar set-up.
 *
 *    We create the CFMachPort and its runloop source used for recieving messages here
 *    so that they're available when observers are added.
 */
CFNotificationCenterRef CFNotificationCenterGetDarwinNotifyCenter(void) {

    __CFLock(&__CFDarwinCenterLock);
    
    if (!__CFDarwinCenter) {
        __CFDarwinCenter = __CFCreateCenter(kCFNotificationCenterDarwin);
        
        CFMachPortContext context = { 0, (void *)__CFDarwinCenter, NULL, NULL, NULL };
        __CFDarwinInfo.port = CFMachPortCreate( kCFAllocatorDefault, __CFDarwinCallBack, &context, NULL );
        __CFDarwinInfo.rls = CFMachPortCreateRunLoopSource( kCFAllocatorDefault, __CFDarwinInfo.port, 0 );
        __CFDarwinInfo.first = NULL;
    }

    __CFUnlock(&__CFDarwinCenterLock);
    
    return __CFDarwinCenter;
}

// Darwin notifications are posted via the notify api
void __CFPostDarwinNotification(CFNotificationCenterRef center, CFStringRef name) {
	CFIndex length = CFStringGetLength(name);
    if (!length) {
        return;
    }
	char buffer[++length];
    if (!CFStringGetCString(name, buffer, length, kCFStringEncodingASCII)) {
        return;
    }
	notify_post(buffer);
}

/*
 *    Functions used to add and remove notifications to the list we are monitoring and register
 *    with notifyd to recieve them. We track how many times each is added and removed, so we can
 *    unregister for notifications when they're no-longer needed. As above, assumes the structure
 *    is spinlocked.
 */

void __CFDarwinAddNotification(CFStringRef name, CFHashCode hash, CFHashCode ignored) {
    
    // Check if we are already listening for this notification
    __CFDarwinNotifications *current = __CFDarwinInfo.first;
    while (current) {
        if (current->hash == hash) {
            current->count++;
            return;
        }
        current = current->next;
    }
    
    // We haven't registered for this notification yet

    int token;
    const char *buffer = CFStringGetCStringPtr(name, kCFStringEncodingUTF8);
    mach_port_t port = CFMachPortGetPort(__CFDarwinInfo.port);
    
    if (notify_register_mach_port(buffer, &port, NOTIFY_REUSE, &token)) {
        return;
    }
    
    __CFDarwinNotifications *notification = malloc(sizeof(__CFDarwinNotifications));
    if (!notification) {
        return;
    }
    
    notification->next = __CFDarwinInfo.first;
    notification->hash = hash;
    notification->token = token;
    notification->count = 1;

    // If we haven't set up the linked list, we also need to register the runloop source
    if (!__CFDarwinInfo.first) {
        CFRunLoopAddSource(CFRunLoopGetMain(), __CFDarwinInfo.rls, kCFRunLoopCommonModes);
    }
    
    __CFDarwinInfo.first = notification;
}

void __CFDarwinRemoveNotification(CFHashCode hash, CFHashCode ignored) {
    
    __CFDarwinNotifications *current = __CFDarwinInfo.first;
    __CFDarwinNotifications **previous = &__CFDarwinInfo.first;
    
    while (current) {
        
        if (current->hash == hash) {
            
            // Found a matching notification
            current->count--;
            
            if (!current->count) {
                // Unlink and free this notification
                *previous = current->next;
                free(current);
                
                // Check whether we can disable the runloop source
                if (!__CFDarwinInfo.first) {
                    CFRunLoopRemoveSource(CFRunLoopGetMain(), __CFDarwinInfo.rls, kCFRunLoopCommonModes);
                }
            }
            
            return;
        }
        
        previous = &current->next;
        current = *previous;
    }
}

/*
 *    The CFMachPortCallBack invoked when a message arrives at the runloop from notifyd. The
 *    Darwin notification centre is passed in as the info... just because.
 */
void __CFDarwinCallBack(CFMachPortRef port, void *msg, CFIndex size, void *info) {
    //printf("Got a message from a darwin port!\n");
    
    // First we retrieve the token associated with the notification
    int token = ((mach_msg_header_t *)msg)->msgh_id;
    
    // Then we look for the matching record
    __CFDarwinNotifications *current = __CFDarwinInfo.first;
    
    while (current) {
        if (current->token == token) {
            break;
        }
        current = current->next;
    }
    
    // Then we send the notification to all the matching observers
    if (current) {
        __CFInvokeCallBacks(__CFDarwinCenter, current->hash, __CFNCUnhash(current->hash), NULL, NULL, NULL, TRUE);
    }
}
