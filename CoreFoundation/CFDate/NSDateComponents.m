//
//  NSDateComponents.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
00000000005d90f8 S _OBJC_CLASS_$_NSDateComponents
00000000005d9d78 S _OBJC_METACLASS_$_NSDateComponents

00000000000df170 t +[NSDateComponents allocWithZone:]
00000000000e5920 t +[NSDateComponents supportsSecureCoding]

00000000000df5f0 t -[NSDateComponents calendar]
000000000011ed20 t -[NSDateComponents copyWithZone:]
00000000000df730 t -[NSDateComponents date]
00000000000dffa0 t -[NSDateComponents day]
00000000000e0bb0 t -[NSDateComponents dealloc]
00000000001908d0 t -[NSDateComponents description]
000000000018ff10 t -[NSDateComponents encodeWithCoder:]
00000000000dfed0 t -[NSDateComponents era]
000000000018fd10 t -[NSDateComponents hash]
00000000000dffb0 t -[NSDateComponents hour]
000000000018ff00 t -[NSDateComponents initWithCoder:]
00000000000df180 t -[NSDateComponents init]
0000000000102d90 t -[NSDateComponents isEqual:]
000000000011f050 t -[NSDateComponents isLeapMonthSet]
00000000000dff70 t -[NSDateComponents isLeapMonth]
0000000000190390 t -[NSDateComponents isValidDateInCalendar:]
000000000018ff20 t -[NSDateComponents isValidDate]
00000000000dffc0 t -[NSDateComponents minute]
00000000000dff60 t -[NSDateComponents month]
00000000000dffe0 t -[NSDateComponents nanosecond]
00000000000dfee0 t -[NSDateComponents quarter]
00000000000dffd0 t -[NSDateComponents second]
00000000000df4c0 t -[NSDateComponents setCalendar:]
00000000000df4a0 t -[NSDateComponents setDay:]
00000000000e55e0 t -[NSDateComponents setEra:]
00000000000e5600 t -[NSDateComponents setHour:]
00000000000e5640 t -[NSDateComponents setLeapMonth:]
00000000000e5620 t -[NSDateComponents setMinute:]
00000000000df480 t -[NSDateComponents setMonth:]
000000000011efb0 t -[NSDateComponents setNanosecond:]
000000000011ef90 t -[NSDateComponents setQuarter:]
00000000000f02c0 t -[NSDateComponents setSecond:]
00000000000df560 t -[NSDateComponents setTimeZone:]
00000000001011c0 t -[NSDateComponents setValue:forComponent:]
000000000011efd0 t -[NSDateComponents setWeek:]
000000000011eff0 t -[NSDateComponents setWeekOfMonth:]
00000000000f4af0 t -[NSDateComponents setWeekOfYear:]
00000000000e6980 t -[NSDateComponents setWeekday:]
000000000011f030 t -[NSDateComponents setWeekdayOrdinal:]
00000000000df1f0 t -[NSDateComponents setYear:]
000000000011f010 t -[NSDateComponents setYearForWeekOfYear:]
00000000000df550 t -[NSDateComponents timeZone]
00000000000df210 t -[NSDateComponents valueForComponent:]
00000000000dff10 t -[NSDateComponents weekOfMonth]
00000000000dfef0 t -[NSDateComponents weekOfYear]
00000000000dff00 t -[NSDateComponents week]
00000000000dff50 t -[NSDateComponents weekdayOrdinal]
00000000000dff40 t -[NSDateComponents weekday]
00000000000dff20 t -[NSDateComponents yearForWeekOfYear]
00000000000df470 t -[NSDateComponents year]
*/

// Placeholder until we can import the SwiftFoundation reimplementation

@implementation NSDateComponents

- (instancetype)init {
    if (self = [super init]) {
        self.era = NSDateComponentUndefined;
        self.year = NSDateComponentUndefined;
        self.month = NSDateComponentUndefined;
        self.day = NSDateComponentUndefined;
        self.hour = NSDateComponentUndefined;
        self.minute = NSDateComponentUndefined;
        self.second = NSDateComponentUndefined;
        self.nanosecond = NSDateComponentUndefined;
        self.weekday = NSDateComponentUndefined;
        self.weekdayOrdinal = NSDateComponentUndefined;
        self.quarter = NSDateComponentUndefined;
        self.weekOfMonth = NSDateComponentUndefined;
        self.weekOfYear = NSDateComponentUndefined;
        self.yearForWeekOfYear = NSDateComponentUndefined;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone { return nil; }

- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

/*
 This API allows one to set a specific component of NSDateComponents, by enum constant value rather than property name.
 The calendar and timeZone and isLeapMonth properties cannot be set by this method.
 */
- (void)setValue:(NSInteger)value forComponent:(NSCalendarUnit)unit {
    
}

/*
 This API allows one to get the value of a specific component of NSDateComponents, by enum constant value rather than property name.
 The calendar and timeZone and isLeapMonth property values cannot be gotten by this method.
 */
- (NSInteger)valueForComponent:(NSCalendarUnit)unit {
    
}


/*
 Reports whether or not the combination of properties which have been set in the receiver is a date which exists in the calendar.
 This method is not appropriate for use on NSDateComponents objects which are specifying relative quantities of calendar components.
 Except for some trivial cases (e.g., 'seconds' should be 0 - 59 in any calendar), this method is not necessarily cheap.
 If the time zone property is set in the NSDateComponents object, it is used.
 The calendar property must be set, or NO is returned.
 */
//@property (getter=isValidDate, readonly) BOOL validDate NS_AVAILABLE(10_9, 8_0);
- (BOOL)isValidDate {
    return NO;
}


/*
 Reports whether or not the combination of properties which have been set in the receiver is a date which exists in the calendar.
 This method is not appropriate for use on NSDateComponents objects which are specifying relative quantities of calendar components.
 Except for some trivial cases (e.g., 'seconds' should be 0 - 59 in any calendar), this method is not necessarily cheap.
 If the time zone property is set in the NSDateComponents object, it is used.
 */
- (BOOL)isValidDateInCalendar:(NSCalendar *)calendar {
    
}

@end

