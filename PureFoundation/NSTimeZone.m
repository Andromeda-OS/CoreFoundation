//
//  NSTimeZone.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Check that this is defined somewhere
// S _NSSystemTimeZoneDidChangeNotification

#define SELF ((CFTimeZoneRef)self)

@interface __NSTimeZone : NSTimeZone
@end

@implementation NSTimeZone

#pragma mark - init methods

- (id)initWithName:(NSString *)tzName {
    free(self);
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)tzName, false);
}

- (id)initWithName:(NSString *)tzName data:(NSData *)data {
    free(self);
    return (id)CFTimeZoneCreate(kCFAllocatorDefault, (CFStringRef)tzName, (CFDataRef)data);
}

#pragma mark - factory methods

+ (instancetype)timeZoneWithName:(NSString *)tzName {
    return [(id)CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)tzName, true) autorelease];
}

+ (id)timeZoneWithName:(NSString *)tzName data:(NSData *)data {
    return [(id)CFTimeZoneCreate(kCFAllocatorDefault, (CFStringRef)tzName, (CFDataRef)data) autorelease];
}

+ (id)timeZoneForSecondsFromGMT:(NSInteger)seconds {
    return [(id)CFTimeZoneCreateWithTimeIntervalFromGMT(kCFAllocatorDefault, seconds) autorelease];
}

+ (id)timeZoneWithAbbreviation:(NSString *)abbreviation {
    return [(id) CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)abbreviation, true) autorelease];
}

+ (NSTimeZone *)systemTimeZone {
    return [(id)CFTimeZoneCopySystem() autorelease];
}

+ (void)resetSystemTimeZone {
    CFTimeZoneResetSystem();
}

+ (NSTimeZone *)defaultTimeZone {
    return [(id)CFTimeZoneCopyDefault() autorelease];
}

+ (void)setDefaultTimeZone:(NSTimeZone *)aTimeZone {
    CFTimeZoneSetDefault((CFTimeZoneRef)aTimeZone);
}

// "Returns an object that forwards all messages to the default time zone for the current application."
// TODO: implement some form of proxy timezone object
+ (NSTimeZone *)localTimeZone {
    // PF_TODO
    return [(id)CFTimeZoneCopyDefault() autorelease];
}

+ (NSArray *)knownTimeZoneNames {
    return [(id)CFTimeZoneCopyKnownNames() autorelease];
}

+ (NSDictionary *)abbreviationDictionary {
    return [(id)CFTimeZoneCopyAbbreviationDictionary() autorelease];
}

// TODO:
// t +[NSTimeZone setAbbreviationDictionary:]
// t +[NSTimeZone timeZoneDataVersion]

// NSTimeZone instance methods
- (NSString *)name { return nil; }
- (NSData *)data { return nil; }
- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate { return 0; }
- (NSString *)abbreviationForDate:(NSDate *)aDate { return nil; }
- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate { return NO; }
- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate { return 0; }
- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate { return nil; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone { return nil; }
@end

@implementation __NSTimeZone

- (CFTypeID)_cfTypeID {
    return CFTimeZoneGetTypeID();
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

- (NSString *)name {
    return (id)CFTimeZoneGetName(SELF);
}

- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale {
    return [(id)CFTimeZoneCopyLocalizedName(SELF, style, (CFLocaleRef)locale) autorelease];
}

- (NSData *)data {
    return (id)CFTimeZoneGetData(SELF);
}

- (NSString *)abbreviation {
    return [(id)CFTimeZoneCopyAbbreviation(SELF, CFAbsoluteTimeGetCurrent()) autorelease];
}

- (NSString *)abbreviationForDate:(NSDate *)aDate {
    return [(id)CFTimeZoneCopyAbbreviation(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate)) autorelease];
}

- (NSInteger)secondsFromGMT {
    return CFTimeZoneGetSecondsFromGMT(SELF, CFAbsoluteTimeGetCurrent());
}

- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate {
    return CFTimeZoneGetSecondsFromGMT(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
}

- (BOOL)isDaylightSavingTime {
    return CFTimeZoneIsDaylightSavingTime(SELF, CFAbsoluteTimeGetCurrent());
}

- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate {
    return CFTimeZoneIsDaylightSavingTime(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
}

- (NSTimeInterval)daylightSavingTimeOffset {
    return CFTimeZoneGetDaylightSavingTimeOffset(SELF, CFAbsoluteTimeGetCurrent());
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate {
    return CFTimeZoneGetDaylightSavingTimeOffset(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
}

- (NSDate *)nextDaylightSavingTimeTransition {
    CFAbsoluteTime time = CFTimeZoneGetNextDaylightSavingTimeTransition(SELF, CFAbsoluteTimeGetCurrent());
    return [(id)CFDateCreate(kCFAllocatorDefault, time) autorelease];
}

- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate {
    CFAbsoluteTime time = CFTimeZoneGetNextDaylightSavingTimeTransition(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
    return [(id)CFDateCreate(kCFAllocatorDefault, time) autorelease];
}

- (BOOL)isEqualToTimeZone:(NSTimeZone *)aTimeZone {
    if (!aTimeZone) return NO;
    return (self == aTimeZone) || CFEqual((CFTypeRef)self, (CFTypeRef)aTimeZone);
}

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, CFTimeZoneGetName(SELF), false);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    // PF_TODO
}

@end

#undef SELF

/*
00000000005d84a0 s _OBJC_METACLASS_$___NSTimeZone
00000000005d8450 s _OBJC_CLASS_$___NSTimeZone

000000000008fd30 t +[__NSTimeZone __new:cache:]
000000000010c000 t +[__NSTimeZone __new:data:]
00000000001ad8e0 t +[__NSTimeZone allocWithZone:]
00000000001ad8d0 t +[__NSTimeZone automaticallyNotifiesObserversForKey:]
000000000008fcc0 t +[__NSTimeZone initialize]

0000000000105580 t -[__NSTimeZone abbreviationForDate:]
00000000000fc770 t -[__NSTimeZone data]
00000000000fc930 t -[__NSTimeZone daylightSavingTimeOffsetForDate:]
00000000001ad850 t -[__NSTimeZone dealloc]
00000000001ad350 t -[__NSTimeZone isDaylightSavingTimeForDate:]
00000000001ad590 t -[__NSTimeZone localizedName:locale:]
00000000000aea20 t -[__NSTimeZone name]
00000000001ad380 t -[__NSTimeZone nextDaylightSavingTimeTransitionAfterDate:]
0000000000090350 t -[__NSTimeZone secondsFromGMTForDate:]

00000000005d67b0 s _OBJC_IVAR_$___NSTimeZone._data
00000000005d67b8 s _OBJC_IVAR_$___NSTimeZone._lock
00000000005d67a8 s _OBJC_IVAR_$___NSTimeZone._name
00000000005d67c0 s _OBJC_IVAR_$___NSTimeZone._ucal
*/

/*
    Implementation details
blocks:
000000000008fcf0 t ___26+[__NSTimeZone initialize]_block_invoke
00000000001ae010 t ___27+[NSTimeZone localTimeZone]_block_invoke
*/

/*
00000000005d8478 s _OBJC_CLASS_$___NSPlaceholderTimeZone
00000000005d84c8 s _OBJC_METACLASS_$___NSPlaceholderTimeZone

000000000008f8e0 t +[__NSPlaceholderTimeZone immutablePlaceholder]
000000000008f820 t +[__NSPlaceholderTimeZone initialize]

00000000000ae8d0 t -[__NSPlaceholderTimeZone __initWithName:cache:]
000000000008f8f0 t -[__NSPlaceholderTimeZone __initWithName:data:cache:]
00000000001adb20 t -[__NSPlaceholderTimeZone abbreviationForDate:]
00000000001ada20 t -[__NSPlaceholderTimeZone data]
00000000001adc20 t -[__NSPlaceholderTimeZone daylightSavingTimeOffsetForDate:]
00000000001ad990 t -[__NSPlaceholderTimeZone dealloc]
00000000000ae8b0 t -[__NSPlaceholderTimeZone initWithName:]
00000000000e55c0 t -[__NSPlaceholderTimeZone initWithName:data:]
00000000001ad940 t -[__NSPlaceholderTimeZone init]
00000000001adba0 t -[__NSPlaceholderTimeZone isDaylightSavingTimeForDate:]
00000000001ad9a0 t -[__NSPlaceholderTimeZone name]
00000000001adca0 t -[__NSPlaceholderTimeZone nextDaylightSavingTimeTransitionAfterDate:]
00000000001ad970 t -[__NSPlaceholderTimeZone release]
00000000001ad980 t -[__NSPlaceholderTimeZone retainCount]
00000000001ad960 t -[__NSPlaceholderTimeZone retain]
00000000001adaa0 t -[__NSPlaceholderTimeZone secondsFromGMTForDate:]

000000000008f850 t ___37+[__NSPlaceholderTimeZone initialize]_block_invoke
*/

/*
 00000000005dd598 d ___NSDefaultTimeZone_
 00000000005dd590 d ___NSSystemTimeZone_
 
00000000005d84f0 s _OBJC_CLASS_$___NSLocalTimeZone
00000000005da8e0 s _OBJC_CLASS_$___NSLocalTimeZoneI

00000000005d8518 s _OBJC_METACLASS_$___NSLocalTimeZone
00000000005da908 s _OBJC_METACLASS_$___NSLocalTimeZoneI

00000000001b6390 t +[__NSLocalTimeZone supportsSecureCoding]


00000000001b61e0 t -[__NSLocalTimeZone abbreviationForDate:]
00000000001b6410 t -[__NSLocalTimeZone classForCoder]
000000000010f0e0 t -[__NSLocalTimeZone copyWithZone:]
00000000001b61a0 t -[__NSLocalTimeZone data]
00000000001b6260 t -[__NSLocalTimeZone daylightSavingTimeOffsetForDate:]
00000000001b6330 t -[__NSLocalTimeZone description]
00000000001b6400 t -[__NSLocalTimeZone encodeWithCoder:]
00000000001b63a0 t -[__NSLocalTimeZone initWithCoder:]
00000000001b6220 t -[__NSLocalTimeZone isDaylightSavingTimeForDate:]
00000000001b62e0 t -[__NSLocalTimeZone localizedName:locale:]
00000000000ae4a0 t -[__NSLocalTimeZone name]
00000000001b62a0 t -[__NSLocalTimeZone nextDaylightSavingTimeTransitionAfterDate:]
00000000001b6430 t -[__NSLocalTimeZone replacementObjectForPortCoder:]
00000000000f9ff0 t -[__NSLocalTimeZone secondsFromGMTForDate:]
00000000001b6470 t -[__NSLocalTimeZoneI _isDeallocating]
00000000001b6480 t -[__NSLocalTimeZoneI _tryRetain]
00000000001b6450 t -[__NSLocalTimeZoneI release]
00000000001b6460 t -[__NSLocalTimeZoneI retainCount]
00000000001b6440 t -[__NSLocalTimeZoneI retain]
*/
