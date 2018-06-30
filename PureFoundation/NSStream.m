//
//  NSStream.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFStreamPriv.h"

#define RSTREAM     ((CFReadStreamRef)self)
#define WSTREAM     ((CFWriteStreamRef)self)

// NSStream, NSInputStream and NSOutputStream are declared here in CF but its methods are implemented in Foundation

@implementation NSStream
@end

@implementation NSInputStream
@end

@implementation NSOutputStream
@end

@interface NSCFInputStream : NSInputStream
@end

@interface NSCFOutputStream : NSOutputStream
@end

// Delegate-wrapping callbacks

static void _PFReadStreamCB(CFReadStreamRef stream, CFStreamEventType eventType, void *delegate) {
    if([(id)delegate respondsToSelector:@selector(stream:handleEvent:)]) {
        [(id)delegate stream:(NSStream *)stream handleEvent: eventType];
    }
}

static void _PFWriteStreamCB(CFWriteStreamRef stream, CFStreamEventType eventType, void *delegate) {
    if([(id)delegate respondsToSelector:@selector(stream:handleEvent:)]) {
        [(id)delegate stream:(NSStream *)stream handleEvent: eventType];
    }
}

#define ALL_STREAM_EVENTS (kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered)


@implementation NSCFInputStream

// TODO:
// t -[__NSCFInputStream removeFromRunLoop:forMode:]
// t -[__NSCFInputStream scheduleInRunLoop:forMode:]
// t -[__NSCFInputStream isEqual:]

- (CFTypeID)_cfTypeID {
    return CFReadStreamGetTypeID();
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

- (id)delegate {
    return (id)_CFStreamGetInfoPointer((struct _CFStream *)self);
}

- (void)setDelegate:(id)delegate {
    if (!delegate) {
        CFReadStreamUnscheduleFromRunLoop(RSTREAM, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFReadStreamSetClient(RSTREAM, kCFStreamEventNone, NULL, NULL);
    } else {
        CFOptionFlags flags = ALL_STREAM_EVENTS;
        CFStreamClientContext context = { 0, (void *)delegate, NULL, NULL, NULL };
        CFReadStreamSetClient(RSTREAM, flags, (CFReadStreamClientCallBack)&_PFReadStreamCB, &context);
        CFReadStreamScheduleWithRunLoop(RSTREAM, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)open {
    CFReadStreamOpen(RSTREAM);
}

- (void)close {
    CFReadStreamClose(RSTREAM);
}

- (id)propertyForKey:(NSString *)key {
    return [(id)CFReadStreamCopyProperty(RSTREAM, (CFStringRef)key) autorelease];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    return CFReadStreamSetProperty(RSTREAM, (CFStringRef)key, (CFTypeRef)property);
}

- (NSStreamStatus)streamStatus {
    return (NSStreamStatus)CFReadStreamGetStatus(RSTREAM);
}

- (NSError *)streamError {
    return [(id)CFReadStreamCopyError(RSTREAM) autorelease];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length {
    if (!buffer || !length) return -1; // TODO: Set streamError
    return CFReadStreamRead(RSTREAM, (UInt8 *)buffer, length);
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)pLength {
    *buffer = (uint8_t *)CFReadStreamGetBuffer(RSTREAM, 0, (CFIndex *)pLength);
    return (*pLength == -1) ? NO : YES;
}

- (BOOL)hasBytesAvailable {
    return CFReadStreamHasBytesAvailable(RSTREAM);
}

@end


@implementation NSCFOutputStream

// TODO:
// t -[__NSCFOutputStream removeFromRunLoop:forMode:]
// t -[__NSCFOutputStream scheduleInRunLoop:forMode:]\
// t -[__NSCFOutputStream isEqual:]

- (CFTypeID)_cfTypeID {
    return CFWriteStreamGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

-(NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (id)delegate {
    return (id)_CFStreamGetInfoPointer((struct _CFStream *)self);
}

- (void)setDelegate:(id)delegate {
    if (!delegate) {
        CFWriteStreamUnscheduleFromRunLoop(WSTREAM, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFWriteStreamSetClient(WSTREAM, kCFStreamEventNone, NULL, NULL);
    } else {
        CFOptionFlags flags = ALL_STREAM_EVENTS;
        CFStreamClientContext context = { 0, (void *)delegate, NULL, NULL, NULL };
        CFWriteStreamSetClient(WSTREAM, flags, (CFWriteStreamClientCallBack)&_PFWriteStreamCB, &context);
        CFWriteStreamScheduleWithRunLoop(WSTREAM, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)open {
    CFWriteStreamOpen(WSTREAM);
}

- (void)close {
    CFWriteStreamClose(WSTREAM);
}

- (id)propertyForKey:(NSString *)key {
    return [(id)CFWriteStreamCopyProperty(WSTREAM, (CFStringRef)key) autorelease];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    return CFWriteStreamSetProperty(WSTREAM, (CFStringRef)key, (CFTypeRef)property);
}

- (NSStreamStatus)streamStatus {
    return (NSStreamStatus)CFWriteStreamGetStatus(WSTREAM);
}

- (NSError *)streamError {
    return [(id)CFWriteStreamCopyError(WSTREAM) autorelease];
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)length {
    if (!buffer || !length) return -1; // TODO: Set streamError
    return CFWriteStreamWrite(WSTREAM, (const UInt8 *)buffer, (CFIndex)length);
}

- (BOOL)hasSpaceAvailable {
    return CFWriteStreamCanAcceptBytes(WSTREAM);
}

@end

#undef RSTREAM
#undef WSTREAM
#undef ALL_STREAM_EVENTS
