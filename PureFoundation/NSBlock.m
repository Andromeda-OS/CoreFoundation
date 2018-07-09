//
//  NSBlock.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// The definitions of NSBlock etc. are not public. Block instances report different classes as their type.

// Inheritance runs:
//  NSObject -> NSBlock -> __NSGlobalBlock -> __NSGlobalBlock__ (_NSConcreteGlobalBlock)
//                      -> __NSStackBlock -> __NSStackBlock__ (_NSConcreteStackBlock)
// Other block types appear to follow the same pattern.

// This is defined in <objc/objc-internal.h>
extern Class objc_initializeClassPair(Class superclass, const char *name, Class cls, Class metacls);

@interface NSBlock : NSObject
@end

@interface __NSGlobalBlock : NSBlock
@end

@interface __NSStackBlock : NSBlock
@end

@interface __NSMallocBlock : NSBlock
@end

@interface __NSAutoBlock : NSBlock
@end

@interface __NSFinalizingBlock : NSBlock
@end

@interface __NSBlockVariable : NSBlock // <-- check this
@end

// These are defined in libsystem_blocks.dylib. When blocks are created, their isa points to one of these.
// _NSConcreteGlobalBlock and _NSConcreteStackBlock are exposed through /usr/include/Block.h
// The others are in Block_private.h but are re-declared here for simplicity
extern void *_NSConcreteAutoBlock[32];
extern void *_NSConcreteFinalizingBlock[32];
extern void *_NSConcreteMallocBlock[32];
extern void *_NSConcreteWeakBlockVariable[32];

// cls: super class, name: name for new mapped class, ptr: class structure defined in libsystem_blocks
// Block_private.h describes the _NSConcrete... structures as "class+meta", which is why the last param points to the second half of these structures
#define MAP_BLOCK_TO_CLASS(cls,name,ptr) \
    { Class blockClass = objc_initializeClassPair([cls class], name, (Class)ptr, (Class)(ptr + 16)); objc_registerClassPair(blockClass); }

// Create the obj-c classes which map the _NSConcrete...Block ISAs into the runtime
// This is called from _CFInitialize() in Runtime.c
void ___CFMakeNSBlockClasses(void) {
    // _NSConcreteGlobalBlock => __NSGlobalBlock__
    MAP_BLOCK_TO_CLASS(__NSGlobalBlock, "__NSGlobalBlock__", _NSConcreteGlobalBlock);
    // _NSConcreteStackBlock => __NSStackBlock__
    MAP_BLOCK_TO_CLASS(__NSStackBlock, "__NSStackBlock__", _NSConcreteStackBlock);
    // _NSConcreteMallocBlock => __NSMallocBlock__
    MAP_BLOCK_TO_CLASS(__NSMallocBlock, "__NSMallocBlock__", _NSConcreteMallocBlock);
    // _NSConcreteAutoBlock => __NSAutoBlock__
    MAP_BLOCK_TO_CLASS(__NSAutoBlock, "__NSAutoBlock__", _NSConcreteAutoBlock);
    // _NSConcreteFinalizingBlock => __NSFinalizingBlock__
    MAP_BLOCK_TO_CLASS(__NSFinalizingBlock, "__NSFinalizingBlock__", _NSConcreteFinalizingBlock);
    // _NSConcreteWeakBlockVariable => __NSBlockVariable__
    MAP_BLOCK_TO_CLASS(__NSBlockVariable, "__NSBlockVariable__", _NSConcreteWeakBlockVariable);
}

#undef MAP_BLOCK_TO_CLASS


@implementation NSBlock

// TODO:
// t -[NSBlock invoke]
// t -[NSBlock performAfterDelay:]

- (id)copyWithZone:(__unused NSZone *)zone {
    return _Block_copy(self);
}

- (id)copy {
    return _Block_copy(self);
}

@end


@implementation __NSGlobalBlock

// TODO:
// t -[__NSGlobalBlock _isDeallocating]
// t -[__NSGlobalBlock _tryRetain]
// t -[__NSGlobalBlock copyWithZone:]
// t -[__NSGlobalBlock copy]
// t -[__NSGlobalBlock release]
// t -[__NSGlobalBlock retainCount]
// t -[__NSGlobalBlock retain]

@end


@implementation __NSStackBlock

// TODO:
// t -[__NSStackBlock autorelease]
// t -[__NSStackBlock release]
// t -[__NSStackBlock retainCount]
// t -[__NSStackBlock retain]

@end


@implementation __NSAutoBlock

// TODO:
// t -[__NSAutoBlock copyWithZone:]
// t -[__NSAutoBlock copy]

@end


@implementation __NSMallocBlock

// TODO:
// t -[__NSMallocBlock release]
// t -[__NSMallocBlock retainCount]
// t -[__NSMallocBlock retain]

@end


@implementation __NSFinalizingBlock

// TODO:
// t -[__NSFinalizingBlock finalize]

@end


@implementation __NSBlockVariable

// TODO:
// S _OBJC_IVAR_$___NSBlockVariable.byref_destroy
// S _OBJC_IVAR_$___NSBlockVariable.byref_keep
// S _OBJC_IVAR_$___NSBlockVariable.containedObject
// S _OBJC_IVAR_$___NSBlockVariable.flags
// S _OBJC_IVAR_$___NSBlockVariable.forwarding
// S _OBJC_IVAR_$___NSBlockVariable.size

@end
