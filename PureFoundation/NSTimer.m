//
//  NSTimer.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSTimer is declared here, but all its methods are implemented in Foundation

// TODO: Work out where we should be implementing the NSTimer properties

@implementation NSTimer : NSObject
@end

#define SELF ((CFRunLoopTimerRef)self)

@interface __NSCFTimer : NSTimer
@end

@implementation __NSCFTimer

-(CFTypeID)_cfTypeID {
    return CFRunLoopTimerGetTypeID();
}

// TODO:
// t +[__NSCFTimer automaticallyNotifiesObserversForKey:]
// t -[__NSCFTimer _isDeallocating]
// t -[__NSCFTimer _tryRetain]

// Important TODOs:
// t -[__NSCFTimer setTolerance:]
// t -[__NSCFTimer tolerance]

- (NSDate *)fireDate {
    CFAbsoluteTime time = CFRunLoopTimerGetNextFireDate(SELF);
    return [(id)CFDateCreate(kCFAllocatorDefault, time) autorelease];
}

- (void)fire {
    // PF_TODO
}

- (void)setFireDate:(NSDate *)date {
    CFRunLoopTimerSetNextFireDate(SELF, CFDateGetAbsoluteTime((CFDateRef)date));
}

- (NSTimeInterval)timeInterval {
    return CFRunLoopTimerGetInterval(SELF);
}

- (void)invalidate {
    CFRunLoopTimerInvalidate(SELF);
}

- (BOOL)isValid {
    return CFRunLoopTimerIsValid(SELF);
}

- (id)userInfo {
    CFRunLoopTimerContext context = { 0, NULL, NULL, NULL, NULL };
    CFRunLoopTimerGetContext(SELF, &context);
    return context.info;
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

@end

#undef SELF
