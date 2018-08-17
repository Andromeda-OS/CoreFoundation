//
//  NSSet.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForFoundationOnly.h"
#import "PureFoundation.h"
#import "CFSet.h"

#define SET_CALLBACKS   (&_PFCollectionCallBacks)
#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)

static CFSetRef PFSetInitFromVAList(void *first, va_list args) {
    va_list dargs;
    va_copy(dargs, args);
    CFIndex count = 1;
    while (va_arg(dargs, void *)) count++;
    va_end(dargs);
    
    void **objects = NULL;
    if (count == 1) {
        objects = &first;
    } else {
        void **ptr = objects = malloc(count * sizeof(void *));
        *ptr++ = first;
        while ((*ptr++ = va_arg(args, void *))) {}
    }
    
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
    if (count > 1) free(objects);
    return set;
}

static CFSetRef PFSetShallowCopy(CFSetRef set, CFIndex count) {
    if (!count) count = CFSetGetCount(set);
    void **values = calloc(count, sizeof(void *));
    CFSetGetValues(set, (const void **)values);
    void **ptr = values;
    while (count--) {
        *ptr = [(id)*ptr copy];
        ptr++;
    }
    CFSetRef newSet = CFSetCreate(kCFAllocatorDefault, (const void **)values, count, SET_CALLBACKS);
    free(values);
    return newSet;
}

// Defined in CFSet.c
// state param was originally defined as struct __objcFastEnumerationStateEquivalent
CF_EXPORT unsigned long _CFSetFastEnumeration(CFTypeRef hc, NSFastEnumerationState *state, void *stackbuffer, unsigned long count);

@implementation NSSet

#pragma mark - immutable factory methods

// TODO:
// t +[NSSet newSetWithObjects:count:]
// t +[NSSet setWithArray:copyItems:]
// t +[NSSet setWithArray:range:]
// t +[NSSet setWithArray:range:copyItems:]
// t +[NSSet setWithOrderedSet:]
// t +[NSSet setWithOrderedSet:copyItems:]
// t +[NSSet setWithOrderedSet:range:]
// t +[NSSet setWithOrderedSet:range:copyItems:]
// t +[NSSet setWithSet:copyItems:]

+ (id)set {
    return [(id)CFSetCreate(kCFAllocatorDefault, NULL, 0, SET_CALLBACKS) autorelease];
}

+ (id)setWithObject:(id)object {
    return [(id)CFSetCreate(kCFAllocatorDefault, (const void **)&object, 1, SET_CALLBACKS) autorelease];
}

+ (id)setWithObjects:(const id *)objects count:(NSUInteger)count {
    return [(id)CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS) autorelease];
}

+ (id)setWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self set];
    }
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    return [(id)set autorelease];
}

+ (id)setWithSet:(NSSet *)set {
    return [(id)CFSetCreateCopy(kCFAllocatorDefault, (CFSetRef)set) autorelease];
}

+ (id)setWithArray:(NSArray *)array {
    // TODO: Can we make this more efficient?
    return [[[self alloc] initWithArray: array] autorelease];
}

#pragma mark - immutable init methods

// TODO:
// t -[NSSet initWithArray:copyItems:]
// t -[NSSet initWithArray:range:]
// t -[NSSet initWithArray:range:copyItems:]
// t -[NSSet initWithCoder:]
// t -[NSSet initWithObject:]
// t -[NSSet initWithOrderedSet:]
// t -[NSSet initWithOrderedSet:copyItems:]
// t -[NSSet initWithOrderedSet:range:]
// t -[NSSet initWithOrderedSet:range:copyItems:]

- (id)init {
    free(self);
    return (id)CFSetCreate(kCFAllocatorDefault, NULL, 0, SET_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    return (id)CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    return (id)set;
}

- (id)initWithSet:(NSSet *)set {
    free(self);
    return (id)CFSetCreateCopy(kCFAllocatorDefault, (CFSetRef)set);
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)copy {
    CFIndex count = CFSetGetCount((CFSetRef)set);
    if (!count) {
        return [self init];
    }
    if (!copy) {
        return [self initWithSet:set];
    }
    free(self);
    return (id)PFSetShallowCopy((CFSetRef)set, count);
}

- (id)initWithArray:(NSArray *)array {
    free(self);
    CFIndex count = CFArrayGetCount((CFArrayRef)array);
    if (!count) {
        return (id)CFSetCreate(kCFAllocatorDefault, NULL, 0, SET_CALLBACKS);
    }
    void *values = malloc(count * sizeof(void *));
    [array getObjects:values];
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)values, count, SET_CALLBACKS);
    free(values);
    return (id)set;
}

#pragma mark - instance method prototypes

// TODO: Write stubs for these
// t -[NSSet allObjects]
// t -[NSSet anyObject]
// t -[NSSet containsObject:]
// t -[NSSet countForObject:]
// t -[NSSet descriptionWithLocale:]
// t -[NSSet descriptionWithLocale:indent:]
// t -[NSSet description]
// t -[NSSet encodeWithCoder:]
// t -[NSSet enumerateObjectsUsingBlock:]
// t -[NSSet enumerateObjectsWithOptions:usingBlock:]
// t -[NSSet getObjects:]
// t -[NSSet getObjects:count:]
// t -[NSSet getObjects:range:]
// t -[NSSet intersectsOrderedSet:]
// t -[NSSet intersectsSet:]
// t -[NSSet isEqual:]
// t -[NSSet isEqualToSet:]
// t -[NSSet isNSSet__]
// t -[NSSet isSubsetOfOrderedSet:]
// t -[NSSet isSubsetOfSet:]
// t -[NSSet makeObjectsPerformSelector:]
// t -[NSSet makeObjectsPerformSelector:withObject:]
// t -[NSSet members:notFoundMarker:]
// t -[NSSet objectPassingTest:]
// t -[NSSet objectWithOptions:passingTest:]
// t -[NSSet objectsPassingTest:]
// t -[NSSet objectsWithOptions:passingTest:]
// t -[NSSet setByAddingObject:]
// t -[NSSet setByAddingObjectsFromArray:]
// t -[NSSet setByAddingObjectsFromSet:]
// t -[NSSet sortedArrayUsingComparator:]
// t -[NSSet sortedArrayWithOptions:usingComparator:]

- (NSUInteger)count { return 0; }
- (id)member:(id)object { return nil; }
- (NSEnumerator *)objectEnumerator { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len { return 0; }

@end


/*

*/

@implementation NSMutableSet

#pragma mark - mutable factory methods

// TODO:
// t +[NSSet newSetWithObjects:count:]
// t +[NSSet setWithArray:copyItems:]
// t +[NSSet setWithArray:range:]
// t +[NSSet setWithArray:range:copyItems:]
// t +[NSSet setWithOrderedSet:]
// t +[NSSet setWithOrderedSet:copyItems:]
// t +[NSSet setWithOrderedSet:range:]
// t +[NSSet setWithOrderedSet:range:copyItems:]
// t +[NSSet setWithSet:copyItems:]

+ (id)set {
    return [(id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS) autorelease];
}

+ (id)setWithCapacity:(NSUInteger)capacity {
    return [(id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS) autorelease];
}

+ (id)setWithObject:(id)object {
    CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    CFSetAddValue(set, object);
    return [(id)set autorelease];
}

+ (id)setWithObjects:(const id *)objects count:(NSUInteger)count {
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

+ (id)setWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self set];
    }
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, 0, set);
    CFRelease(self);
    return [(id)mSet autorelease];
}

+ (id)setWithSet:(NSSet *)set {
    return [(id)CFSetCreateMutableCopy(kCFAllocatorDefault, 0, (CFSetRef)set) autorelease];
}

+ (id)setWithArray:(NSArray *)array {
    NSUInteger count = [array count];
    if (!count) {
        return [(id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS) autorelease];
    }
    void **values = malloc(count * sizeof(void *));
    [array getObjects:(id *)values];
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)values, count, SET_CALLBACKS);
    free(values);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

#pragma mark - mutable init methods

// TODO:
// t -[NSSet initWithArray:copyItems:]
// t -[NSSet initWithArray:range:]
// t -[NSSet initWithArray:range:copyItems:]
// t -[NSSet initWithCoder:]
// t -[NSSet initWithObject:]
// t -[NSSet initWithOrderedSet:]
// t -[NSSet initWithOrderedSet:copyItems:]
// t -[NSSet initWithOrderedSet:range:]
// t -[NSSet initWithOrderedSet:range:copyItems:]

- (id)init {
    free(self);
    return (id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return (id)mSet;
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, 0, set);
    CFRelease(self);
    return (id)mSet;
}

- (id)initWithSet:(NSSet *)set {
    free(self);
    return (id)CFSetCreateMutableCopy(kCFAllocatorDefault, 0, (CFSetRef)set);
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)copy {
    CFIndex count = CFSetGetCount((CFSetRef)set);
    if (!count) {
        return [self init];
    }
    if (!copy) {
        return [self initWithSet:set];
    }
    free(self);
    CFSetRef newSet = PFSetShallowCopy((CFSetRef)set, count);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, newSet);
    CFRelease(newSet);
    return (id)mSet;
}

- (id)initWithArray:(NSArray *)array {
    free(self);
    NSUInteger count = [array count];
    if (!count) {
        return (id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    }
    void **values = malloc(count * sizeof(void *));
    [array getObjects:(id *)values];
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void**)values, count, SET_CALLBACKS);
    free(values);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return (id)mSet;
}

- (id)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFSetCreateMutable(kCFAllocatorDefault, capacity, SET_CALLBACKS);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // PF_TODO
    free(self);
    return nil;
}

#pragma mark - mutable instance method prototypes

// TODO: Stub these
// t -[NSMutableSet addObjects:count:]
// t -[NSMutableSet addObjectsFromArray:]
// t -[NSMutableSet addObjectsFromArray:range:]
// t -[NSMutableSet addObjectsFromOrderedSet:]
// t -[NSMutableSet addObjectsFromOrderedSet:range:]
// t -[NSMutableSet addObjectsFromSet:]
// t -[NSMutableSet intersectOrderedSet:]
// t -[NSMutableSet intersectSet:]
// t -[NSMutableSet minusOrderedSet:]
// t -[NSMutableSet minusSet:]
// t -[NSMutableSet removeAllObjects]
// t -[NSMutableSet removeObjectsInArray:]
// t -[NSMutableSet removeObjectsInArray:range:]
// t -[NSMutableSet removeObjectsInOrderedSet:]
// t -[NSMutableSet removeObjectsInOrderedSet:range:]
// t -[NSMutableSet removeObjectsInSet:]
// t -[NSMutableSet removeObjectsPassingTest:]
// t -[NSMutableSet removeObjectsWithOptions:passingTest:]
// t -[NSMutableSet replaceObject:]
// t -[NSMutableSet setArray:]
// t -[NSMutableSet setObject:]
// t -[NSMutableSet setOrderedSet:]
// t -[NSMutableSet setSet:]
// t -[NSMutableSet unionOrderedSet:]
// t -[NSMutableSet unionSet:]

- (void)addObject:(id)object { }
- (void)removeObject:(id)object { }

@end

#define SELF ((CFSetRef)self)
#define MSELF ((CFMutableSetRef)self)

@interface __NSCFSet : NSMutableSet
@end

@implementation __NSCFSet

// TODO:
//00000000000e5370 t -[NSSet enumerateObjectsUsingBlock:]
//000000000011f370 t -[NSSet enumerateObjectsWithOptions:usingBlock:]
//00000000001e9360 t +[__NSCFSet automaticallyNotifiesObserversForKey:]
//0000000000101060 t -[__NSCFSet getObjects:]
//0000000000095a00 t -[NSSet getObjects:count:]
//000000000019e190 t -[NSSet getObjects:range:]
//000000000007d710 t -[NSSet countForObject:]
//00000000000e4470 t -[NSSet descriptionWithLocale:indent:]
//000000000019e250 t -[NSSet intersectsOrderedSet:]
//000000000007d610 t -[NSSet isNSSet__]
//000000000019e420 t -[NSSet isSubsetOfOrderedSet:]
//000000000019e620 t -[NSSet members:notFoundMarker:]
//000000000019ea60 t -[NSSet objectPassingTest:]
//000000000019e8f0 t -[NSSet objectWithOptions:passingTest:]
//00000000000a3ca0 t -[NSSet objectsPassingTest:]
//00000000000a3d20 t -[NSSet objectsWithOptions:passingTest:]
//000000000019eee0 t -[NSSet sortedArrayUsingComparator:]
//000000000019eb50 t -[NSSet sortedArrayWithOptions:usingComparator:]
//0000000000122a20 t -[NSMutableSet addObjects:count:]
//0000000000122b30 t -[NSMutableSet addObjectsFromArray:range:]
//0000000000122f70 t -[NSMutableSet addObjectsFromOrderedSet:]
//0000000000122d50 t -[NSMutableSet addObjectsFromOrderedSet:range:]
//0000000000123120 t -[NSMutableSet addObjectsFromSet:]
//0000000000123460 t -[NSMutableSet intersectOrderedSet:]
//00000000001239d0 t -[NSMutableSet minusOrderedSet:]
//0000000000123d60 t -[NSMutableSet removeObjectsInArray:]
//0000000000123bf0 t -[NSMutableSet removeObjectsInArray:range:]
//0000000000124080 t -[NSMutableSet removeObjectsInOrderedSet:]
//0000000000123f10 t -[NSMutableSet removeObjectsInOrderedSet:range:]
//0000000000124230 t -[NSMutableSet removeObjectsInSet:]
//00000000001248e0 t -[NSMutableSet removeObjectsPassingTest:]
//00000000001245c0 t -[NSMutableSet removeObjectsWithOptions:passingTest:]
//0000000000124920 t -[NSMutableSet replaceObject:]
//0000000000124ab0 t -[NSMutableSet setArray:]
//00000000001249f0 t -[NSMutableSet setObject:]
//0000000000124c70 t -[NSMutableSet setOrderedSet:]
//0000000000124ea0 t -[NSMutableSet unionOrderedSet:]

- (CFTypeID)_cfTypeID {
    return CFSetGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)_CFNonObjCRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { _CFNonObjCRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return _CFNonObjCHash((CFTypeRef)self); }
- (BOOL)isEqual:(id)object {
    return object && _CFNonObjCEqual((CFTypeRef)self, (CFTypeRef)object);
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)length {
    return _CFSetFastEnumeration(SELF, state, state, length);
}

-(NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale {
    // PF_TODO
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSUInteger)count {
    return CFSetGetCount(SELF);
}

- (id)member:(id)object {
    return object ? (id)CFSetGetValue(SELF, (const void *)object) : nil;
}

- (NSEnumerator *)objectEnumerator {
    // TODO: Implement when we have NSEnumerator
    return nil;
}

- (NSArray *)allObjects {
    CFIndex count = CFSetGetCount(SELF);
    void **values = NULL;
    if (count) {
        values = malloc(count * sizeof(void *));
        CFSetGetValues(SELF, (const void **)values);
    }
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    if (count) free(values);
    return [(id)array autorelease];
}

- (id)anyObject {
    // TODO: See if there's a better way of doing this. Maybe implement in CF.
    NSUInteger count = CFSetGetCount((CFSetRef)self);
    if (!count) return nil;
    void *objects = malloc(count * sizeof(void *));
    CFSetGetValues((CFSetRef)self, (const void **)objects);
    id randomishObject = *(id *)objects;
    free(objects);
    return randomishObject;
}

- (BOOL)containsObject:(id)anObject {
    return anObject ? CFSetContainsValue(SELF, (const void *)anObject) : NO;
}

- (BOOL)isEqualToSet:(NSSet *)otherSet {
    if (!otherSet) return NO;
    return (self == otherSet) || CFEqual((CFTypeRef)self, (CFTypeRef)otherSet);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    if (!aSelector) return;
    for (id object in self) {
        [object performSelector:aSelector];
    }
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    if (!aSelector) return;
    for (id object in self) {
        [object performSelector:aSelector withObject:argument];
    }
}

- (BOOL)intersectsSet:(NSSet *)otherSet {
    // TODO: Check the logic used here
    if (!otherSet || ![otherSet count] || !CFSetGetCount(SELF)) {
        return NO;
    }
    for (id object in otherSet) {
        if (CFSetContainsValue(SELF, (const void *)object)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSubsetOfSet:(NSSet *)otherSet {
    for (id object in self) {
        if (!CFSetContainsValue((CFSetRef)otherSet, (const void *)object)) {
            return NO;
        }
    }
    return YES;
}

- (NSSet *)setByAddingObject:(id)anObject {
    CFMutableSetRef set = CFSetCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    if (anObject) {
        CFSetAddValue(set, (const void *)anObject);
    }
    return [(id)set autorelease];
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other {
    CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    for (id object in other) {
        CFSetAddValue(set, (const void *)object);
    }
    return [(id)set autorelease];
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other {
    CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    for (id object in other) {
        CFSetAddValue(set, (const void *)object);
    }
    return [(id)set autorelease];
}

- (void)addObject:(id)object {
    if (!object) return;
    CFSetAddValue(MSELF, (const void*)object);
}

- (void)removeObject:(id)object {
    if (!object) return;
    CFSetRemoveValue(MSELF, (const void*)object);
}

- (void)removeAllObjects {
    CFSetRemoveAllValues(MSELF);
}

- (void)addObjectsFromArray:(NSArray *)array {
    for (id object in array) {
        CFSetAddValue(MSELF, (const void *)object);
    }
}

- (void)setSet:(NSSet *)otherSet {
    CFSetRemoveAllValues(MSELF);
    for (id object in otherSet) {
        CFSetAddValue(MSELF, (const void *)object);
    }
}

- (void)intersectSet:(NSSet *)otherSet {
    // TODO: Check logic here
    if (!otherSet || ![otherSet count]) {
        CFSetRemoveAllValues(MSELF);
        return;
    }
    CFMutableSetRef mSet = CFSetCreateMutable(kCFAllocatorDefault, 0, NULL);
    // find all of the objects which are in self but not otherSet...
    for (id object in self) {
        if (![otherSet containsObject:object]) {
            CFSetAddValue(mSet, (const void *)object);
        }
    }
    // ...and then remove them
    for (id object in (NSSet *)mSet) {
        CFSetRemoveValue(MSELF, (const void *)object);
    }
    CFRelease(mSet);
}

- (void)minusSet:(NSSet *)otherSet {
    // TODO: Check logic here
    if (!otherSet || ![otherSet count] || !CFSetGetCount(SELF)) return;
    for (id object in otherSet) {
        CFSetRemoveValue(MSELF, (const void *)object);
    }
}

- (void)unionSet:(NSSet *)otherSet {
    // TODO: Check logic here
    if (!otherSet || ![otherSet count]) return;
    for (id object in otherSet) {
        CFSetAddValue(MSELF, (const void *)object);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [(id)CFSetCreateCopy(kCFAllocatorDefault, SELF) autorelease];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [(id)CFSetCreateMutableCopy(kCFAllocatorDefault, 0, SELF) autorelease];
}

@end



#undef SELF
#undef MSELF

/*
00000000005d7be0 s _OBJC_CLASS_$___NSSetI
00000000005d8310 s _OBJC_CLASS_$___NSSetM
00000000005d7c08 s _OBJC_METACLASS_$___NSSetI
00000000005d8360 s _OBJC_METACLASS_$___NSSetM

00000000005d6418 s _OBJC_IVAR_$___NSSetI._list
00000000005d6410 s _OBJC_IVAR_$___NSSetI._szidx
00000000005d6408 s _OBJC_IVAR_$___NSSetI._used
00000000005d6740 s _OBJC_IVAR_$___NSSetM.cow
00000000005d6738 s _OBJC_IVAR_$___NSSetM.storage


0000000000158e10 t +[__NSSetI __new::::]
0000000000159200 t +[__NSSetI allocWithZone:]
0000000000158a40 t +[__NSSetI automaticallyNotifiesObserversForKey:]
0000000000047f90 t +[__NSSetM __new:::]
000000000019fd70 t +[__NSSetM allocWithZone:]
000000000019faa0 t +[__NSSetM automaticallyNotifiesObserversForKey:]
0000000000047f30 t +[__NSSetM initialize]

0000000000158a50 t -[__NSSetI clumpingFactor]
0000000000158d00 t -[__NSSetI clumpingInterestingThreshold]
00000000000b9440 t -[__NSSetI copyWithZone:]
000000000007d770 t -[__NSSetI countByEnumeratingWithState:objects:count:]
000000000007d620 t -[__NSSetI count]
000000000008f380 t -[__NSSetI dealloc]
0000000000100c10 t -[__NSSetI enumerateObjectsWithOptions:usingBlock:]
000000000007d640 t -[__NSSetI getObjects:count:]
0000000000076f70 t -[__NSSetI member:]
00000000000e4d30 t -[__NSSetI objectEnumerator]
000000000007d590 t -[__NSSetM _mutate]
0000000000048210 t -[__NSSetM addObject:]
000000000019fab0 t -[__NSSetM clumpingFactor]
000000000019fd10 t -[__NSSetM clumpingInterestingThreshold]
00000000000ad940 t -[__NSSetM copyWithZone:]
00000000000848f0 t -[__NSSetM countByEnumeratingWithState:objects:count:]
0000000000077f20 t -[__NSSetM count]
0000000000077f70 t -[__NSSetM dealloc]
00000000000e53f0 t -[__NSSetM enumerateObjectsWithOptions:usingBlock:]
0000000000089890 t -[__NSSetM getObjects:count:]
000000000007edd0 t -[__NSSetM member:]
000000000019fe60 t -[__NSSetM mutableCopyWithZone:]
00000000000e47d0 t -[__NSSetM objectEnumerator]
00000000000a0510 t -[__NSSetM removeAllObjects]
00000000000537d0 t -[__NSSetM removeObject:]

00000000005d6c50 s _OBJC_IVAR_$___NSCFSet._bits
00000000005d6c58 s _OBJC_IVAR_$___NSCFSet._callbacks
00000000005d6c40 s _OBJC_IVAR_$___NSCFSet._cfinfo
00000000005d6c48 s _OBJC_IVAR_$___NSCFSet._rc
00000000005d6c60 s _OBJC_IVAR_$___NSCFSet._values

00000000005d7230 s _OBJC_CLASS_$___NSPlaceholderSet
00000000005d7258 s _OBJC_METACLASS_$___NSPlaceholderSet


0000000000139e50 t -[__NSPlaceholderSet addObject:]
0000000000139c10 t -[__NSPlaceholderSet count]
000000000013a150 t -[__NSPlaceholderSet dealloc]
0000000000047ea0 t -[__NSPlaceholderSet initWithCapacity:]
0000000000075760 t -[__NSPlaceholderSet initWithObjects:count:]
0000000000139fe0 t -[__NSPlaceholderSet initWithSet:copyItems:]
000000000004b7d0 t -[__NSPlaceholderSet init]
0000000000139cd0 t -[__NSPlaceholderSet member:]
0000000000139d90 t -[__NSPlaceholderSet objectEnumerator]
000000000013a130 t -[__NSPlaceholderSet release]
0000000000139f10 t -[__NSPlaceholderSet removeObject:]
000000000013a140 t -[__NSPlaceholderSet retainCount]
000000000013a120 t -[__NSPlaceholderSet retain]

0000000000047e20 t ___32+[__NSPlaceholderSet initialize]_block_invoke
000000000013a0c0 t ___44-[__NSPlaceholderSet initWithSet:copyItems:]_block_invoke

00000000001590b0 t ___21+[__NSSetI __new::::]_block_invoke
0000000000047f60 t ___22+[__NSSetM initialize]_block_invoke
000000000019fe30 t ___25-[__NSSetM copyWithZone:]_block_invoke
000000000019ff60 t ___32-[__NSSetM mutableCopyWithZone:]_block_invoke
000000000019e9d0 t ___39-[NSSet objectWithOptions:passingTest:]_block_invoke
00000000000a42c0 t ___40-[NSSet objectsWithOptions:passingTest:]_block_invoke
000000000019ee80 t ___48-[NSSet sortedArrayWithOptions:usingComparator:]_block_invoke
0000000000102390 t ___51-[__NSSetI enumerateObjectsWithOptions:usingBlock:]_block_invoke

00000000005dc238 d ___NSSet0__
000000000029a670 s ___NSSetCapacities
0000000000351c30 s ___NSSetCapacities
00000000000a3ea0 t ___NSSetEnumerate
00000000005dd368 d ___NSSetM_DeletedMarker
000000000029a520 s ___NSSetSizes
0000000000351d70 s ___NSSetSizes
00000000005df4c0 d ___NSSet_cowCallbacks

000000000019dd90 t ____NSSetDeallocHandler_block_invoke
0000000000138c90 t _____NSSetEnumerate_block_invoke
0000000000138e50 t _____NSSetEnumerate_block_invoke.8
0000000000124820 t ___53-[NSMutableSet removeObjectsWithOptions:passingTest:]_block_invoke


0000000000139fd0 t +[__NSPlaceholderSet allocWithZone:]
00000000000758d0 t +[__NSPlaceholderSet immutablePlaceholder]
0000000000047df0 t +[__NSPlaceholderSet initialize]
0000000000047e90 t +[__NSPlaceholderSet mutablePlaceholder]
*/

/*
00000000005d9418 S _OBJC_CLASS_$_NSSharedKeySet
00000000005da098 S _OBJC_METACLASS_$_NSSharedKeySet
00000000005da340 S _OBJC_METACLASS_$__NSSharedKeySetS

00000000000e9fa0 t +[NSSharedKeySet keySetWithKeys:]
00000000001ccc70 t +[NSSharedKeySet supportsSecureCoding]

00000000001ce7d0 t -[NSSharedKeySet M]
00000000001cd960 t -[NSSharedKeySet allKeys]
00000000001cc9a0 t -[NSSharedKeySet copyWithZone:]
00000000001cdb30 t -[NSSharedKeySet countByEnumeratingWithState:objects:count:]
00000000000ec040 t -[NSSharedKeySet count]
00000000001ce0b0 t -[NSSharedKeySet dealloc]
00000000001ce1f0 t -[NSSharedKeySet debugDescription]
00000000001cc9c0 t -[NSSharedKeySet encodeWithCoder:]
00000000001ce7e0 t -[NSSharedKeySet factor]
00000000001ce770 t -[NSSharedKeySet g]
00000000001cdbf0 t -[NSSharedKeySet hash]
00000000000ec1f0 t -[NSSharedKeySet indexForKey:]
00000000001ccc80 t -[NSSharedKeySet initWithCoder:]
00000000000ea220 t -[NSSharedKeySet initWithKeys:count:]
00000000000e9730 t -[NSSharedKeySet init]
00000000000ebf50 t -[NSSharedKeySet isEmpty]
00000000001cdc10 t -[NSSharedKeySet isEqual:]
000000000010fde0 t -[NSSharedKeySet keyAtIndex:]
00000000001ce1b0 t -[NSSharedKeySet keySetCount]
00000000001ce820 t -[NSSharedKeySet keys]
00000000001cd940 t -[NSSharedKeySet maximumIndex]
00000000001ce7f0 t -[NSSharedKeySet numKey]
00000000001ce7b0 t -[NSSharedKeySet rankTable]
00000000001ce800 t -[NSSharedKeySet seeds]
00000000001ce790 t -[NSSharedKeySet select]
00000000000e9770 t -[NSSharedKeySet setFactor:]
00000000000e97b0 t -[NSSharedKeySet setG:]
00000000000e97f0 t -[NSSharedKeySet setKeys:]
00000000000e9760 t -[NSSharedKeySet setM:]
00000000000e9780 t -[NSSharedKeySet setNumKey:]
00000000000e97d0 t -[NSSharedKeySet setRankTable:]
00000000000e9790 t -[NSSharedKeySet setSeeds:]
00000000000e9750 t -[NSSharedKeySet setSelect:]
00000000000e9810 t -[NSSharedKeySet setSubSharedKeySet:]
00000000001ce840 t -[NSSharedKeySet subSharedKeySet]

000000000018ed20 t ___24-[_NSSharedKeySetS hash]_block_invoke
00000000001cd880 t ___32-[NSSharedKeySet initWithCoder:]_block_invoke

00000000005d96c0 S _OBJC_CLASS_$__NSSharedKeySetS


000000000018f490 t -[_NSSharedKeySetS M]
000000000018e420 t -[_NSSharedKeySetS allKeys]
000000000018ea50 t -[_NSSharedKeySetS bytesAtIndex:]
000000000018f470 t -[_NSSharedKeySetS c]
000000000018f560 t -[_NSSharedKeySetS ckeys]
000000000018e380 t -[_NSSharedKeySetS copyWithZone:]
000000000018e3a0 t -[_NSSharedKeySetS count]
000000000018f2d0 t -[_NSSharedKeySetS dealloc]
000000000018f4a0 t -[_NSSharedKeySetS factor]
000000000018f410 t -[_NSSharedKeySetS g]
000000000018eab0 t -[_NSSharedKeySetS hash]
00000000001167c0 t -[_NSSharedKeySetS indexForBytes:length:]
00000000001163e0 t -[_NSSharedKeySetS indexForKey:length:]
00000000001112c0 t -[_NSSharedKeySetS initWithKeys:keyLenghtInBytes:count:type:]
00000000001112a0 t -[_NSSharedKeySetS init]
000000000018e3e0 t -[_NSSharedKeySetS isEmpty]
000000000018ed40 t -[_NSSharedKeySetS isEqual:]
000000000018e9a0 t -[_NSSharedKeySetS keyAtIndex:]
000000000018f5a0 t -[_NSSharedKeySetS keyLen]
000000000018f3e0 t -[_NSSharedKeySetS keySetCount]
000000000018f4e0 t -[_NSSharedKeySetS keys1]
000000000018f500 t -[_NSSharedKeySetS keys2]
000000000018f520 t -[_NSSharedKeySetS keys3]
000000000018e400 t -[_NSSharedKeySetS maximumIndex]
000000000018e570 t -[_NSSharedKeySetS newKeySetWithKeys:encoding:]
000000000018f4b0 t -[_NSSharedKeySetS numKey]
000000000018f450 t -[_NSSharedKeySetS rankTable]
000000000018f4c0 t -[_NSSharedKeySetS seeds]
000000000018f430 t -[_NSSharedKeySetS select]
0000000000112ff0 t -[_NSSharedKeySetS setC:]
0000000000113c20 t -[_NSSharedKeySetS setCkeys:]
0000000000113020 t -[_NSSharedKeySetS setFactor:]
0000000000113060 t -[_NSSharedKeySetS setG:]
00000000001130c0 t -[_NSSharedKeySetS setKeyLen:]
00000000001130a0 t -[_NSSharedKeySetS setKeys1:]
00000000001134b0 t -[_NSSharedKeySetS setKeys2:]
000000000018f540 t -[_NSSharedKeySetS setKeys3:]
0000000000113010 t -[_NSSharedKeySetS setM:]
0000000000113030 t -[_NSSharedKeySetS setNumKey:]
0000000000113080 t -[_NSSharedKeySetS setRankTable:]
0000000000113040 t -[_NSSharedKeySetS setSeeds:]
0000000000112fe0 t -[_NSSharedKeySetS setSelect:]
00000000001130e0 t -[_NSSharedKeySetS setSubSharedKeySet:]
00000000001130d0 t -[_NSSharedKeySetS setType:]
000000000018f580 t -[_NSSharedKeySetS subSharedKeySet]
000000000018f5b0 t -[_NSSharedKeySetS type]

00000000005d6950 s _OBJC_IVAR_$_NSSharedKeySet._M
00000000005d6910 s _OBJC_IVAR_$_NSSharedKeySet._algorithmType
00000000005d6928 s _OBJC_IVAR_$_NSSharedKeySet._factor
00000000005d6938 s _OBJC_IVAR_$_NSSharedKeySet._g
00000000005d6918 s _OBJC_IVAR_$_NSSharedKeySet._keys
00000000005d6908 s _OBJC_IVAR_$_NSSharedKeySet._numKey
00000000005d6930 s _OBJC_IVAR_$_NSSharedKeySet._rankTable
00000000005d6920 s _OBJC_IVAR_$_NSSharedKeySet._seeds
00000000005d6940 s _OBJC_IVAR_$_NSSharedKeySet._select
00000000005d6948 s _OBJC_IVAR_$_NSSharedKeySet._subSharedKeySet

00000000005d65d8 s _OBJC_IVAR_$__NSSharedKeySetS._M
00000000005d65e0 s _OBJC_IVAR_$__NSSharedKeySetS._c
00000000005d65c8 s _OBJC_IVAR_$__NSSharedKeySetS._ckeys
00000000005d65a8 s _OBJC_IVAR_$__NSSharedKeySetS._factor
00000000005d65b8 s _OBJC_IVAR_$__NSSharedKeySetS._g
00000000005d6578 s _OBJC_IVAR_$__NSSharedKeySetS._keyLen
00000000005d6588 s _OBJC_IVAR_$__NSSharedKeySetS._keys1
00000000005d6590 s _OBJC_IVAR_$__NSSharedKeySetS._keys2
00000000005d6598 s _OBJC_IVAR_$__NSSharedKeySetS._keys3
00000000005d6570 s _OBJC_IVAR_$__NSSharedKeySetS._numKey
00000000005d65b0 s _OBJC_IVAR_$__NSSharedKeySetS._rankTable
00000000005d65a0 s _OBJC_IVAR_$__NSSharedKeySetS._seeds
00000000005d65c0 s _OBJC_IVAR_$__NSSharedKeySetS._select
00000000005d65d0 s _OBJC_IVAR_$__NSSharedKeySetS._subSharedKeySet
00000000005d6580 s _OBJC_IVAR_$__NSSharedKeySetS._type

00000000001f51a0 s __NSSharedKeySetS_g
000000000020b4b0 s __NSSharedKeySetS_g
000000000021cfc0 s __NSSharedKeySetS_g
00000000002294e0 s __NSSharedKeySetS_g
000000000023c950 s __NSSharedKeySetS_g
0000000000249e00 s __NSSharedKeySetS_g
0000000000257e10 s __NSSharedKeySetS_g
000000000026b1c0 s __NSSharedKeySetS_g
0000000000281600 s __NSSharedKeySetS_g
000000000028adc0 s __NSSharedKeySetS_g
000000000028b970 s __NSSharedKeySetS_g
000000000029a7c0 s __NSSharedKeySetS_g
00000000002a7710 s __NSSharedKeySetS_g
00000000002fb3d0 s __NSSharedKeySetS_g
0000000000309520 s __NSSharedKeySetS_g
0000000000312bb0 s __NSSharedKeySetS_g
00000000003214e0 s __NSSharedKeySetS_g
0000000000332ff0 s __NSSharedKeySetS_g
00000000003464e0 s __NSSharedKeySetS_g
0000000000349930 s __NSSharedKeySetS_g
0000000000351220 s __NSSharedKeySetS_g
0000000000352c90 s __NSSharedKeySetS_g
000000000035a410 s __NSSharedKeySetS_g
0000000000368d80 s __NSSharedKeySetS_g
000000000037f9b0 s __NSSharedKeySetS_g
000000000038e290 s __NSSharedKeySetS_g
00000000003940e0 s __NSSharedKeySetS_g
0000000000394110 s __NSSharedKeySetS_g
00000000003ab560 s __NSSharedKeySetS_g
00000000003c0ff8 s __NSSharedKeySetS_g
0000000000203880 s __NSSharedKeySetS_keys
0000000000216250 s __NSSharedKeySetS_keys
0000000000224db0 s __NSSharedKeySetS_keys
0000000000234730 s __NSSharedKeySetS_keys
00000000002450e0 s __NSSharedKeySetS_keys
0000000000252440 s __NSSharedKeySetS_keys
0000000000263ae0 s __NSSharedKeySetS_keys
0000000000279120 s __NSSharedKeySetS_keys
0000000000286c00 s __NSSharedKeySetS_keys
000000000028b4f0 s __NSSharedKeySetS_keys
0000000000294540 s __NSSharedKeySetS_keys
00000000002a2720 s __NSSharedKeySetS_keys
00000000002ad090 s __NSSharedKeySetS_keys
0000000000302de0 s __NSSharedKeySetS_keys
000000000030ef90 s __NSSharedKeySetS_keys
000000000031ac00 s __NSSharedKeySetS_keys
000000000032c8c0 s __NSSharedKeySetS_keys
000000000033e6a0 s __NSSharedKeySetS_keys
0000000000348920 s __NSSharedKeySetS_keys
000000000034e1e0 s __NSSharedKeySetS_keys
0000000000351840 s __NSSharedKeySetS_keys
00000000003578f0 s __NSSharedKeySetS_keys
0000000000363050 s __NSSharedKeySetS_keys
00000000003771d0 s __NSSharedKeySetS_keys
0000000000388580 s __NSSharedKeySetS_keys
0000000000391c90 s __NSSharedKeySetS_keys
00000000003940e8 s __NSSharedKeySetS_keys
00000000003a2410 s __NSSharedKeySetS_keys
00000000003b8ed0 s __NSSharedKeySetS_keys
00000000003c1010 s __NSSharedKeySetS_keys
00000000001f5f40 s __NSSharedKeySetS_r
000000000020bef0 s __NSSharedKeySetS_r
000000000021d730 s __NSSharedKeySetS_r
0000000000229f60 s __NSSharedKeySetS_r
000000000023d150 s __NSSharedKeySetS_r
000000000024a5f0 s __NSSharedKeySetS_r
0000000000258930 s __NSSharedKeySetS_r
000000000026bef0 s __NSSharedKeySetS_r
0000000000281b10 s __NSSharedKeySetS_r
000000000028ae30 s __NSSharedKeySetS_r
000000000028c1b0 s __NSSharedKeySetS_r
000000000029af40 s __NSSharedKeySetS_r
00000000002a7c60 s __NSSharedKeySetS_r
00000000002fbb00 s __NSSharedKeySetS_r
0000000000309a80 s __NSSharedKeySetS_r
0000000000313340 s __NSSharedKeySetS_r
0000000000321f80 s __NSSharedKeySetS_r
0000000000333ab0 s __NSSharedKeySetS_r
0000000000346710 s __NSSharedKeySetS_r
0000000000349d80 s __NSSharedKeySetS_r
0000000000351280 s __NSSharedKeySetS_r
0000000000353110 s __NSSharedKeySetS_r
000000000035ac50 s __NSSharedKeySetS_r
0000000000369af0 s __NSSharedKeySetS_r
00000000003801f0 s __NSSharedKeySetS_r
000000000038e600 s __NSSharedKeySetS_r
00000000003940e1 s __NSSharedKeySetS_r
0000000000394e70 s __NSSharedKeySetS_r
00000000003ac230 s __NSSharedKeySetS_r
00000000003c0ffa s __NSSharedKeySetS_r
00000000001f5190 s __NSSharedKeySetS_seeds
000000000020b4a0 s __NSSharedKeySetS_seeds
000000000021cfb0 s __NSSharedKeySetS_seeds
00000000002294d0 s __NSSharedKeySetS_seeds
000000000023c940 s __NSSharedKeySetS_seeds
0000000000249df0 s __NSSharedKeySetS_seeds
0000000000257e00 s __NSSharedKeySetS_seeds
000000000026b1b0 s __NSSharedKeySetS_seeds
00000000002815f0 s __NSSharedKeySetS_seeds
000000000028adb0 s __NSSharedKeySetS_seeds
000000000028b960 s __NSSharedKeySetS_seeds
000000000029a7b0 s __NSSharedKeySetS_seeds
00000000002a7700 s __NSSharedKeySetS_seeds
00000000002fb3c0 s __NSSharedKeySetS_seeds
0000000000309510 s __NSSharedKeySetS_seeds
0000000000312ba0 s __NSSharedKeySetS_seeds
00000000003214d0 s __NSSharedKeySetS_seeds
0000000000332fe0 s __NSSharedKeySetS_seeds
00000000003464d0 s __NSSharedKeySetS_seeds
0000000000349920 s __NSSharedKeySetS_seeds
0000000000351210 s __NSSharedKeySetS_seeds
0000000000352c80 s __NSSharedKeySetS_seeds
000000000035a400 s __NSSharedKeySetS_seeds
0000000000368d70 s __NSSharedKeySetS_seeds
000000000037f9a0 s __NSSharedKeySetS_seeds
000000000038e280 s __NSSharedKeySetS_seeds
00000000003940d8 s __NSSharedKeySetS_seeds
0000000000394100 s __NSSharedKeySetS_seeds
00000000003ab550 s __NSSharedKeySetS_seeds
00000000003c0ff0 s __NSSharedKeySetS_seeds
00000000001effa0 s __NSSharedKeySet_g
000000000021cf38 s __NSSharedKeySet_g
00000000002b1240 s __NSSharedKeySet_g
00000000003203e0 s __NSSharedKeySet_g
00000000001f2440 s __NSSharedKeySet_keys
000000000021cf60 s __NSSharedKeySet_keys
00000000002b5c60 s __NSSharedKeySet_keys
0000000000321000 s __NSSharedKeySet_keys
00000000001f01d0 s __NSSharedKeySet_r
000000000021cf40 s __NSSharedKeySet_r
00000000002b16a0 s __NSSharedKeySet_r
00000000003204a0 s __NSSharedKeySet_r
00000000001eff90 s __NSSharedKeySet_seeds
000000000021cf30 s __NSSharedKeySet_seeds
00000000002b1230 s __NSSharedKeySet_seeds
00000000003203d0 s __NSSharedKeySet_seeds
*/

/*
00000000005d8338 s _OBJC_CLASS_$___NSFrozenSetM
00000000005d8388 s _OBJC_METACLASS_$___NSFrozenSetM

00000000001a0710 t +[__NSFrozenSetM allocWithZone:]

00000000001a0140 t -[__NSFrozenSetM clumpingFactor]
00000000001a03a0 t -[__NSFrozenSetM clumpingInterestingThreshold]
00000000001a0780 t -[__NSFrozenSetM copyWithZone:]
00000000001a0400 t -[__NSFrozenSetM countByEnumeratingWithState:objects:count:]
000000000019ff90 t -[__NSFrozenSetM count]
00000000001a0730 t -[__NSFrozenSetM dealloc]
00000000001a04e0 t -[__NSFrozenSetM enumerateObjectsWithOptions:usingBlock:]
00000000001a0650 t -[__NSFrozenSetM getObjects:count:]
000000000019ffb0 t -[__NSFrozenSetM member:]
00000000001a07a0 t -[__NSFrozenSetM mutableCopyWithZone:]
00000000001a00c0 t -[__NSFrozenSetM objectEnumerator]

00000000005d6750 s _OBJC_IVAR_$___NSFrozenSetM.cow
00000000005d6748 s _OBJC_IVAR_$___NSFrozenSetM.storage

00000000001a08a0 t ___38-[__NSFrozenSetM mutableCopyWithZone:]_block_invoke
*/

/*
00000000005d6fb0 s _OBJC_CLASS_$___NSSingleObjectSetI
00000000005d6fd8 s _OBJC_METACLASS_$___NSSingleObjectSetI

0000000000136c20 t +[__NSSingleObjectSetI __new::]
0000000000136c80 t +[__NSSingleObjectSetI allocWithZone:]
00000000001369f0 t +[__NSSingleObjectSetI automaticallyNotifiesObserversForKey:]

0000000000136ca0 t -[__NSSingleObjectSetI copyWithZone:]
00000000000a3020 t -[__NSSingleObjectSetI countByEnumeratingWithState:objects:count:]
00000000000a5eb0 t -[__NSSingleObjectSetI count]
0000000000075980 t -[__NSSingleObjectSetI dealloc]
0000000000136a00 t -[__NSSingleObjectSetI enumerateObjectsWithOptions:usingBlock:]
00000000000e13a0 t -[__NSSingleObjectSetI getObjects:count:]
00000000000a2ca0 t -[__NSSingleObjectSetI member:]
00000000000e43d0 t -[__NSSingleObjectSetI objectEnumerator]

00000000005d61b0 s _OBJC_IVAR_$___NSSingleObjectSetI.element

0000000000136b20 t ___63-[__NSSingleObjectSetI enumerateObjectsWithOptions:usingBlock:]_block_invoke
*/
