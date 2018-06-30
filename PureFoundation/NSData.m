//
//  NSData.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSData and NSMutableData are declared here. All other methods are implemented in the NSData category in Foundation

@implementation NSData

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

@implementation NSMutableData
@end

#define SELF ((CFDataRef)self)
#define MSELF ((CFMutableDataRef)self)

@interface __NSCFData : NSMutableData
@end

@implementation __NSCFData

- (CFTypeID)_cfTypeID {
    return CFDataGetTypeID();
}

// TODO:
// t +[__NSCFData automaticallyNotifiesObserversForKey:]
// t -[__NSCFData _isDeallocating]
// t -[__NSCFData _providesConcreteBacking]
// t -[__NSCFData _tryRetain]

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFDataCreateCopy(kCFAllocatorDefault, SELF);
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return (id)CFDataCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // PF_TODO
}

- (NSUInteger)length {
    return CFDataGetLength(SELF);
}

- (const void *)bytes {
    return (const void *)CFDataGetBytePtr(SELF);
}

- (void)getBytes:(void *)buffer {
    CFDataGetBytes(SELF, CFRangeMake(0, CFDataGetLength(SELF)), (UInt8 *)buffer);
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length {
    CFDataGetBytes(SELF, CFRangeMake(0, length), (UInt8 *)buffer);
}

- (void)getBytes:(void *)buffer range:(NSRange)range {
    CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length || range.location + range.length > length) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFDataGetBytes(SELF, CFRangeMake(range.location, range.length), (UInt8 *)buffer);
}

- (BOOL)isEqualToData:(NSData *)other {
    if (!other) return NO;
    return (self == other) || CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

- (NSData *)subdataWithRange:(NSRange)range {
    CFIndex length = CFDataGetLength(SELF);
    if (!length || range.location >= length || range.location + range.length > length) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    UInt8 *buffer = malloc(range.length);
    CFDataGetBytes(SELF, CFRangeMake(range.location, range.length), buffer);
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)buffer, range.length);
    free(buffer);
    return [(id)data autorelease];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically {
    NSDataWritingOptions options = atomically ? NSDataWritingAtomic : 0;
    return PFDataWriteToPath(SELF, (CFStringRef)path, options, NULL);
}

- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr {
    return PFDataWriteToPath(SELF, (CFStringRef)path, writeOptionsMask, (CFErrorRef *)errorPtr);
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
    NSDataWritingOptions options = atomically ? NSDataWritingAtomic : 0;
    return PFDataWriteToURL(SELF, (CFURLRef)url, options, NULL);
}

- (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr {
    return PFDataWriteToURL(SELF, (CFURLRef)url, writeOptionsMask, (CFErrorRef *)errorPtr);
}

#pragma mark - mutable instance methods

- (void *)mutableBytes {
    return CFDataGetMutableBytePtr(MSELF);
}

- (void)setLength:(NSUInteger)length {
    CFDataSetLength(MSELF, length);
}

- (void)appendBytes:(const void *)bytes length:(NSUInteger)length {
    if (!length) return;
    CFDataAppendBytes(MSELF, (const UInt8 *)bytes, length);
}

- (void)appendData:(NSData *)other {
    CFIndex length = CFDataGetLength((CFDataRef)other);
    if (!length) return;
    const UInt8 *bytes = CFDataGetBytePtr((CFDataRef)other);
    CFDataAppendBytes(MSELF, bytes, length);
}

- (void)increaseLengthBy:(NSUInteger)extraLength {
    CFDataIncreaseLength(MSELF, extraLength);
}

- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes {
    CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFDataReplaceBytes(MSELF, CFRangeMake(range.location, range.length), (const UInt8 *)bytes, range.length);
}

- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)replacementBytes length:(NSUInteger)replacementLength {
    CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFDataReplaceBytes(MSELF, CFRangeMake(range.location, range.length), (const UInt8 *)replacementBytes, replacementLength);
}

- (void)resetBytesInRange:(NSRange)range {
    CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    UInt8 *bytes = calloc(range.length, 1);
    CFDataReplaceBytes(MSELF, CFRangeMake(range.location, range.length), (const UInt8 *)bytes, range.length);
    free(bytes);
}

- (void)setData:(NSData *)data {
    CFIndex length = CFDataGetLength((CFDataRef)data);
    if (!length) return;
    const UInt8 *bytes = CFDataGetBytePtr((CFDataRef)data);
    CFRange range = CFRangeMake(0, CFDataGetLength(SELF));
    CFDataReplaceBytes(MSELF, range, bytes, length);
}

@end

#undef SELF
#undef MSELF



