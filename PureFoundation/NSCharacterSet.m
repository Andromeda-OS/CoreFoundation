//
//  NSCharacterSet.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSCharacterSet, including all of the factory methods, are implemented in Foundation

#define SELF    ((CFCharacterSetRef)self)
#define MSELF   ((CFMutableCharacterSetRef)self)

@interface __NSCFCharacterSet : NSMutableCharacterSet
@end

@implementation __NSCFCharacterSet

// TODO:
// t +[__NSCFCharacterSet automaticallyNotifiesObserversForKey:]
// t -[__NSCFCharacterSet classForCoder]
// t -[__NSCFCharacterSet encodeWithCoder:]
// t -[__NSCFCharacterSet makeCharacterSetCompact]
// t -[__NSCFCharacterSet makeCharacterSetFast]

-(CFTypeID)_cfTypeID {
    return CFCharacterSetGetTypeID();
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CFCharacterSetCreateCopy(kCFAllocatorDefault, SELF);
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, SELF);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // TODO
}

#pragma mark -

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]] && CFEqual((CFTypeRef)self, (CFTypeRef)object);
}

- (BOOL)characterIsMember:(unichar)aCharacter {
    return CFCharacterSetIsCharacterMember(SELF, (UniChar)aCharacter);
}

- (NSData *)bitmapRepresentation {
    return [(id)CFCharacterSetCreateBitmapRepresentation(kCFAllocatorDefault, SELF) autorelease];
}

- (NSCharacterSet *)invertedSet {
    return [(id)CFCharacterSetCreateInvertedSet(kCFAllocatorDefault, SELF) autorelease];
}

- (BOOL)longCharacterIsMember:(UTF32Char)theLongChar {
    return CFCharacterSetIsLongCharacterMember(SELF, theLongChar);
}

- (BOOL)isSupersetOfSet:(NSCharacterSet *)theOtherSet {
    return CFCharacterSetIsSupersetOfSet(SELF, (CFCharacterSetRef)theOtherSet);
}

- (BOOL)hasMemberInPlane:(uint8_t)thePlane {
    return CFCharacterSetHasMemberInPlane(SELF, (CFIndex)thePlane);
}

- (void)addCharactersInRange:(NSRange)aRange {
    if (aRange.length == 0) return;
    CFRange range = CFRangeMake(aRange.location, aRange.length);
    CFCharacterSetAddCharactersInRange(MSELF, range );
}

- (void)removeCharactersInRange:(NSRange)aRange {
    if (aRange.length == 0) return;
    CFRange range = CFRangeMake(aRange.location, aRange.length);
    CFCharacterSetRemoveCharactersInRange(MSELF, range);
}

- (void)addCharactersInString:(NSString *)aString {
    if (!aString || !aString.length) return;
    CFCharacterSetAddCharactersInString(MSELF, (CFStringRef)aString);
}

- (void)removeCharactersInString:(NSString *)aString {
    if (!aString || !aString.length) return;
    CFCharacterSetRemoveCharactersInString(MSELF, (CFStringRef)aString);
}

- (void)formUnionWithCharacterSet:(NSCharacterSet *)otherSet {
    if (!otherSet) return;
    CFCharacterSetUnion(MSELF, (CFCharacterSetRef)otherSet);
}

- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)otherSet {
    if (!otherSet) return;
    CFCharacterSetIntersect(MSELF, (CFCharacterSetRef)otherSet);
}

- (void)invert {
    CFCharacterSetInvert(MSELF);
}

@end

#undef SELF
#undef MSELF
