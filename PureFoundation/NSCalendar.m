//
//  NSCalendar.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Investigate
// T __NSCalendarPreserveSmallerUnits
// t __NSCFCalendarLogger
// d __NSCFCalendarLogger._logger
// d __NSCFCalendarLogger.onceToken

// TODO: Check that this is exported somewhere
// S _NSCalendarDayChangedNotification

@implementation NSCalendar

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return nil;
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding { return  YES; }
- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return nil;
}

#pragma mark - Factory methods

+ (id)currentCalendar {
    return [(id)CFCalendarCopyCurrent() autorelease];
}

// TODO: This will probably require a new custom class
+ (id)autoupdatingCurrentCalendar {
    return [(id)CFCalendarCopyCurrent() autorelease];
}

// TODO:
// t +[NSCalendar calendarWithIdentifier:]

#pragma mark - init methods

- (id)initWithCalendarIdentifier:(NSString *)ident {
    free(self);
    if (!ident.length) return nil;
    return (id)CFCalendarCreateWithIdentifier(kCFAllocatorDefault, (CFStringRef)ident);
}

- (id)init {
    free(self);
    return nil;
}

#pragma mark - instance methods

- (NSString *)calendarIdentifier { return nil; }
- (void)setLocale:(NSLocale *)locale {}
- (NSLocale *)locale { return nil; }
- (void)setTimeZone:(NSTimeZone *)tz {}
- (NSTimeZone *)timeZone  { return nil; }
- (void)setFirstWeekday:(NSUInteger)weekday {}
- (NSUInteger)firstWeekday { return 1; }
- (void)setMinimumDaysInFirstWeek:(NSUInteger)mdw {}
- (NSUInteger)minimumDaysInFirstWeek { return 1; }
- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit { return NSMakeRange(0,0); }
- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit { return NSMakeRange(0,0); }
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date { return NSMakeRange(0,0); }
- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date  { return 0; }

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date { return NO; }
- (NSDate *)dateFromComponents:(NSDateComponents *)comps { return nil; }
- (NSDateComponents *)components:(NSCalendarUnit)unitFlags fromDate:(NSDate *)date { return nil; }
- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSCalendarOptions)opts  { return nil; }
- (NSDateComponents *)components:(NSCalendarUnit)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSCalendarOptions)opts  { return nil; }

// TODO: Add stubs for these to shut the compiler up
// t -[NSCalendar AMSymbol]
// t -[NSCalendar PMSymbol]
// t -[NSCalendar compareDate:toDate:toUnitGranularity:]
// t -[NSCalendar component:fromDate:]
// t -[NSCalendar components:fromDateComponents:toDateComponents:options:]
// t -[NSCalendar componentsInTimeZone:fromDate:]
// t -[NSCalendar copyWithZone:]
// t -[NSCalendar date:matchesComponents:]
// t -[NSCalendar dateByAddingUnit:value:toDate:options:]
// t -[NSCalendar dateBySettingHour:minute:second:ofDate:options:]
// t -[NSCalendar dateBySettingUnit:value:ofDate:options:]
// t -[NSCalendar dateFromComponents:]
// t -[NSCalendar dateWithEra:year:month:day:hour:minute:second:nanosecond:]
// t -[NSCalendar dateWithEra:yearForWeekOfYear:weekOfYear:weekday:hour:minute:second:nanosecond:]
// t -[NSCalendar encodeWithCoder:]
// t -[NSCalendar enumerateDatesStartingAfterDate:matchingComponents:options:usingBlock:]
// t -[NSCalendar eraSymbols]
// t -[NSCalendar getEra:year:month:day:fromDate:]
// t -[NSCalendar getEra:yearForWeekOfYear:weekOfYear:weekday:fromDate:]
// t -[NSCalendar getHour:minute:second:nanosecond:fromDate:]
// t -[NSCalendar gregorianStartDate]
// t -[NSCalendar hash]
// t -[NSCalendar initWithCalendarIdentifier:]
// t -[NSCalendar initWithCoder:]
// t -[NSCalendar init]
// t -[NSCalendar isDate:equalToDate:toUnitGranularity:]
// t -[NSCalendar isDate:inSameDayAsDate:]
// t -[NSCalendar isDateInToday:]
// t -[NSCalendar isDateInTomorrow:]
// t -[NSCalendar isDateInWeekend:]
// t -[NSCalendar isDateInYesterday:]
// t -[NSCalendar isEqual:]
// t -[NSCalendar longEraSymbols]
// t -[NSCalendar monthSymbols]
// t -[NSCalendar nextDateAfterDate:matchingComponents:options:]
// t -[NSCalendar nextDateAfterDate:matchingHour:minute:second:options:]
// t -[NSCalendar nextDateAfterDate:matchingUnit:value:options:]
// t -[NSCalendar nextWeekendStartDate:interval:options:afterDate:]
// t -[NSCalendar quarterSymbols]
// t -[NSCalendar rangeOfWeekendStartDate:interval:containingDate:]
// t -[NSCalendar setGregorianStartDate:]
// t -[NSCalendar shortMonthSymbols]
// t -[NSCalendar shortQuarterSymbols]
// t -[NSCalendar shortStandaloneMonthSymbols]
// t -[NSCalendar shortStandaloneQuarterSymbols]
// t -[NSCalendar shortStandaloneWeekdaySymbols]
// t -[NSCalendar shortWeekdaySymbols]
// t -[NSCalendar standaloneMonthSymbols]
// t -[NSCalendar standaloneQuarterSymbols]
// t -[NSCalendar standaloneWeekdaySymbols]
// t -[NSCalendar startOfDayForDate:]
// t -[NSCalendar veryShortMonthSymbols]
// t -[NSCalendar veryShortStandaloneMonthSymbols]
// t -[NSCalendar veryShortStandaloneWeekdaySymbols]
// t -[NSCalendar veryShortWeekdaySymbols]
// t -[NSCalendar weekdaySymbols]

@end


#define SELF ((CFCalendarRef)self)

@interface __NSCFCalendar : NSCalendar
@end

@implementation __NSCFCalendar

-(CFTypeID)_cfTypeID {
    return CFCalendarGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CFStringRef identifier = CFCalendarGetIdentifier(SELF);
    return (id)CFCalendarCreateWithIdentifier(kCFAllocatorDefault, identifier);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

#pragma mark - instance methods

// TODO:
// t -[NSCalendar AMSymbol]
// t -[NSCalendar PMSymbol]
// t -[NSCalendar compareDate:toDate:toUnitGranularity:]
// t -[NSCalendar component:fromDate:]
// t -[NSCalendar components:fromDateComponents:toDateComponents:options:]
// t -[NSCalendar componentsInTimeZone:fromDate:]
// t -[NSCalendar copyWithZone:]
// t -[NSCalendar date:matchesComponents:]
// t -[NSCalendar dateByAddingUnit:value:toDate:options:]
// t -[NSCalendar dateBySettingHour:minute:second:ofDate:options:]
// t -[NSCalendar dateBySettingUnit:value:ofDate:options:]
// t -[NSCalendar dateFromComponents:]
// t -[NSCalendar dateWithEra:year:month:day:hour:minute:second:nanosecond:]
// t -[NSCalendar dateWithEra:yearForWeekOfYear:weekOfYear:weekday:hour:minute:second:nanosecond:]
// t -[NSCalendar encodeWithCoder:]
// t -[NSCalendar enumerateDatesStartingAfterDate:matchingComponents:options:usingBlock:]
// t -[NSCalendar eraSymbols]
// t -[NSCalendar getEra:year:month:day:fromDate:]
// t -[NSCalendar getEra:yearForWeekOfYear:weekOfYear:weekday:fromDate:]
// t -[NSCalendar getHour:minute:second:nanosecond:fromDate:]
// t -[NSCalendar gregorianStartDate]
// t -[NSCalendar hash]
// t -[NSCalendar initWithCalendarIdentifier:]
// t -[NSCalendar initWithCoder:]
// t -[NSCalendar init]
// t -[NSCalendar isDate:equalToDate:toUnitGranularity:]
// t -[NSCalendar isDate:inSameDayAsDate:]
// t -[NSCalendar isDateInToday:]
// t -[NSCalendar isDateInTomorrow:]
// t -[NSCalendar isDateInWeekend:]
// t -[NSCalendar isDateInYesterday:]
// t -[NSCalendar isEqual:]
// t -[NSCalendar longEraSymbols]
// t -[NSCalendar monthSymbols]
// t -[NSCalendar nextDateAfterDate:matchingComponents:options:]
// t -[NSCalendar nextDateAfterDate:matchingHour:minute:second:options:]
// t -[NSCalendar nextDateAfterDate:matchingUnit:value:options:]
// t -[NSCalendar nextWeekendStartDate:interval:options:afterDate:]
// t -[NSCalendar quarterSymbols]
// t -[NSCalendar rangeOfWeekendStartDate:interval:containingDate:]
// t -[NSCalendar setGregorianStartDate:]
// t -[NSCalendar shortMonthSymbols]
// t -[NSCalendar shortQuarterSymbols]
// t -[NSCalendar shortStandaloneMonthSymbols]
// t -[NSCalendar shortStandaloneQuarterSymbols]
// t -[NSCalendar shortStandaloneWeekdaySymbols]
// t -[NSCalendar shortWeekdaySymbols]
// t -[NSCalendar standaloneMonthSymbols]
// t -[NSCalendar standaloneQuarterSymbols]
// t -[NSCalendar standaloneWeekdaySymbols]
// t -[NSCalendar startOfDayForDate:]
// t -[NSCalendar veryShortMonthSymbols]
// t -[NSCalendar veryShortStandaloneMonthSymbols]
// t -[NSCalendar veryShortStandaloneWeekdaySymbols]
// t -[NSCalendar veryShortWeekdaySymbols]
// t -[NSCalendar weekdaySymbols]

- (NSString *)calendarIdentifier {
    return (id)CFCalendarGetIdentifier(SELF);
}

- (void)setLocale:(NSLocale *)locale {
    CFCalendarSetLocale(SELF, (CFLocaleRef)locale);
}

- (NSLocale *)locale {
    return (id)CFCalendarCopyLocale(SELF);
}

- (void)setTimeZone:(NSTimeZone *)tz {
    CFCalendarSetTimeZone(SELF, (CFTimeZoneRef)tz);
}

- (NSTimeZone *)timeZone {
    return [(id)CFCalendarCopyTimeZone(SELF) autorelease];
}

- (void)setFirstWeekday:(NSUInteger)weekday {
    CFCalendarSetFirstWeekday(SELF, weekday);
}

- (NSUInteger)firstWeekday {
    return CFCalendarGetFirstWeekday(SELF);
}

- (void)setMinimumDaysInFirstWeek:(NSUInteger)mdw {
    CFCalendarSetMinimumDaysInFirstWeek(SELF, mdw);
}

- (NSUInteger)minimumDaysInFirstWeek {
    return CFCalendarGetMinimumDaysInFirstWeek(SELF);
}

- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit {
    CFRange range = CFCalendarGetMinimumRangeOfUnit(SELF, unit);
    return NSMakeRange(range.location, range.length);
}

- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit {
    CFRange range = CFCalendarGetMaximumRangeOfUnit(SELF, unit);
    return NSMakeRange(range.location, range.length);
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date {
    CFRange range = CFCalendarGetRangeOfUnit(SELF, smaller, larger, CFDateGetAbsoluteTime((CFDateRef)date));
    return NSMakeRange(range.location, range.length);
}

- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date {
    return CFCalendarGetOrdinalityOfUnit(SELF, smaller, larger, CFDateGetAbsoluteTime((CFDateRef)date));
}

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date {
    CFAbsoluteTime time;
    BOOL result = CFCalendarGetTimeRangeOfUnit(SELF, unit, [date timeIntervalSinceReferenceDate], &time, tip);
    if (result) {
        *datep = (NSDate *)CFDateCreate(kCFAllocatorDefault, time);
    }
    return result;
}

// These call into un-advertised CFCalendar function exposed in an _unpatched_ CFLite
- (NSDate *)dateFromComponents:(NSDateComponents *)comps {
    // TODO: Requires NSDateComponents implementation
//    CFAbsoluteTime time;
//    char components[11];
//    NSUInteger values[10];
//    NSUInteger count = [(PFDateComponents *)comps _getComponents: components values: values];
//    if (count) {
//        if (_CFCalendarComposeAbsoluteTimeV(SELF, &time, components, (int *)values, count)) {
//            return (id)CFDateCreate(kCFAllocatorDefault, time);
//        }
//    }
    return nil;
}

- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSCalendarOptions)opts {
    // TODO: Requires NSDateComponents implementation
//    CFAbsoluteTime time = [date timeIntervalSinceReferenceDate];
//    char components[11];
//    NSUInteger values[10];
//    NSUInteger count = [(PFDateComponents *)comps _getComponents: components values: values];
//    if (count) {
//        if (_CFCalendarAddComponentsV(SELF, &time, opts, components, (int *)values, count)) {
//            return [(id)CFDateCreate(kCFAllocatorDefault, time) autorelease];
//        }
//    }
    return nil;
}

- (NSDateComponents *)components:(NSCalendarUnit)unitFlags fromDate:(NSDate *)date {
    // TODO: Requires NSDateComponents implementation
//    CFAbsoluteTime time = [date timeIntervalSinceReferenceDate];
//    char components[11];
//    NSUInteger values[10];
//    NSUInteger *vector[10] = { &values[0], &values[1], &values[2], &values[3], &values[4], &values[5], &values[6], &values[7], &values[8], &values[9] };
//
//    NSUInteger count = _PFGetDateComponents( components, unitFlags );
//    if (count) {
//        if (!_CFCalendarDecomposeAbsoluteTimeV(SELF, time, components, (int **)vector, count)) {
//            return nil;
//        }
//    }
//    return [[[PFDateComponents alloc] _initWithForFlags: unitFlags withComponents: components values: values count: count] autorelease];
    return nil;
}

- (NSDateComponents *)components:(NSCalendarUnit)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSCalendarOptions)opts {
    // TODO: Requires NSDateComponents implementation
//    CFAbsoluteTime start = [startingDate timeIntervalSinceReferenceDate];
//    CFAbsoluteTime end = [resultDate timeIntervalSinceReferenceDate];
//
//    char components[11];
//    NSUInteger values[10];
//    NSUInteger *vector[10] = { &values[0], &values[1], &values[2], &values[3], &values[4], &values[5], &values[6], &values[7], &values[8], &values[9] };
//
//    NSUInteger count = _PFGetDateComponents( components, unitFlags );
//
//    if (count) {
//        if (!_CFCalendarGetComponentDifferenceV(SELF, start, end, opts, components, (int **)vector, count)) {
//            return nil;
//        }
//    }
//    return [[[PFDateComponents alloc] _initWithForFlags: unitFlags withComponents: components values: values count: count] autorelease];
    return nil;
}

@end

#undef SELF


/*
00000000005d9580 S _OBJC_CLASS_$__NSAutoCalendar
00000000005da200 S _OBJC_METACLASS_$__NSAutoCalendar

00000000005d6770 S _OBJC_IVAR_$__NSAutoCalendar._lock
00000000005d6778 S _OBJC_IVAR_$__NSAutoCalendar.cal
00000000005d6790 S _OBJC_IVAR_$__NSAutoCalendar.changedFirstWeekday
00000000005d67a0 S _OBJC_IVAR_$__NSAutoCalendar.changedGregorianStartDate
00000000005d6780 S _OBJC_IVAR_$__NSAutoCalendar.changedLocale
00000000005d6798 S _OBJC_IVAR_$__NSAutoCalendar.changedMinimumDaysinFirstWeek
00000000005d6788 S _OBJC_IVAR_$__NSAutoCalendar.changedTimeZone
*/

/*
00000000005d83b0 s _OBJC_CLASS_$__NSCopyOnWriteCalendarWrapper
00000000005d83d8 s _OBJC_METACLASS_$__NSCopyOnWriteCalendarWrapper

00000000000e5980 t +[_NSCopyOnWriteCalendarWrapper currentCalendar]

00000000000df600 t -[_NSCopyOnWriteCalendarWrapper _copyWrappedCalendar]
00000000000b3f80 t -[_NSCopyOnWriteCalendarWrapper _initWithCalendar:]
00000000000b4000 t -[_NSCopyOnWriteCalendarWrapper _init]
00000000000ed7c0 t -[_NSCopyOnWriteCalendarWrapper calendarIdentifier]
00000000000de010 t -[_NSCopyOnWriteCalendarWrapper components:fromDate:]
00000000000e5ac0 t -[_NSCopyOnWriteCalendarWrapper components:fromDate:toDate:options:]
00000000000dddb0 t -[_NSCopyOnWriteCalendarWrapper copyWithZone:]
00000000000ef260 t -[_NSCopyOnWriteCalendarWrapper dateByAddingComponents:toDate:options:]
00000000000df7b0 t -[_NSCopyOnWriteCalendarWrapper dateFromComponents:]
00000000000b9220 t -[_NSCopyOnWriteCalendarWrapper dealloc]
00000000001a1a20 t -[_NSCopyOnWriteCalendarWrapper enumerateDatesStartingAfterDate:matchingComponents:options:usingBlock:]
00000000000ed870 t -[_NSCopyOnWriteCalendarWrapper firstWeekday]
00000000001a1580 t -[_NSCopyOnWriteCalendarWrapper gregorianStartDate]
00000000001a1890 t -[_NSCopyOnWriteCalendarWrapper hash]
00000000000f4b10 t -[_NSCopyOnWriteCalendarWrapper isDateInWeekend:]
00000000000ef050 t -[_NSCopyOnWriteCalendarWrapper locale]
00000000000f2890 t -[_NSCopyOnWriteCalendarWrapper maximumRangeOfUnit:]
00000000001a14d0 t -[_NSCopyOnWriteCalendarWrapper minimumDaysInFirstWeek]
00000000001a1700 t -[_NSCopyOnWriteCalendarWrapper minimumRangeOfUnit:]
00000000001a1940 t -[_NSCopyOnWriteCalendarWrapper nextWeekendStartDate:interval:options:afterDate:]
00000000001a17c0 t -[_NSCopyOnWriteCalendarWrapper ordinalityOfUnit:inUnit:forDate:]
0000000000101410 t -[_NSCopyOnWriteCalendarWrapper rangeOfUnit:inUnit:forDate:]
00000000000f04f0 t -[_NSCopyOnWriteCalendarWrapper rangeOfUnit:startDate:interval:forDate:]
00000000001a1330 t -[_NSCopyOnWriteCalendarWrapper setFirstWeekday:]
00000000001a1630 t -[_NSCopyOnWriteCalendarWrapper setGregorianStartDate:]
00000000000eeec0 t -[_NSCopyOnWriteCalendarWrapper setLocale:]
00000000001a1400 t -[_NSCopyOnWriteCalendarWrapper setMinimumDaysInFirstWeek:]
00000000000ddba0 t -[_NSCopyOnWriteCalendarWrapper setTimeZone:]
00000000000eefa0 t -[_NSCopyOnWriteCalendarWrapper timeZone]

00000000005d6768 s _OBJC_IVAR_$__NSCopyOnWriteCalendarWrapper._lock
00000000005d6758 s _OBJC_IVAR_$__NSCopyOnWriteCalendarWrapper.cal
00000000005d6760 s _OBJC_IVAR_$__NSCopyOnWriteCalendarWrapper.needsToCopy
*/

/*
00000000000b2f20 t ___24+[NSCalendar initialize]_block_invoke
00000000001a3220 t ___53-[NSCalendar dateBySettingUnit:value:ofDate:options:]_block_invoke
00000000001a2d10 t ___59-[NSCalendar nextDateAfterDate:matchingComponents:options:]_block_invoke
000000000018ba20 t ____NSCFCalendarLogger_block_invoke
*/
