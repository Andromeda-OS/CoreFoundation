//
//  NSDictionary.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PureFoundation.h"
#import "FileLoaders.h"

#define KEY_CALLBACKS (&kCFTypeDictionaryKeyCallBacks)
#define VALUE_CALLBACKS ((CFDictionaryValueCallBacks *)&_PFCollectionCallBacks)

#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)

#define SELF ((CFDictionaryRef)self)
#define MSELF ((CFMutableDictionaryRef)self)

// TODO: Implement these to reduce amount of in-line exception generating code
// t __NSDictionaryRaiseInsertNilKeyException
// t __NSDictionaryRaiseInsertNilValueException
// t __NSDictionaryRaiseRemoveNilKeyException

// CFDictionaryRef was originally CFHashRef
// NSFastEnumerationState * was originally struct __objcFastEnumerationStateEquivalent *
extern unsigned long _CFDictionaryFastEnumeration(CFDictionaryRef hc, NSFastEnumerationState *state, void *stackbuffer, unsigned long count);

#pragma mark - callbacks

typedef struct _PFKeysForObject {
    id object;
    CFMutableArrayRef array;
} _PFKeysForObject;

// find objects where isEqual: context[1] and put them into context[2]
static void PFKeysForObject(const void *key, const void *value, void *context) {
    _PFKeysForObject *ctx = context;
    if ([(id)value isEqual:ctx->object]) {
        CFArrayAppendValue(ctx->array, key);
    }
}

static CFDictionaryRef PFDictionaryInitFromVAList(void *first, va_list args) {
    va_list dargs;
    va_copy(dargs, args);
    CFIndex count = 1;
    while (va_arg(dargs, void *)) count++;
    va_end(dargs);
    
    if (count & 1) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    count /= 2;
    
    void **objects = NULL;
    void **keys = NULL;
    if (count == 1) {
        objects = &first;
        keys = va_arg(args, void *);
    } else {
        void **o_ptr = objects = malloc(count * sizeof(void *));
        void **k_ptr = keys = malloc(count * sizeof(void *));
        *o_ptr++ = first;
        *k_ptr++ = va_arg(args, void *);
        while ((*o_ptr++ = va_arg(args, void *))) {
            *k_ptr++ = va_arg(args, void *);
        }
    }
    
    CFDictionaryRef dict = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS);
    if (count > 1) {
        free(objects);
        free(keys);
    }
    return dict;
}

static CFDictionaryRef PFDictionaryInitFromArrays(CFArrayRef keys, CFArrayRef values) {
    CFIndex keysCount = CFArrayGetCount(keys);
    CFIndex valuesCount = CFArrayGetCount(values);
    if (keysCount != valuesCount) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    void **pKeys = NULL;
    void **pValues = NULL;
    if (keysCount) {
        pKeys = malloc(keysCount * sizeof(void *));
        pValues = malloc(valuesCount * sizeof(void *));
        CFRange range = CFRangeMake(0, keysCount);
        CFArrayGetValues(keys, range, (const void **)pKeys);
        CFArrayGetValues(values, range, (const void **)pValues);
    }
    CFDictionaryRef dict = CFDictionaryCreate(kCFAllocatorDefault, (const void **)pKeys, (const void **)pValues, keysCount, KEY_CALLBACKS, VALUE_CALLBACKS);
    if (keysCount) {
        free(pKeys);
        free(pValues);
    }
    return dict;
}

static CFDictionaryRef PFDictionaryShallowCopyingValues(CFDictionaryRef dict, CFIndex count) {
    if (!count) count = CFDictionaryGetCount(dict);
    void **keys = malloc(count * sizeof(void *));
    void **values = malloc(count * sizeof(void *));
    CFDictionaryGetKeysAndValues(dict, (const void **)keys, (const void **)values);
    CFIndex c = count;
    id *ptr = (id *)values;
    while (c--) *ptr = [*ptr copy];
    CFDictionaryRef newDict = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, count, KEY_CALLBACKS, VALUE_CALLBACKS);
    free(keys);
    free(values);
    return newDict;
}


@implementation NSDictionary

#pragma mark - immutable factory methods

+ (id)dictionary {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, NULL, NULL) autorelease];
}

+ (id)dictionaryWithObject:(id)object forKey:(id)key {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, (const void **)&key, (const void **)&object, 1, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self dictionary];
    }
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    return [(id)dict autorelease];
}

+ (id)dictionaryWithDictionary:(NSDictionary *)dict {
    return [(id)CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)dict) autorelease];
}

+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    return [(id)PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects) autorelease];
}

// TODO:
// t +[NSDictionary dictionaryWithDictionary:copyItems:]
// t +[NSDictionary newDictionaryWithObjects:forKeys:count:]

#pragma mark - immutable init methods

- (id)init {
    free(self);
    return (id)CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, (const void**)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

- (id)initWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    return (id)dict;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    free(self);
    return (id)CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)otherDictionary);
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)copy {
    free(self);
    CFIndex count = CFDictionaryGetCount((CFDictionaryRef)otherDictionary);
    if (!count) {
        return (id)CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
    }
    if (!copy) {
        return (id)CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)otherDictionary);
    }
    return (id)PFDictionaryShallowCopyingValues((CFDictionaryRef)otherDictionary, count);
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    free(self);
    return (id)PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // PF_TODO
    free(self);
    return nil;
}

#pragma mark - instance method prototypes

- (NSUInteger)count { return 0; }
- (id)objectForKey:(id)aKey { return nil; }
- (NSEnumerator *)keyEnumerator { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (BOOL)supportsSecureCoding { return YES; }
- (void)encodeWithCoder:(NSCoder *)aCoder {}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len { return 0; }

@end


@implementation NSMutableDictionary

#pragma mark - mutable factory methods

+ (id)dictionary {
    return [(id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithCapacity:(NSUInteger)capacity {
    return [(id)CFDictionaryCreateMutable(kCFAllocatorDefault, capacity, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithObject:(id)object forKey:(id)key {
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
    CFDictionaryAddValue(dict, (const void *)key, (const void *)object);
    return [(id)dict autorelease];
}

+ (id)dictionaryWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    CFDictionaryRef dict = PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return [(id)mDict autorelease];
}

+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self init];
    }
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    CFDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return [(id)mDict autorelease];
}

+ (id)dictionaryWithDictionary:(NSDictionary *)dict {
    return [(id)CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)dict) autorelease];
}

+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    CFDictionaryRef dict = PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return [(id)mDict autorelease];
}

// TODO:
// t +[NSDictionary newDictionaryWithObjects:forKeys:count:]

#pragma mark - mutable initialisers

- (id)init {
    free(self);
    return (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFDictionaryCreateMutable(kCFAllocatorDefault, capacity, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    free(self);
    return (id)CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return (id)mDict;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    free(self);
    return (id)CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)otherDictionary);
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)copy {
    free(self);
    CFIndex count = CFDictionaryGetCount((CFDictionaryRef)otherDictionary);
    if (!count) {
        return (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
    }
    if (!copy) {
        return (id)CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)otherDictionary);
    }
    CFDictionaryRef dict = PFDictionaryShallowCopyingValues((CFDictionaryRef)otherDictionary, count);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return (id)mDict;
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    free(self);
    CFDictionaryRef dict = PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return (id)mDict;
}

#pragma mark - instance method prototypes

- (void)removeObjectForKey:(id)aKey {}
- (void)setObject:(id)anObject forKey:(id)aKey {}

@end


@interface __NSCFDictionary : NSMutableDictionary
@end

@implementation __NSCFDictionary

-(CFTypeID)_cfTypeID {
    return CFDictionaryGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)length {
    return _CFDictionaryFastEnumeration((CFDictionaryRef)self, state, stackbuf, length);
}

#pragma mark - instance methods

- (NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale {
    // PF_TODO
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    // PF_TODO
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionInStringsFileFormat {
    // PF_TODO
    return nil;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically {
    return PFPropertyListWriteToPath(SELF, (CFStringRef)path, atomically, NULL);
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
    return PFPropertyListWriteToURL(SELF, (CFURLRef)url, atomically, NULL);
}

#pragma mark - instance methods

- (NSUInteger)count {
    return CFDictionaryGetCount(SELF);
}

- (id)objectForKey:(id)aKey {
    return aKey ? (id)CFDictionaryGetValue(SELF, (const void *)aKey ) : nil;
}

// TODO: PFEnumerator should become NSEnumerator
- (NSEnumerator *)keyEnumerator {
//    return [[[PFEnumerator alloc] initWithCFDictionaryKeys: self] autorelease];
    // TODO: Implement with NSEnumerator
    return nil;
}

// TODO: PFEnumerator should become NSEnumerator
- (NSEnumerator *)objectEnumerator {
//    return [[[PFEnumerator alloc] initWithCFDictionaryValues: self] autorelease];
    // TODO: Implement with NSEnumerator
    return nil;
}

- (NSArray *)allKeys {
    CFIndex count = CFDictionaryGetCount(SELF);
    const void **keys = NULL;
    if (count) {
        keys = calloc(count, sizeof(void *));
        CFDictionaryGetKeysAndValues(SELF, keys, NULL);
    }
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, keys, count, ARRAY_CALLBACKS);
    if (keys) free(keys);
    return [(id)array autorelease];
}

- (NSArray *)allValues {
    CFIndex count = CFDictionaryGetCount(SELF);
    const void **values = NULL;
    if (count) {
        values = calloc(count, sizeof(void *));
        CFDictionaryGetKeysAndValues(SELF, NULL, values);
    }
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, values, count, ARRAY_CALLBACKS);
    if (values) free(values);
    return [(id)array autorelease];
}

- (NSArray *)allKeysForObject:(id)anObject {
    if (!anObject || !CFDictionaryGetCount(SELF)) {
        return [(id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS) autorelease];
    }
    _PFKeysForObject context = { anObject, CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS) };
    CFDictionaryApplyFunction(SELF, PFKeysForObject, &context);
    return [(id)context.array autorelease];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary {
    if (!otherDictionary) return NO;
    return (self == otherDictionary) || CFEqual((CFTypeRef)self, (CFTypeRef)otherDictionary);
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {
    NSUInteger count = [keys count];
    if (!count) return [NSArray array];
    
    // this is going to be inefficient, but it works for now
    id *buffer = calloc( count, sizeof(id) );
    id temp;
    
    for( id key in keys )
    {
        if( YES == CFDictionaryGetValueIfPresent( (CFDictionaryRef)self, key, (void *)&temp ) )
            *buffer++ = temp;
        else
            *buffer++ = marker;
    }
    
    buffer -= count;
    CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, &kCFTypeArrayCallBacks );
    free( buffer );
    return [(id)array autorelease];
}

/*
 *    "Returns an array of the receiver’s keys, in the order they would be in if the
 *    receiver were sorted by its values."
 *
 *    Hmm... split the dictionary out into two buffers. Run the compare function over
 *    the values, but apply the re-ordering to both keys and values?
 */
- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
    // PF_TODO
    return nil;
}

- (void)getObjects:(id *)objects andKeys:(id *)keys {
    CFDictionaryGetKeysAndValues(SELF, (const void **)keys, (const void **)objects);
}

#pragma mark - NSMutableDictionary instance methods

- (void)removeObjectForKey:(id)aKey {
    if (!aKey) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    CFDictionaryRemoveValue(MSELF, (const void *)aKey);
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    if (!anObject || !aKey) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    CFDictionarySetValue(MSELF, (const void *)aKey, (const void *)anObject);
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    NSUInteger count = [otherDictionary count];
    if (!count) return;
    
    NSEnumerator *keyEn = [otherDictionary keyEnumerator];
    NSEnumerator *valueEN = [otherDictionary objectEnumerator];
    
    for( id key in keyEn )
    {
        /*
         *    This is actually pretty risky. If the other dictionary is an NSCFDictionary
         *    then we can be fairly certain keys and values will appear in the same order.
         *    If it's any other kind of dictionary, then all bets are off.
         */
        CFDictionarySetValue( (CFMutableDictionaryRef)self, (const void *)key, (const void *)[valueEN nextObject] );
    }
}

- (void)removeAllObjects {
    CFDictionaryRemoveAllValues(MSELF);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    if( (CFDictionaryGetCount((CFDictionaryRef)self) == 0) || ([keyArray count] == 0) ) return;
    
    for( id key in keyArray )
        CFDictionaryRemoveValue( (CFMutableDictionaryRef)self, (const void *)key );
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    // docs say we should call [self removeAllObjects], but we won't
    CFDictionaryRemoveAllValues( (CFMutableDictionaryRef)self );
    
    CFIndex count = [otherDictionary count];
    if( count == 0 ) return;
    
    // enumerate over other dictionary and add in each key-value pair by hand
    NSEnumerator *keyEn = [otherDictionary keyEnumerator];
    NSEnumerator *valueEN = [otherDictionary objectEnumerator];
    
    // see addEntriesForDictionary: above for why this is bloody dangerous
    for( id key in keyEn )
        CFDictionaryAddValue( (CFMutableDictionaryRef)self, (const void *)key, (const void *)[valueEN nextObject] );
}

@end

#undef KEY_CALLBACKS
#undef VALUE_CALLBACKS
#undef ARRAY_CALLBACKS
#undef SELF
#undef MSELF


/*
    Implementation details
 
00000000005d6250 s _OBJC_IVAR_$___NSCFDictionary._bits
00000000005d6258 s _OBJC_IVAR_$___NSCFDictionary._callbacks
00000000005d6240 s _OBJC_IVAR_$___NSCFDictionary._cfinfo
00000000005d6268 s _OBJC_IVAR_$___NSCFDictionary._keys
00000000005d6248 s _OBJC_IVAR_$___NSCFDictionary._rc
00000000005d6260 s _OBJC_IVAR_$___NSCFDictionary._values

00000000005d7000 s _OBJC_METACLASS_$___NSDictionary0
00000000005d6f88 s _OBJC_METACLASS_$___NSDictionaryI
00000000005d8db0 s _OBJC_METACLASS_$___NSDictionaryM
00000000005d7a28 s _OBJC_METACLASS_$___NSDictionaryObjectEnumerator

00000000005d7028 s _OBJC_CLASS_$___NSDictionary0
00000000005d6f60 s _OBJC_CLASS_$___NSDictionaryI
00000000005d8d60 s _OBJC_CLASS_$___NSDictionaryM
00000000005d7a00 s _OBJC_CLASS_$___NSDictionaryObjectEnumerator

00000000005d61a8 s _OBJC_IVAR_$___NSDictionaryI._list
00000000005d61a0 s _OBJC_IVAR_$___NSDictionaryI._szidx
00000000005d6198 s _OBJC_IVAR_$___NSDictionaryI._used
00000000005d6c28 s _OBJC_IVAR_$___NSDictionaryM.cow
00000000005d6c20 s _OBJC_IVAR_$___NSDictionaryM.storage

blocks:
000000000000a420 t ___29+[__NSDictionaryM initialize]_block_invoke
0000000000136360 t ___30+[__NSDictionaryI __new::::::]_block_invoke
0000000000195340 t ___32-[NSDictionary __apply:context:]_block_invoke
00000000001e6750 t ___32-[__NSDictionaryM copyWithZone:]_block_invoke
0000000000138af0 t ___33+[__NSDictionary0 allocWithZone:]_block_invoke
00000000001e6780 t ___39-[__NSDictionaryM mutableCopyWithZone:]_block_invoke
00000000000c5b50 t ___45-[NSDictionary descriptionWithLocale:indent:]_block_invoke
0000000000195320 t ___47-[NSDictionary keysSortedByValueUsingSelector:]_block_invoke
0000000000195090 t ___50-[NSDictionary keyOfEntryWithOptions:passingTest:]_block_invoke
0000000000098650 t ___53-[NSDictionary keysOfEntriesWithOptions:passingTest:]_block_invoke
0000000000135b00 t ___53-[__NSDictionaryI keyOfEntryWithOptions:passingTest:]_block_invoke
0000000000135e60 t ___56-[__NSDictionaryI keysOfEntriesWithOptions:passingTest:]_block_invoke
00000000001e6510 t ___56-[__NSDictionaryM removeEntriesWithOptions:passingTest:]_block_invoke
0000000000195210 t ___61-[NSDictionary keysSortedByValueWithOptions:usingComparator:]_block_invoke
0000000000089680 t ___65-[__NSDictionaryI enumerateKeysAndObjectsWithOptions:usingBlock:]_block_invoke
0000000000163a50 t ___60-[NSMutableDictionary removeEntriesWithOptions:passingTest:]_block_invoke

00000000001543c0 t _____NSDictionaryEnumerate_block_invoke
00000000001545c0 t _____NSDictionaryEnumerate_block_invoke.13

00000000005ddbe8 D ___NSDictionary0__
000000000023c800 s ___NSDictionaryCapacities
00000000003ab260 s ___NSDictionaryCapacities
000000000007f740 t ___NSDictionaryEnumerate
00000000005dd9b8 d ___NSDictionaryM_DeletedMarker
0000000000154350 t ___NSDictionaryParameterCheckIterate
000000000023c6b0 s ___NSDictionarySizes
00000000003ab3a0 s ___NSDictionarySizes
00000000005df6a8 d ___NSDictionary_cowCallbacks

0000000000007c60 t +[__NSDictionary0 _alloc]
0000000000138aa0 t +[__NSDictionary0 allocWithZone:]
00000000001360f0 t +[__NSDictionaryI __new::::::]
00000000001360d0 t +[__NSDictionaryI allocWithZone:]
00000000001358a0 t +[__NSDictionaryI automaticallyNotifiesObserversForKey:]
000000000000a450 t +[__NSDictionaryM __new:::::]
00000000001e6730 t +[__NSDictionaryM allocWithZone:]
0000000000109720 t +[__NSDictionaryM automaticallyNotifiesObserversForKey:]
000000000000a3f0 t +[__NSDictionaryM initialize]

0000000000007d30 t -[__NSDictionary0 _init]
0000000000095450 t -[__NSDictionary0 autorelease]
00000000000dd9c0 t -[__NSDictionary0 copyWithZone:]
00000000000ae100 t -[__NSDictionary0 copy]
0000000000077f00 t -[__NSDictionary0 count]
0000000000138b20 t -[__NSDictionary0 dealloc]
0000000000095460 t -[__NSDictionary0 getObjects:andKeys:count:]
0000000000138b10 t -[__NSDictionary0 init]
0000000000077f10 t -[__NSDictionary0 keyEnumerator]
0000000000138b40 t -[__NSDictionary0 objectEnumerator]
0000000000078330 t -[__NSDictionary0 objectForKey:]
0000000000078040 t -[__NSDictionary0 release]
0000000000138b30 t -[__NSDictionary0 retainCount]
00000000000779e0 t -[__NSDictionary0 retain]
00000000000627e0 t -[__NSDictionaryI __apply:context:]
0000000000136520 t -[__NSDictionaryI _clumpingFactor]
00000000001367d0 t -[__NSDictionaryI _clumpingInterestingThreshold]
0000000000078460 t -[__NSDictionaryI copyWithZone:]
00000000000846a0 t -[__NSDictionaryI countByEnumeratingWithState:objects:count:]
000000000000e030 t -[__NSDictionaryI count]
000000000005c560 t -[__NSDictionaryI dealloc]
0000000000089500 t -[__NSDictionaryI enumerateKeysAndObjectsWithOptions:usingBlock:]
000000000000e050 t -[__NSDictionaryI getObjects:andKeys:count:]
0000000000084650 t -[__NSDictionaryI keyEnumerator]
0000000000135940 t -[__NSDictionaryI keyOfEntryWithOptions:passingTest:]
0000000000135c60 t -[__NSDictionaryI keysOfEntriesWithOptions:passingTest:]
000000000008e710 t -[__NSDictionaryI mutableCopyWithZone:]
00000000000605a0 t -[__NSDictionaryI objectForKey:]
0000000000135fd0 t -[__NSDictionaryI objectForKeyedSubscript:]
00000000000a16e0 t -[__NSDictionaryM __apply:context:]
00000000000ac2a0 t -[__NSDictionaryM __setObject:forKey:]
00000000001e67b0 t -[__NSDictionaryM _clumpingFactor]
00000000001e6a10 t -[__NSDictionaryM _clumpingInterestingThreshold]
0000000000077880 t -[__NSDictionaryM _mutate]
0000000000077900 t -[__NSDictionaryM copyWithZone:]
0000000000077550 t -[__NSDictionaryM countByEnumeratingWithState:objects:count:]
0000000000045db0 t -[__NSDictionaryM count]
0000000000047c10 t -[__NSDictionaryM dealloc]
000000000007fbe0 t -[__NSDictionaryM enumerateKeysAndObjectsWithOptions:usingBlock:]
0000000000045eb0 t -[__NSDictionaryM getObjects:andKeys:count:]
0000000000077050 t -[__NSDictionaryM keyEnumerator]
00000000001e5d20 t -[__NSDictionaryM keyOfEntryWithOptions:passingTest:]
00000000001e5f60 t -[__NSDictionaryM keysOfEntriesWithOptions:passingTest:]
00000000000a7340 t -[__NSDictionaryM mutableCopyWithZone:]
0000000000045c00 t -[__NSDictionaryM objectForKey:]
00000000001e5ff0 t -[__NSDictionaryM objectForKeyedSubscript:]
00000000000779f0 t -[__NSDictionaryM removeAllObjects]
00000000001e6120 t -[__NSDictionaryM removeEntriesWithOptions:passingTest:]
00000000000916e0 t -[__NSDictionaryM removeObjectForKey:]
000000000000d6b0 t -[__NSDictionaryM setObject:forKey:]
00000000001e5940 t -[__NSDictionaryM setObject:forKeyedSubscript:]
0000000000109630 t -[__NSDictionaryM setObservationInfo:]
00000000000ed120 t -[__NSDictionaryObjectEnumerator nextObject]
*/

/*
00000000005d8d10 s _OBJC_CLASS_$___NSPlaceholderDictionary
00000000005d8d38 s _OBJC_METACLASS_$___NSPlaceholderDictionary

00000000001e5220 t +[__NSPlaceholderDictionary allocWithZone:]
000000000000db50 t +[__NSPlaceholderDictionary immutablePlaceholder]
000000000000a270 t +[__NSPlaceholderDictionary initialize]
000000000000a2f0 t +[__NSPlaceholderDictionary mutablePlaceholder]

00000000001e4e60 t -[__NSPlaceholderDictionary count]
00000000001e53a0 t -[__NSPlaceholderDictionary dealloc]
000000000000a350 t -[__NSPlaceholderDictionary initWithCapacity:]
000000000005bac0 t -[__NSPlaceholderDictionary initWithContentsOfFile:]
0000000000075a60 t -[__NSPlaceholderDictionary initWithContentsOfURL:]
00000000001e5230 t -[__NSPlaceholderDictionary initWithDictionary:copyItems:]
000000000000db60 t -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]
000000000000a300 t -[__NSPlaceholderDictionary init]
00000000001e4fe0 t -[__NSPlaceholderDictionary keyEnumerator]
00000000001e4f20 t -[__NSPlaceholderDictionary objectForKey:]
00000000001e5380 t -[__NSPlaceholderDictionary release]
00000000001e5160 t -[__NSPlaceholderDictionary removeObjectForKey:]
00000000001e5390 t -[__NSPlaceholderDictionary retainCount]
00000000001e5370 t -[__NSPlaceholderDictionary retain]
00000000001e50a0 t -[__NSPlaceholderDictionary setObject:forKey:]

000000000000a2a0 t ___39+[__NSPlaceholderDictionary initialize]_block_invoke
00000000001e5310 t ___58-[__NSPlaceholderDictionary initWithDictionary:copyItems:]_block_invoke
*/

/*
00000000005d93f0 S _OBJC_CLASS_$_NSSharedKeyDictionary
00000000005da070 S _OBJC_METACLASS_$_NSSharedKeyDictionary

00000000000ebf70 t +[NSSharedKeyDictionary sharedKeyDictionaryWithKeySet:]
00000000001cc970 t +[NSSharedKeyDictionary supportsSecureCoding]

00000000001cbff0 t -[NSSharedKeyDictionary classForCoder]
000000000010fa30 t -[NSSharedKeyDictionary copyWithZone:]
000000000011ada0 t -[NSSharedKeyDictionary countByEnumeratingWithState:objects:count:]
0000000000115ab0 t -[NSSharedKeyDictionary count]
00000000000ecfb0 t -[NSSharedKeyDictionary dealloc]
00000000001cc010 t -[NSSharedKeyDictionary encodeWithCoder:]
000000000010fb20 t -[NSSharedKeyDictionary enumerateKeysAndObjectsWithOptions:usingBlock:]
0000000000117510 t -[NSSharedKeyDictionary getObjects:andKeys:count:]
00000000001cc310 t -[NSSharedKeyDictionary initWithCoder:]
00000000000ebfb0 t -[NSSharedKeyDictionary initWithKeySet:]
00000000001cbdb0 t -[NSSharedKeyDictionary keyEnumerator]
00000000001cbfb0 t -[NSSharedKeyDictionary keySet]
00000000001cbfd0 t -[NSSharedKeyDictionary mutableCopyWithZone:]
00000000000ec4b0 t -[NSSharedKeyDictionary objectForKey:]
0000000000102420 t -[NSSharedKeyDictionary removeObjectForKey:]
00000000000ec080 t -[NSSharedKeyDictionary setObject:forKey:]

00000000005d68d8 s _OBJC_IVAR_$_NSSharedKeyDictionary._count
00000000005d68f0 s _OBJC_IVAR_$_NSSharedKeyDictionary._ifkIMP
00000000005d68e8 s _OBJC_IVAR_$_NSSharedKeyDictionary._keyMap
00000000005d6900 s _OBJC_IVAR_$_NSSharedKeyDictionary._mutations
00000000005d68e0 s _OBJC_IVAR_$_NSSharedKeyDictionary._sideDic
00000000005d68f8 s _OBJC_IVAR_$_NSSharedKeyDictionary._values

00000000001cc8b0 t ___39-[NSSharedKeyDictionary initWithCoder:]_block_invoke
000000000010fd30 t ___71-[NSSharedKeyDictionary enumerateKeysAndObjectsWithOptions:usingBlock:]_block_invoke
*/

/*
00000000005d8d88 s _OBJC_CLASS_$___NSFrozenDictionaryM
00000000005d8dd8 s _OBJC_METACLASS_$___NSFrozenDictionaryM

00000000001e7360 t +[__NSFrozenDictionaryM allocWithZone:]

00000000001e6cd0 t -[__NSFrozenDictionaryM __apply:context:]
00000000001e73d0 t -[__NSFrozenDictionaryM copyWithZone:]
00000000001e6da0 t -[__NSFrozenDictionaryM countByEnumeratingWithState:objects:count:]
00000000001e6a70 t -[__NSFrozenDictionaryM count]
00000000001e7380 t -[__NSFrozenDictionaryM dealloc]
00000000001e6e80 t -[__NSFrozenDictionaryM enumerateKeysAndObjectsWithOptions:usingBlock:]
00000000001e6a90 t -[__NSFrozenDictionaryM getObjects:andKeys:count:]
00000000001e6b80 t -[__NSFrozenDictionaryM keyEnumerator]
00000000001e7010 t -[__NSFrozenDictionaryM keyOfEntryWithOptions:passingTest:]
00000000001e7220 t -[__NSFrozenDictionaryM keysOfEntriesWithOptions:passingTest:]
00000000001e73f0 t -[__NSFrozenDictionaryM mutableCopyWithZone:]
00000000001e6bd0 t -[__NSFrozenDictionaryM objectForKey:]
00000000001e7260 t -[__NSFrozenDictionaryM objectForKeyedSubscript:]

00000000005d6c38 s _OBJC_IVAR_$___NSFrozenDictionaryM.cow
00000000005d6c30 s _OBJC_IVAR_$___NSFrozenDictionaryM.storage

00000000001e74d0 t ___45-[__NSFrozenDictionaryM mutableCopyWithZone:]_block_invoke
*/

/*
00000000005d7370 s _OBJC_CLASS_$___NSSingleEntryDictionaryI
00000000005d7398 s _OBJC_METACLASS_$___NSSingleEntryDictionaryI

000000000013d4f0 t +[__NSSingleEntryDictionaryI __new:::]
000000000013d680 t +[__NSSingleEntryDictionaryI allocWithZone:]
000000000013d670 t +[__NSSingleEntryDictionaryI automaticallyNotifiesObserversForKey:]

000000000013d330 t -[__NSSingleEntryDictionaryI __apply:context:]
000000000013d4d0 t -[__NSSingleEntryDictionaryI copyWithZone:]
000000000013d3c0 t -[__NSSingleEntryDictionaryI countByEnumeratingWithState:objects:count:]
000000000013d110 t -[__NSSingleEntryDictionaryI count]
000000000013d600 t -[__NSSingleEntryDictionaryI dealloc]
000000000013d450 t -[__NSSingleEntryDictionaryI enumerateKeysAndObjectsWithOptions:usingBlock:]
000000000013d2c0 t -[__NSSingleEntryDictionaryI getObjects:andKeys:count:]
000000000013d120 t -[__NSSingleEntryDictionaryI isEqualToDictionary:]
000000000013d220 t -[__NSSingleEntryDictionaryI keyEnumerator]
000000000013d6a0 t -[__NSSingleEntryDictionaryI mutableCopyWithZone:]
000000000013d270 t -[__NSSingleEntryDictionaryI objectEnumerator]
000000000013d1e0 t -[__NSSingleEntryDictionaryI objectForKey:]

00000000005d6230 s _OBJC_IVAR_$___NSSingleEntryDictionaryI._key
00000000005d6238 s _OBJC_IVAR_$___NSSingleEntryDictionaryI._obj
*/

/*
00000000005dd5a8 d ___NSAbbreviationDictionary_
*/
