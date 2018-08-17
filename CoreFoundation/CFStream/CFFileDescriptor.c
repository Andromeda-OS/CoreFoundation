/*
 *  CFFileDescriptor.c
 *  CFFileDescriptor
 *
 *  http://www.puredarwin.org/ 2009, 2018
 */

#include <CoreFoundation/CFRunLoop.h>
#include "CFPriv.h"
#include "CFInternal.h"
#include "CFFileDescriptor.h"

// for mach ports
#include <mach/mach.h>
#include <mach/mach_error.h>
#include <mach/notify.h>


typedef struct __CFFileDescriptor {
	CFRuntimeBase _base;
	CFFileDescriptorNativeDescriptor fd;
	CFFileDescriptorCallBack callback;
	CFFileDescriptorContext context; // includes info for callback
	CFRunLoopSourceRef rls;	
	mach_port_t port;
    dispatch_source_t read_source;
    dispatch_source_t write_source;
    CFLock_t lock;
} __CFFileDescriptor;

static CFTypeID __kCFFileDescriptorTypeID = _kCFRuntimeNotATypeID;

CFTypeID CFFileDescriptorGetTypeID(void) { return __kCFFileDescriptorTypeID; }


#pragma mark - Managing dispatch sources

dispatch_source_t __CFFDCreateSource(CFFileDescriptorRef f, CFOptionFlags callBackType);
void __CFFDRemoveSource(CFFileDescriptorRef f, CFOptionFlags callBackType);
void __CFFDEnableSources(CFFileDescriptorRef f, CFOptionFlags callBackTypes);
void __CFFDSourceInvoked(CFFileDescriptorRef f, CFOptionFlags callBackType);

// create and return a dispatch source of the given type
dispatch_source_t __CFFDCreateSource(CFFileDescriptorRef f, CFOptionFlags callBackType) {
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, f->fd, 0, dispatch_get_main_queue());
    if (source) {
        dispatch_source_set_event_handler(source, ^{
            __CFFDSourceInvoked(f, callBackType);
        });
    }
    return source;
}

// callBackType will be one of Read and Write
void __CFFDRemoveSource(CFFileDescriptorRef f, CFOptionFlags callBackType) {
    if (callBackType == kCFFileDescriptorReadCallBack && f->read_source) {
        dispatch_source_cancel(f->read_source);
        dispatch_release(f->read_source);
        f->read_source = NULL;
    }
    if (callBackType == kCFFileDescriptorWriteCallBack && f->write_source) {
        dispatch_source_cancel(f->write_source);
        dispatch_release(f->write_source);
        f->write_source = NULL;
    }
}

// enable dispatch source callbacks on either lazy port creation or CFFileDescriptorEnableCallBacks()
// callBackTypes are the types just enabled, or both if called from the port creation function
void __CFFDEnableSources(CFFileDescriptorRef f, CFOptionFlags callBackTypes) {
    if (!f->port) {
        return;
    }
    if (callBackTypes & kCFFileDescriptorReadCallBack && f->read_source) {
        dispatch_resume(f->read_source);
    }
    if (callBackTypes & kCFFileDescriptorWriteCallBack && f->write_source) {
        dispatch_resume(f->write_source);
    }
}

// callBackType will be one of Read and Write
void __CFFDSourceInvoked(CFFileDescriptorRef f, CFOptionFlags callBackType) {
    
    if (!f->port) {
        return;
    }
    
    mach_msg_header_t header;
    mach_msg_return_t ret;

    header.msgh_id = callBackType;
    header.msgh_bits = MACH_MSGH_BITS_REMOTE(MACH_MSG_TYPE_MAKE_SEND);
    header.msgh_size = 0;
    header.msgh_remote_port = f->port;
    header.msgh_local_port = MACH_PORT_NULL;
    header.msgh_reserved = 0;

    ret = mach_msg(&header, MACH_SEND_MSG, sizeof(mach_msg_header_t), 0, MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
    
    __CFFDRemoveSource(f, callBackType);
}

#pragma mark - RunLoop internal

// runloop get port callback: called lazily by the runloop to return the port it should communicate via
mach_port_t __CFFDGetPort(void *info) {
    
	CFFileDescriptorRef f = (CFFileDescriptorRef)info;

    __CFLock(&f->lock);
    
	if (f->port == MACH_PORT_NULL) {

        // create a mach port to communicate with the runloop (taken from the CFMachPort sources)
		mach_port_t port;
		
        kern_return_t ret = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &port);
		if (ret != KERN_SUCCESS) {
            __CFUnlock(&f->lock);
			return MACH_PORT_NULL;
		}
		
		f->port = port;
        
        __CFFDEnableSources(f, kCFFileDescriptorReadCallBack | kCFFileDescriptorWriteCallBack);
	}

    __CFUnlock(&f->lock);
    
	return f->port;
}

// main runloop callback: invoke the user's callback
void *__CFFDRunLoopCallBack(void *msg_, CFIndex size, CFAllocatorRef allocator, void *info_) {
    
    mach_msg_header_t *msg = msg_;
    __CFFileDescriptor *info = info_;
    
    if (info->callback) {
        info->callback(info, msg->msgh_id, info->context.info);
    }
	return NULL;
}

#pragma mark - Internal

static void __CFFileDescriptorDeallocate(CFTypeRef cf) {
    
    CFFileDescriptorRef f = (CFFileDescriptorRef)cf;

    __CFLock(&f->lock);
    CFFileDescriptorInvalidate(f); // does most of the tear-down
    __CFUnlock(&f->lock);
}

static const CFRuntimeClass __CFFileDescriptorClass = {
    0,
    "CFFileDescriptor",
    NULL,    // init
    NULL,    // copy
    __CFFileDescriptorDeallocate,
    NULL, //__CFDataEqual,
    NULL, //__CFDataHash,
    NULL, //
    NULL, //__CFDataCopyDescription
};

// register the type with the CF runtime
__private_extern__ void __CFFileDescriptorInitialize(void) {
    __kCFFileDescriptorTypeID = _CFRuntimeRegisterClass(&__CFFileDescriptorClass);
}

// use the base reserved bits for storage (like CFMachPort does)
Boolean __CFFDIsValid(CFFileDescriptorRef f) { 
    return (Boolean)__CFRuntimeGetValue(f, 0, 0);
}

#pragma mark - Public

// create a file descriptor object
CFFileDescriptorRef	CFFileDescriptorCreate(CFAllocatorRef allocator, CFFileDescriptorNativeDescriptor fd, Boolean closeOnInvalidate, CFFileDescriptorCallBack callout, const CFFileDescriptorContext *context)
{
	if (!callout) return NULL;

	CFIndex size = sizeof(struct __CFFileDescriptor) - sizeof(CFRuntimeBase);
	CFFileDescriptorRef memory = (CFFileDescriptorRef)_CFRuntimeCreateInstance(allocator, __kCFFileDescriptorTypeID, size, NULL);
	if (!memory) {
        return NULL;
    }

	memory->fd = fd;
	memory->callback = callout;
    memory->context.version = 0;
    
	if (!context || context->version != 0) {
        memory->context.info = NULL;
        memory->context.retain = NULL;
        memory->context.release = NULL;
        memory->context.copyDescription = NULL;
    } else {
        memory->context.info = context->info;
        memory->context.retain = context->retain;
        memory->context.release = context->release;
        memory->context.copyDescription = context->copyDescription;
    }
	
	memory->rls = NULL;
	memory->port = MACH_PORT_NULL;
    memory->read_source = NULL;
    memory->write_source = NULL;
    memory->lock = CFLockInit;
	
    __CFRuntimeSetValue(memory, 0, 0, 1);
    __CFRuntimeSetValue(memory, 1, 1, closeOnInvalidate);
    
	return memory;
}


CFFileDescriptorNativeDescriptor CFFileDescriptorGetNativeDescriptor(CFFileDescriptorRef f) {
    if (!f || (CFGetTypeID(f) != CFFileDescriptorGetTypeID()) || !__CFFDIsValid(f)) {
        return -1;
    }
	return f->fd;
}

void CFFileDescriptorGetContext(CFFileDescriptorRef f, CFFileDescriptorContext *context) {
    
    if (!f || !context || (CFGetTypeID(f) != CFFileDescriptorGetTypeID()) || !__CFFDIsValid(f)) {
		return;
    }

    context->version = f->context.version;
	context->info = f->context.info;
	context->retain = f->context.retain;
	context->release = f->context.release;
	context->copyDescription = f->context.copyDescription;
}

// enable callbacks, setting kqueue filter, regardless of whether watcher thread is running
void CFFileDescriptorEnableCallBacks(CFFileDescriptorRef f, CFOptionFlags callBackTypes) {

	if (!f || !callBackTypes || (CFGetTypeID(f) != CFFileDescriptorGetTypeID()) || !__CFFDIsValid(f)) return;

    __CFLock(&f->lock);

	if (callBackTypes & kCFFileDescriptorReadCallBack && !f->read_source) {
        f->read_source = __CFFDCreateSource(f, kCFFileDescriptorReadCallBack);
        __CFFDEnableSources(f, kCFFileDescriptorReadCallBack);
	}
	
	if (callBackTypes & kCFFileDescriptorWriteCallBack && !f->write_source) {
        f->write_source = __CFFDCreateSource(f, kCFFileDescriptorWriteCallBack);
        __CFFDEnableSources(f, kCFFileDescriptorWriteCallBack);
	}
	
    __CFUnlock(&f->lock);
}

// disable callbacks, setting kqueue filter, regardless of whether watcher thread is running
void CFFileDescriptorDisableCallBacks(CFFileDescriptorRef f, CFOptionFlags callBackTypes)
{
	if (!f || !callBackTypes || (CFGetTypeID(f) != CFFileDescriptorGetTypeID()) || !__CFFDIsValid(f)) return;
	
    __CFLock(&f->lock);
    
	if (callBackTypes & kCFFileDescriptorReadCallBack && f->read_source) {
        __CFFDRemoveSource(f, kCFFileDescriptorReadCallBack);
	}
	
	if (callBackTypes & kCFFileDescriptorWriteCallBack && f->write_source) {
        __CFFDRemoveSource(f, kCFFileDescriptorWriteCallBack);
	}
	
    __CFUnlock(&f->lock);
}

// invalidate the file descriptor, possibly closing the fd
void CFFileDescriptorInvalidate(CFFileDescriptorRef f)
{
	if (!f || (CFGetTypeID(f) != CFFileDescriptorGetTypeID()) || !__CFFDIsValid(f)) return;
	
    __CFLock(&f->lock);

    __CFRuntimeSetValue(f, 0, 0, 0);

    __CFFDRemoveSource(f, kCFFileDescriptorReadCallBack);
    __CFFDRemoveSource(f, kCFFileDescriptorWriteCallBack);
    
	if (f->rls) {
		CFRelease(f->rls);
		f->rls = NULL;
	}
	
    if (__CFRuntimeGetValue(f, 1, 1)) { // close fd on invalidate
		close(f->fd);
    }
	
    __CFUnlock(&f->lock);
}

// is file descriptor still valid, based on _base header flags?
Boolean	CFFileDescriptorIsValid(CFFileDescriptorRef f) {
	if (!f || (CFGetTypeID(f) != CFFileDescriptorGetTypeID())) return FALSE;
    return __CFFDIsValid(f);
}

CFRunLoopSourceRef CFFileDescriptorCreateRunLoopSource(CFAllocatorRef allocator, CFFileDescriptorRef f, CFIndex order) {

	if (!f || (CFGetTypeID(f) != CFFileDescriptorGetTypeID()) || !__CFFDIsValid(f)) return NULL;

    __CFLock(&f->lock);
    
	if (!f->rls) {
		CFRunLoopSourceContext1 context = {
            1,
            (void *)CFRetain(f),
            (CFAllocatorRetainCallBack)f->context.retain,
            (CFAllocatorReleaseCallBack)f->context.release,
            (CFAllocatorCopyDescriptionCallBack)f->context.copyDescription,
            NULL,
            NULL,
            __CFFDGetPort,
            __CFFDRunLoopCallBack
        };
		CFRunLoopSourceRef rls = CFRunLoopSourceCreate( allocator, order, (CFRunLoopSourceContext *)&context );
		if( rls != NULL ) f->rls = rls;
	}

    __CFUnlock(&f->lock);

	return f->rls;
}
