//
//  NSCFType.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Need to work out whether we should bridge every non-bridged class to this class

#define SELF    (CFTypeRef)self

@interface __NSCFType : NSObject
@end

@implementation __NSCFType

// TODO:
// t +[__NSCFType automaticallyNotifiesObserversForKey:]
// t -[__NSCFType _isDeallocating]
// t -[__NSCFType _tryRetain]

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain(SELF); }
- (NSUInteger)retainCount { return CFGetRetainCount(SELF); }
- (oneway void)release { CFRelease(SELF); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash(SELF); }

- (NSString *)description {
    return [(id)CFCopyDescription(SELF) autorelease];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[__NSCFType class]] && CFEqual(SELF, (CFTypeRef)object);
}

@end

#undef SELF
