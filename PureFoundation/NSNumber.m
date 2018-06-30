//
//  NSNumber.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h> // for variable types

#define SELF    ((CFNumberRef)self)

@interface __NSCFNumber : NSNumber
@end

@implementation __NSCFNumber

// TODO:
// t +[__NSCFNumber automaticallyNotifiesObserversForKey:]
// t -[__NSCFNumber _cfNumberType]
// t -[__NSCFNumber isEqual:]
// t -[__NSCFNumber isNSNumber__]

-(CFTypeID)_cfTypeID {
    return CFNumberGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

// TODO: Check whether numbers are still kept unique by CF
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

-(NSString *)description {
    return (NSString *)CFCopyDescription(SELF);
}

// TODO: This needs re-writing when we get NSNumberFormatter
- (NSString *)descriptionWithLocale:(id)locale {
    SInt8 i8;
    SInt16 i16;
    SInt32 i32;
    SInt64 i64;
    Float32 f32;
    Float64 f64;
    CFStringRef string;
    
    // and here we should check for "special" number values eg. NaN, Inf
    
    // this is a bit long-winded, but I wanted to be sure...
    switch(CFNumberGetType((CFNumberRef)self)) {
        case kCFNumberSInt8Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt8Type, &i8);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%hhi"), i8 );
            break;
        case kCFNumberSInt16Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt16Type, &i16);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%hi"), i16 );
            break;
        case kCFNumberSInt32Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt32Type, &i32);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%i"), (int)i32 );
            break;
        case kCFNumberSInt64Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt64Type, &i64);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%lli"), i64 );
            break;
        case kCFNumberFloat32Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberFloat32Type, &f32);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%.3f"), f32 );
            break;
        case kCFNumberFloat64Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberFloat64Type, &f64);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%.8lf"), f64 );
            break;
            
        default:
            return @"";
    }
    return [(id)string autorelease];
}

- (void)getValue:(void *)value {
    CFNumberGetValue(SELF, CFNumberGetType(SELF), value);
}

// These assume that PureFoundation will only ever be built for 64bit
- (const char *)objCType {
    switch (CFNumberGetType(SELF)) {
        case kCFNumberCharType:
        case kCFNumberSInt8Type:
            return @encode(char);
            
        case kCFNumberShortType:
        case kCFNumberSInt16Type:
            return @encode(short);
            
        case kCFNumberIntType:
        case kCFNumberSInt32Type:
            return @encode(int);
            
        case kCFNumberLongType:
            return @encode(long);
            
        case kCFNumberCFIndexType:
        case kCFNumberNSIntegerType:
        case kCFNumberLongLongType:
        case kCFNumberSInt64Type:
            return @encode(long long);
            
        case kCFNumberFloatType:
        case kCFNumberFloat32Type:
            return @encode(float);
            
        case kCFNumberDoubleType:
        case kCFNumberFloat64Type:
        case kCFNumberCGFloatType:
            return @encode(double);
    }
    return "?";
}

- (char)charValue {
    char value;
    CFNumberGetValue(SELF, kCFNumberCharType, &value);
    return value;
}

- (unsigned char)unsignedCharValue {
    unsigned char value;
    CFNumberGetValue(SELF, kCFNumberCharType, &value);
    return value;
}

- (short)shortValue {
    short value;
    CFNumberGetValue(SELF, kCFNumberShortType, &value);
    return value;
}

- (unsigned short)unsignedShortValue {
    unsigned short value;
    CFNumberGetValue(SELF, kCFNumberShortType, &value);
    return value;
}

- (int)intValue {
    int value;
    CFNumberGetValue(SELF, kCFNumberIntType, &value);
    return value;
}

- (unsigned int)unsignedIntValue {
    unsigned int value;
    CFNumberGetValue(SELF, kCFNumberIntType, &value);
    return value;
}

- (long)longValue {
    long value;
    CFNumberGetValue(SELF, kCFNumberLongType, &value);
    return value;
}

- (unsigned long)unsignedLongValue {
    unsigned long value;
    CFNumberGetValue(SELF, kCFNumberLongType, &value);
    return value;
}

- (long long)longLongValue {
    long long value;
    CFNumberGetValue(SELF, kCFNumberLongLongType, &value);
    return value;
}

- (unsigned long long)unsignedLongLongValue {
    unsigned long long value;
    CFNumberGetValue(SELF, kCFNumberLongLongType, &value);
    return value;
}

- (float)floatValue {
    float value;
    CFNumberGetValue(SELF, kCFNumberFloatType, &value);
    return value;
}

- (double)doubleValue {
    double value;
    CFNumberGetValue(SELF, kCFNumberDoubleType, &value);
    return value;
}

- (BOOL)boolValue {
    int value;
    CFNumberGetValue(SELF, kCFNumberIntType, &value);
    return value ? YES : NO;
}

- (NSInteger)integerValue {
    NSInteger value;
    CFNumberGetValue(SELF, kCFNumberNSIntegerType, &value);
    return value;
}

- (NSUInteger)unsignedIntegerValue {
    NSUInteger value;
    CFNumberGetValue(SELF, kCFNumberNSIntegerType, &value);
    return value;
}

- (NSString *)stringValue {
    return [self descriptionWithLocale:nil];
}

- (NSComparisonResult)compare:(NSNumber *)otherNumber {
    return CFNumberCompare(SELF, (CFNumberRef)otherNumber, NULL);
}

- (BOOL)isEqualToNumber:(NSNumber *)number {
    if (!number) return NO;
    return (self == number) || (CFNumberCompare(SELF, (CFNumberRef)number, NULL) == kCFCompareEqualTo);
}

// TODO
//- (NSDecimal)decimalValue {}

@end

@interface __NSCFBoolean : NSNumber
@end

@implementation __NSCFBoolean

// TODO
// t +[__NSCFBoolean automaticallyNotifiesObserversForKey:]
// t -[__NSCFBoolean _cfNumberType]
// t -[__NSCFBoolean _getValue:forType:]
// t -[__NSCFBoolean getValue:]
// t -[__NSCFBoolean isEqual:]
// t -[__NSCFBoolean isEqualToNumber:]

- (CFTypeID)_cfTypeID {
    return CFBooleanGetTypeID();
}

//Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (id)copyWithZone:(NSZone *)zone {
    return self; // because these are constants
}

- (const char *)objCType {
    return @encode(unsigned char);
}

- (char)charValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned char)unsignedCharValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (short)shortValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned short)unsignedShortValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (int)intValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned int)unsignedIntValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (long)longValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned long)unsignedLongValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (long long)longLongValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned long long)unsignedLongLongValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (float)floatValue { return (self == (id)kCFBooleanTrue) ? 1.0 : 0.0; }
- (double)doubleValue { return (self == (id)kCFBooleanTrue) ? 1.0 : 0.0; }
- (NSInteger)integerValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (NSUInteger)unsignedIntegerValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (BOOL)boolValue { return self == (id)kCFBooleanTrue; }

- (NSString *)stringValue { return self == (id)kCFBooleanTrue ? @"1" : @"0"; }
- (NSString *)description { return self == (id)kCFBooleanTrue ? @"1" : @"0"; }
- (NSString *)descriptionWithLocale:(id)locale {
    return self == (id)kCFBooleanTrue ? @"1" : @"0";
}

#pragma mark - NSDecimalNumberExtensions

- (NSDecimal)decimalValue { }

@end

#undef SELF
