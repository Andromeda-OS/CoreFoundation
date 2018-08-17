//
//  NSLocale.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForFoundationOnly.h"

// TODO: Ensure that these are implemented somewhere
// S _NSLocaleMeasurementSystemMetric
// S _NSLocaleMeasurementSystemUK
// S _NSLocaleMeasurementSystemUS


@implementation NSLocale

#pragma mark - init methods

- (instancetype)init {
    free(self);
    return nil; // This is what Foundation does
}

- (id)initWithLocaleIdentifier:(NSString *)string {
    free(self);
    return (id)CFLocaleCreate(kCFAllocatorDefault, (CFStringRef)string);
}

#pragma mark - factory methods

+ (id)systemLocale {
    return (id)CFLocaleGetSystem();
}

+ (id)currentLocale {
    return [(id)CFLocaleCopyCurrent() autorelease];
}

+ (NSArray *)availableLocaleIdentifiers {
    return [(id)CFLocaleCopyAvailableLocaleIdentifiers() autorelease];
}

+ (NSArray *)ISOLanguageCodes {
    return [(id)CFLocaleCopyISOLanguageCodes() autorelease];
}

+ (NSArray *)ISOCountryCodes {
    return [(id)CFLocaleCopyISOCountryCodes() autorelease];
}

+ (NSArray *)ISOCurrencyCodes {
    return [(id)CFLocaleCopyISOCurrencyCodes() autorelease];
}

+ (NSArray *)commonISOCurrencyCodes {
    return [(id)CFLocaleCopyCommonISOCurrencyCodes() autorelease];
}

+ (NSArray *)preferredLanguages {
    return [(id)CFLocaleCopyPreferredLanguages() autorelease];
}

+ (NSDictionary *)componentsFromLocaleIdentifier:(NSString *)string {
    return [(id)CFLocaleCreateComponentsFromLocaleIdentifier(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

+ (NSString *)localeIdentifierFromComponents:(NSDictionary *)dict {
    return [(id)CFLocaleCreateLocaleIdentifierFromComponents(kCFAllocatorDefault, (CFDictionaryRef)dict) autorelease];
}

+ (NSString *)canonicalLocaleIdentifierFromString:(NSString *)string {
    return [(id)CFLocaleCreateCanonicalLocaleIdentifierFromString(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

// TODO:
// t +[NSLocale canonicalLanguageIdentifierFromString:]
// t +[NSLocale characterDirectionForLanguage:]
// t +[NSLocale internetServicesRegion]
// t +[NSLocale lineDirectionForLanguage:]
// t +[NSLocale localeIdentifierFromComponents:]
// t +[NSLocale localeIdentifierFromWindowsLocaleCode:]
// t +[NSLocale localeWithLocaleIdentifier:]
// t +[NSLocale windowsLocaleCodeFromLocaleIdentifier:]

#pragma mark - instance method prototypes

- (NSString *)localeIdentifier { return nil; }
- (id)objectForKey:(id)key { return nil; }
- (NSString *)displayNameForKey:(id)key value:(id)value { return nil; }

// TODO: Stub these
// t -[NSLocale alternateQuotationBeginDelimiter]
// t -[NSLocale alternateQuotationEndDelimiter]
// t -[NSLocale calendarIdentifier]
// t -[NSLocale collationIdentifier]
// t -[NSLocale collatorIdentifier]
// t -[NSLocale copyWithZone:]
// t -[NSLocale countryCode]
// t -[NSLocale currencyCode]
// t -[NSLocale currencySymbol]
// t -[NSLocale decimalSeparator]
// t -[NSLocale encodeWithCoder:]
// t -[NSLocale exemplarCharacterSet]
// t -[NSLocale groupingSeparator]
// t -[NSLocale hash]
// t -[NSLocale identifier]
// t -[NSLocale isEqual:]
// t -[NSLocale languageCode]
// t -[NSLocale localizedStringForAlternateQuotationBeginDelimiter:]
// t -[NSLocale localizedStringForAlternateQuotationEndDelimiter:]
// t -[NSLocale localizedStringForCalendarIdentifier:]
// t -[NSLocale localizedStringForCollationIdentifier:]
// t -[NSLocale localizedStringForCollatorIdentifier:]
// t -[NSLocale localizedStringForCountryCode:]
// t -[NSLocale localizedStringForCurrencyCode:]
// t -[NSLocale localizedStringForCurrencySymbol:]
// t -[NSLocale localizedStringForDecimalSeparator:]
// t -[NSLocale localizedStringForGroupingSeparator:]
// t -[NSLocale localizedStringForLanguageCode:]
// t -[NSLocale localizedStringForLocaleIdentifier:]
// t -[NSLocale localizedStringForQuotationBeginDelimiter:]
// t -[NSLocale localizedStringForQuotationEndDelimiter:]
// t -[NSLocale localizedStringForScriptCode:]
// t -[NSLocale localizedStringForVariantCode:]
// t -[NSLocale quotationBeginDelimiter]
// t -[NSLocale quotationEndDelimiter]
// t -[NSLocale scriptCode]
// t -[NSLocale usesMetricSystem]
// t -[NSLocale variantCode]

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end


#define SELF ((CFLocaleRef)self)

@interface __NSCFLocale : NSLocale
@end

@implementation __NSCFLocale

-(CFTypeID)_cfTypeID {
    return CFLocaleGetTypeID();
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFLocaleCreateCopy(kCFAllocatorDefault, SELF);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

#pragma mark - instance methods

- (id)objectForKey:(id)key {
    return (id)CFLocaleGetValue(SELF, (CFStringRef)key);
}

- (NSString *)displayNameForKey:(id)key value:(id)value {
    return [(id)CFLocaleCopyDisplayNameForPropertyValue(SELF, (CFStringRef)key, (CFStringRef)value) autorelease];
}

- (NSString *)localeIdentifier {
    return (id)CFLocaleGetIdentifier(SELF);
}

// TODO: Stub these
// t -[NSLocale alternateQuotationBeginDelimiter]
// t -[NSLocale alternateQuotationEndDelimiter]
// t -[NSLocale calendarIdentifier]
// t -[NSLocale collationIdentifier]
// t -[NSLocale collatorIdentifier]
// t -[NSLocale copyWithZone:]
// t -[NSLocale countryCode]
// t -[NSLocale currencyCode]
// t -[NSLocale currencySymbol]
// t -[NSLocale decimalSeparator]
// t -[NSLocale encodeWithCoder:]
// t -[NSLocale exemplarCharacterSet]
// t -[NSLocale groupingSeparator]
// t -[NSLocale hash]
// t -[NSLocale identifier]
// t -[NSLocale isEqual:]
// t -[NSLocale languageCode]
// t -[NSLocale localizedStringForAlternateQuotationBeginDelimiter:]
// t -[NSLocale localizedStringForAlternateQuotationEndDelimiter:]
// t -[NSLocale localizedStringForCalendarIdentifier:]
// t -[NSLocale localizedStringForCollationIdentifier:]
// t -[NSLocale localizedStringForCollatorIdentifier:]
// t -[NSLocale localizedStringForCountryCode:]
// t -[NSLocale localizedStringForCurrencyCode:]
// t -[NSLocale localizedStringForCurrencySymbol:]
// t -[NSLocale localizedStringForDecimalSeparator:]
// t -[NSLocale localizedStringForGroupingSeparator:]
// t -[NSLocale localizedStringForLanguageCode:]
// t -[NSLocale localizedStringForLocaleIdentifier:]
// t -[NSLocale localizedStringForQuotationBeginDelimiter:]
// t -[NSLocale localizedStringForQuotationEndDelimiter:]
// t -[NSLocale localizedStringForScriptCode:]
// t -[NSLocale localizedStringForVariantCode:]
// t -[NSLocale quotationBeginDelimiter]
// t -[NSLocale quotationEndDelimiter]
// t -[NSLocale scriptCode]
// t -[NSLocale usesMetricSystem]
// t -[NSLocale variantCode]

@end

#undef SELF

/*
00000000001b73c0 t -[_NSPlaceholderLocale autorelease]
0000000000042980 t -[_NSPlaceholderLocale initWithLocaleIdentifier:]
00000000001b73b0 t -[_NSPlaceholderLocale release]
00000000001b73a0 t -[_NSPlaceholderLocale retain]

00000000005d8608 s _OBJC_CLASS_$__NSPlaceholderLocale
00000000005d85e0 s _OBJC_METACLASS_$__NSPlaceholderLocale
*/
