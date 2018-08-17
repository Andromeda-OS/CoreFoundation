//
//  NSDate.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForFoundationOnly.h"

// Coding happens in Foundation in the NSDate category

#define SELF ((CFDateRef)self)

@interface __NSDate : NSDate
@end

@implementation NSDate

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
    free(self);
    return nil;
}

#pragma mark - factory methods

+ (id)date {
    return [(id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent()) autorelease];
}

+ (id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, seconds) autorelease];
}

+ (id)dateWithTimeIntervalSinceNow:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + seconds) autorelease];
}

+ (id)dateWithTimeIntervalSince1970:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, (seconds - NSTimeIntervalSince1970)) autorelease];
}

+ (id)dateWithTimeInterval:(NSTimeInterval)secsToBeAdded sinceDate:(NSDate *)date {
    return [(id)CFDateCreate(kCFAllocatorDefault, CFDateGetAbsoluteTime((CFDateRef)date) + secsToBeAdded) autorelease];
}

// These values were deduced from proper Foundation
+ (id)distantFuture {
    return [(id)CFDateCreate(kCFAllocatorDefault, 63113904000.000000) autorelease];
}

+ (id)distantPast {
    return [(id)CFDateCreate(kCFAllocatorDefault, -63114076800.000000) autorelease];
}

+ (NSTimeInterval)timeIntervalSinceReferenceDate {
    return CFAbsoluteTimeGetCurrent();
}

+ (id)dateWithDate:(NSDate *)date {
    return [(id)CFDateCreate(kCFAllocatorDefault, CFDateGetAbsoluteTime((CFDateRef)date)) autorelease];
}

+ (id)dateWithString:(NSString *)aString {
    // PF_TODO
    return nil;
}

#pragma mark - init methods

- (id)init {
    free(self);
    return (id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent());
}

- (id)initWithDate:(NSDate *)date {
    free(self);
    return (id)CFDateCreate(kCFAllocatorDefault, CFDateGetAbsoluteTime((CFDateRef)date));
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secondsToBeAdded {
    free(self);
    return (id)CFDateCreate(kCFAllocatorDefault, secondsToBeAdded);
}

- (id)initWithTimeIntervalSince1970:(NSTimeInterval)seconds {
    free(self);
    return (id)CFDateCreate(kCFAllocatorDefault, seconds - kCFAbsoluteTimeIntervalSince1970);
}

- (id)initWithTimeIntervalSinceNow:(NSTimeInterval)secondsToBeAddedToNow {
    free(self);
    return (id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + secondsToBeAddedToNow);
}

- (id)initWithTimeInterval:(NSTimeInterval)secondsToBeAdded sinceDate:(NSDate *)anotherDate {
    free(self);
    return (id)CFDateCreate(kCFAllocatorDefault, CFDateGetAbsoluteTime((CFDateRef)anotherDate) + secondsToBeAdded);
}


#pragma mark - NSCalendarDateExtras

// TODO: Implement this using CFDateFormatter
- (id)initWithString:(NSString *)aString {
    // PF_TODO
    free(self);
    return nil;
}

#pragma mark - instance method prototypes

- (NSTimeInterval)timeIntervalSinceReferenceDate { return 0.0; }

- (NSCalendarDate *)dateWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone { return nil; }
- (NSString *)descriptionWithLocale:(id)locale { return nil; }
- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale { return nil; }

@end


@implementation __NSDate

// TODO:
// t -[NSDate compare:toUnitGranularity:]
// t -[NSDate dateByAddingTimeInterval:]
// t -[NSDate isEqual:]
// t -[NSDate isEqual:toUnitGranularity:]
// t -[NSDate isInSameDayAsDate:]
// t -[NSDate isInToday]
// t -[NSDate isInTomorrow]
// t -[NSDate isInYesterday]
// t -[NSDate isNSDate__]

- (CFTypeID)_cfTypeID {
    return CFDateGetTypeID();
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

/*
 *    "A string representation of the receiver in the international format
 *    YYYY-MM-DD HH:MM:SS ±HHMM, where ±HHMM represents the time zone offset
 *    in hours and minutes from GMT (for example, “2001-03-24 10:45:32 +0600”)."
 *
 *    This will probably have to wait until NSDateFormatter is made.
 */
-(NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale {
    // PF_TODO
    return [self description];
}

- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale {
    // PF_TODO
    return [self description];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFDateCreate(kCFAllocatorDefault, CFDateGetAbsoluteTime(SELF));
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

#pragma mark - instance methods

- (NSTimeInterval)timeIntervalSinceReferenceDate {
    return CFDateGetAbsoluteTime(SELF);
}

- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)anotherDate {
    return CFDateGetTimeIntervalSinceDate(SELF, (CFDateRef)anotherDate);
}

- (NSTimeInterval)timeIntervalSinceNow {
    return CFDateGetAbsoluteTime(SELF) - CFAbsoluteTimeGetCurrent();
}

- (NSTimeInterval)timeIntervalSince1970 {
    return CFDateGetAbsoluteTime(SELF) + NSTimeIntervalSince1970;
}

- (id)addTimeInterval:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, (CFDateGetAbsoluteTime(SELF) + seconds)) autorelease];
}

- (NSDate *)earlierDate:(NSDate *)anotherDate {
    return CFDateCompare(SELF, (CFDateRef)anotherDate, NULL) == kCFCompareGreaterThan ? anotherDate : self;
}

- (NSDate *)laterDate:(NSDate *)anotherDate {
    return CFDateCompare(SELF, (CFDateRef)anotherDate, NULL) == kCFCompareLessThan ? anotherDate : self;
}

- (NSComparisonResult)compare:(NSDate *)other {
    return (NSComparisonResult)CFDateCompare(SELF, (CFDateRef)other, NULL);
}

- (BOOL)isEqualToDate:(NSDate *)otherDate {
    if (!otherDate) return NO;
    return (self == otherDate) || CFEqual((CFTypeRef)self, (CFTypeRef)otherDate);
}

#pragma mark - NSCalendarDate

- (NSCalendarDate *)dateWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone {
    // PF_TODO
    return nil;
}

@end

#undef SELF


/*
00000000005d6568 s _OBJC_IVAR_$___NSDate._time

blocks:
00000000000a2c60 t ___21+[NSDate distantPast]_block_invoke
000000000009cdd0 t ___23+[NSDate distantFuture]_block_invoke
00000000000e3f30 t ___32-[NSDate descriptionWithLocale:]_block_invoke
*/

/*
00000000005d7f78 s _OBJC_CLASS_$___NSPlaceholderDate
00000000005d8018 s _OBJC_METACLASS_$___NSPlaceholderDate

000000000003d9b0 t +[__NSPlaceholderDate immutablePlaceholder]
000000000003d900 t +[__NSPlaceholderDate initialize]

000000000018b100 t -[__NSPlaceholderDate dealloc]
000000000003d9c0 t -[__NSPlaceholderDate initWithTimeIntervalSinceReferenceDate:]
00000000000e2000 t -[__NSPlaceholderDate init]
000000000018b0e0 t -[__NSPlaceholderDate release]
000000000018b0f0 t -[__NSPlaceholderDate retainCount]
000000000018b0d0 t -[__NSPlaceholderDate retain]
000000000018b110 t -[__NSPlaceholderDate timeIntervalSinceReferenceDate]

000000000003d930 t ___33+[__NSPlaceholderDate initialize]_block_invoke
 
 00000000005dd200 d ___NSDistantFutureDate_
 00000000005dd210 d ___NSDistantPastDate_

*/

/*
00000000005d7fc8 s _OBJC_CLASS_$___NSTaggedDate
00000000005d7ff0 s _OBJC_METACLASS_$___NSTaggedDate

000000000003db60 t +[__NSTaggedDate __new:]
00000000000f02a0 t +[__NSTaggedDate allocWithZone:]
000000000018b080 t +[__NSTaggedDate automaticallyNotifiesObserversForKey:]

000000000018b050 t -[__NSTaggedDate dealloc]
000000000018b090 t -[__NSTaggedDate initWithTimeIntervalSinceReferenceDate:]
0000000000064aa0 t -[__NSTaggedDate timeIntervalSinceReferenceDate]

00000000005dd1f0 d ___NSTaggedDateClass
*/
