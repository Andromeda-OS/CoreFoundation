//
//  NSCFType.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForFoundationOnly.h"

// Every non-bridged CF type reports itself as this class

#define SELF    (CFTypeRef)self

@interface __NSCFType : NSObject
@end

@implementation __NSCFType

// TODO:
// t +[__NSCFType automaticallyNotifiesObserversForKey:]
// t -[__NSCFType _isDeallocating]
// t -[__NSCFType _tryRetain]

// The standard bridged-class over-rides
// These allow CF types to interact with Foundation
// The CFTYPE_IS_OBJC check specifically returns false for this class, so the CF codepath is taken

- (id)retain {
    return (id)_CFNonObjCRetain(SELF);
}

- (NSUInteger)retainCount {
    return CFGetRetainCount(SELF);
}

- (oneway void)release {
    _CFNonObjCRelease(SELF);
}

- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode

- (NSUInteger)hash {
    return _CFNonObjCHash(SELF);
}

- (NSString *)description {
    return [(id)CFCopyDescription(SELF) autorelease];
}

- (BOOL)isEqual:(id)object {
    return object && _CFNonObjCEqual(SELF, (CFTypeID)object);
}

@end

#undef SELF
