//
//  NSString.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PureFoundation.h"

// Hmm... NSString and NSMutableString are implemented in Foundation, but the bridged class __NSCFString is implemented here

#define SELF ((CFStringRef)self)
#define MSELF ((CFMutableStringRef)self)

#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)

@interface __NSCFString : NSMutableString
@end

@implementation __NSCFString

// TODO:
// t +[__NSCFString automaticallyNotifiesObserversForKey:]
// t -[__NSCFString appendCharacters:length:]
// t -[__NSCFString isEqual:]

- (CFTypeID)_cfTypeID {
    return CFStringGetTypeID();
}

- (BOOL)isNSString__ {
    return YES;
}

// TODO: implement -classForCoder

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)description {
    return [(id)CFRetain(SELF) autorelease];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFStringCreateCopy(kCFAllocatorDefault, SELF);
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return (id)CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // TODO: Implement this
    return nil;
}


#pragma mark - File operations

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error {
    // TODO
    return false;
}

- (BOOL)writeToFile:(NSString *)path
         atomically:(BOOL)useAuxiliaryFile
           encoding:(NSStringEncoding)enc
              error:(NSError **)error
{
    if( path == nil ) return NO;
    
    CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
    // set error is encoding isn't available...
    NSData *data = (NSData *)CFStringCreateExternalRepresentation( kCFAllocatorDefault, (CFStringRef)self, cf_enc, 0 );
    // set error if creating data failed...
    BOOL result = [data writeToFile: path atomically: useAuxiliaryFile];
    // set error if writing failed...
    [data release];
    return result;
}

- (id)propertyList {
    // TODO: Check whether this works at all
    
    // covert the string into a data object
    NSData *data = (NSData *)CFStringCreateExternalRepresentation( kCFAllocatorDefault, (CFStringRef)self, kCFStringEncodingUTF8, 0 );
    if( data == nil )
        [NSException raise: NSParseErrorException format:@"TODO"];
    
    id plist = [NSPropertyListSerialization propertyListFromData: data mutabilityOption: NSPropertyListImmutable format:NULL errorDescription: NULL];
    if( plist == nil )
        [NSException raise: NSParseErrorException format:@"TODO"];
    
    [data release];
    return [plist autorelease];
}

- (NSDictionary *)propertyListFromStringsFileFormat { }

#pragma mark - primatives

// TODO: We could comment out all the other methods and if we've implemented NSString and NSMutableString right they should work the same

- (NSUInteger)length {
    return (CFStringGetLength(SELF));
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return CFStringGetCharacterAtIndex(SELF, (CFIndex)index);
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    CFRange r = CFRangeMake( range.location, range.length );
    
    CFStringReplace( (CFMutableStringRef)self, r, (CFStringRef)aString);
}

#pragma mark - string manipulation

- (void)getCharacters:(unichar *)buffer {
    NSRange aRange = NSMakeRange( 0, [self length] );
    [self getCharacters: buffer range: aRange];
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange {
    
    // should check that aRange is valid and raise NSRangeException if it isn't
    NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
    if( length == 0 ) return;
    
    if( (aRange.location >= length) || ((aRange.location+aRange.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange range = CFRangeMake( aRange.location, aRange.length );
    CFStringGetCharacters( (CFStringRef)self, range, buffer );
}

- (NSString *)substringFromIndex:(NSUInteger)from {
    NSUInteger length = [self length];
    if( from >= length )
        [NSException raise: NSRangeException format:@"TODO"];
    
    NSRange range = NSMakeRange( from, (length-from) );
    return [self substringWithRange: range];
}

- (NSString *)substringToIndex:(NSUInteger)to {
    if( to >= ([self length]-1) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    NSRange range = NSMakeRange( 0, to );
    return [self substringWithRange: range];
}

- (NSString *)substringWithRange:(NSRange)range {
    NSUInteger length = [self length];
    if( (range.location >= length) || ((range.location + range.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange cf_range = CFRangeMake( range.location, range.length );
    
    return [(id)CFStringCreateWithSubstring(kCFAllocatorDefault, SELF, cf_range) autorelease];
}

#pragma mark - Comparison functions

- (NSComparisonResult)compare:(NSString *)string {
    CFStringCompare(SELF, (CFStringRef)string, 0);
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask {
    CFStringCompare(SELF, (CFStringRef)string, mask);
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange {
    NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
    if( (compareRange.location >= length) || ((compareRange.location+compareRange.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    CFRange range = CFRangeMake( compareRange.location, compareRange.length );
    
    // check option flags, restricting to the 3 allowed methods (although I'm not 100% sue that CF
    //        supports the literal search option...
    mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSNumericSearch);
    
    return CFStringCompareWithOptions(SELF, (CFStringRef)string, range, mask);
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange locale:(id)locale
{
    NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
    if( (compareRange.location >= length) || ((compareRange.location+compareRange.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    CFRange range = CFRangeMake( compareRange.location, compareRange.length );
    
    // check option flags, restricting to the 3 allowed methods (although I'm not 100% sue that CF
    //        supports the literal search option...
    mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSNumericSearch);
    
    // check locale, but allow through a dictionary
    if(locale == nil) locale = (NSLocale *)CFLocaleCopyCurrent();
    
    return CFStringCompareWithOptionsAndLocale( (CFStringRef)self, (CFStringRef)string, range, mask, (CFLocaleRef)locale);
}

- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string {
    return CFStringCompare(SELF, (CFStringRef)string, kCFCompareCaseInsensitive);
}

- (NSComparisonResult)localizedCompare:(NSString *)string {
    CFRange range = CFRangeMake(0, CFStringGetLength(SELF));
    return CFStringCompareWithOptionsAndLocale(SELF, (CFStringRef)string, range, 0, NULL);
}

- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string {
    CFRange range = CFRangeMake(0, CFStringGetLength(SELF));
    return CFStringCompareWithOptionsAndLocale(SELF, (CFStringRef)string, range, kCFCompareCaseInsensitive, NULL);
}

- (BOOL)isEqualToString:(NSString *)aString {
    if( self == aString ) return YES;
    if( aString == nil ) return NO;
    return ( kCFCompareEqualTo == CFStringCompare((CFStringRef)self, (CFStringRef)aString, 0 ) );
}

- (BOOL)hasPrefix:(NSString *)aString {
    return CFStringHasPrefix(SELF, (CFStringRef)aString);
}

- (BOOL)hasSuffix:(NSString *)aString {
    return CFStringHasSuffix(SELF, (CFStringRef)aString);
}


- (NSRange)rangeOfString:(NSString *)aString {
    if( aString == nil )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    return [self rangeOfString: aString options: 0];
}

- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask {
    if( aString == nil )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    
    NSRange range = NSMakeRange( 0, [self length] );
    
    return [self rangeOfString: aString options: mask range: range];
}

- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange {

    if( aString == nil )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    
    // check that searchRange is valid
    NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
    if( length == 0 )
        return NSMakeRange( NSNotFound, 0 );
    
    if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange range = CFRangeMake( searchRange.location, searchRange.length );
    
    // set the mask to only allow allowed options
    mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSBackwardsSearch | NSAnchoredSearch);
    
    CFRange result;
    
    if( TRUE == CFStringFindWithOptions( (CFStringRef)self, (CFStringRef)aString, range, mask, &result ) )
        return NSMakeRange( result.location, result.length );
    else
        return NSMakeRange( NSNotFound, 0 );
}

- (NSRange)rangeOfString:(NSString *)aString
                 options:(NSStringCompareOptions)mask
                   range:(NSRange)searchRange
                  locale:(NSLocale *)locale
{
    if( aString == nil )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    
    // check that searchRange is valid
    NSUInteger length =  CFStringGetLength((CFStringRef)self); //[self length];
    if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) >= length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange range = CFRangeMake( searchRange.location, searchRange.length );
    
    // set the mask to only allow allowed options
    mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSBackwardsSearch | NSAnchoredSearch);
    
    // check and set the locale
    if( locale == nil ) locale = (NSLocale *)CFLocaleCopyCurrent();
    
    CFRange result;
    
    if( TRUE == CFStringFindWithOptionsAndLocale( (CFStringRef)self, (CFStringRef)aString, range, mask, (CFLocaleRef) locale, &result ) )
        return NSMakeRange( result.location, result.length );
    else
        return NSMakeRange( NSNotFound, 0 );
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet {
    if( aSet == nil )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    
    return [self rangeOfCharacterFromSet: aSet options: 0];
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask {
    if( aSet == nil )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    
    NSRange range = NSMakeRange( 0, [self length] );
    
    return [self rangeOfCharacterFromSet: aSet options: 0 range: range];
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet
                           options:(NSStringCompareOptions)mask
                             range:(NSRange)searchRange
{
    if( aSet == nil )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    
    // checks that searchRange is valid
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) >= length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange range = CFRangeMake( searchRange.location, searchRange.length );
    
    mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSBackwardsSearch);
    
    CFRange result;
    
    if( TRUE == CFStringFindCharacterFromSet( (CFStringRef)self, (CFCharacterSetRef)aSet, range, mask, &result ) )
        return NSMakeRange( result.location, result.length );
    else
        return NSMakeRange( NSNotFound, 0 );
}

- (NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index {
    if( index >= CFStringGetLength((CFStringRef)self) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange range = CFStringGetRangeOfComposedCharactersAtIndex( (CFStringRef)self, index );
    return NSMakeRange( range.location, range.length );
}

- (NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range {
    
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) >= length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange range1 = CFStringGetRangeOfComposedCharactersAtIndex( (CFStringRef)self, range.location );
    CFRange range2 = CFStringGetRangeOfComposedCharactersAtIndex( (CFStringRef)self, (range.location + range.length) );
    
    return NSMakeRange( range1.location, ((range2.location+range2.length)-range1.location) );
}

- (NSString *)stringByAppendingString:(NSString *)aString {
    
    NSUInteger length1 = CFStringGetLength((CFStringRef)self);
    NSUInteger length2 = [aString length];
    
    unichar buffer[length1+length2];
    
    CFStringGetCharacters( (CFStringRef)self, CFRangeMake(0, length1), buffer );
    [aString getCharacters: buffer+length1];
    
    return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer, length1+length2) autorelease];
}

- (NSString *)stringByAppendingFormat:(NSString *)format, ... {
    
    va_list arguments;
    va_start( arguments, format );
    
    CFStringRef aString = CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, arguments );
    
    va_end( arguments );
    
    NSUInteger length1 = CFStringGetLength((CFStringRef)self);
    NSUInteger length2 = CFStringGetLength((CFStringRef)aString);
    
    unichar buffer[length1+length2];
    
    CFStringGetCharacters( (CFStringRef)self, CFRangeMake(0, length1), buffer );
    CFStringGetCharacters( (CFStringRef)aString, CFRangeMake(0, length2), buffer+length1 );
    
    CFStringRef new = CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, length1+length2 );
    
    [(id)aString release];
    
    return [(id)new autorelease];
}

- (double)doubleValue {
    return CFStringGetDoubleValue(SELF);
}

- (float)floatValue {
    return (float)CFStringGetDoubleValue(SELF);
}

- (int)intValue {
    return CFStringGetIntValue(SELF);
}

- (NSInteger)integerValue {
    return CFStringGetIntValue(SELF);
}

- (long long)longLongValue {
    return CFStringGetIntValue(SELF);
}

- (BOOL)boolValue {
    // TODO: Check that this makes sense
    
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( length == 0 ) return NO;
    
    CFCharacterSetRef cset = CFCharacterSetGetPredefined( kCFCharacterSetWhitespace );
    
    CFStringInlineBuffer *buffer;
    CFRange range = CFRangeMake(0, length);
    CFStringInitInlineBuffer( (CFStringRef)self, buffer, range );
    NSUInteger index = 0;
    unichar c = CFStringGetCharacterFromInlineBuffer( buffer, index++ );
    
    while( CFCharacterSetIsCharacterMember( cset, c ) )
        c = CFStringGetCharacterFromInlineBuffer( buffer, index++ );
    
    //if( (c == '+') || (c == '-') )
    
    if( (c == 'Y') || (c == 'y') || (c == 'T') || (c == 't') || (c == '1') || (c == '2') || (c == '3') || (c == '4') || (c == '5') || (c == '6') || (c == '7') || (c == '8') || (c == '9') ) return YES;
    
    return NO;
}

- (NSArray *)componentsSeparatedByString:(NSString *)separator {
    return [(id)CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault, SELF, (CFStringRef)separator) autorelease];
}

- (NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator {
    // TODO
    return nil;
}

- (NSString *)commonPrefixWithString:(NSString *)aString options:(NSStringCompareOptions)mask {
    // TODO
    return nil;
}

- (NSString *)uppercaseString {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringUppercase(string, NULL);
    return [(id)string autorelease];
}

- (NSString *)lowercaseString {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringLowercase(string, NULL);
    return [(id)string autorelease];
}

- (NSString *)capitalizedString {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringCapitalize(string, NULL);
    return [(id)string autorelease];
}

- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set {
    
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( length == 0 ) return [NSString string];
    unichar sbuf[length];
    
    unichar *buffer = (unichar *)CFStringGetCharactersPtr((CFStringRef)self);
    if( buffer == NULL )
    {
        CFRange range = CFRangeMake(0, length);
        CFStringGetCharacters( (CFStringRef)self, range, sbuf );
        buffer = sbuf;
    }
    
    NSUInteger start, end;
    
    for( start = 0; start < length; start++ )
        if( !CFCharacterSetIsCharacterMember( (CFCharacterSetRef)set, buffer[start] ) )
            break;
    
    if( start == length ) return [NSString string];
    
    for( end = --length; length > 0; end-- )
        if( !CFCharacterSetIsCharacterMember( (CFCharacterSetRef)set, buffer[end] ) )
            break;
    
    if( end == 0 ) return [NSString string];
    
    return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer+start, end-start+1) autorelease];
}

- (NSString *)stringByPaddingToLength:(NSUInteger)newLength
                           withString:(NSString *)padString
                      startingAtIndex:(NSUInteger)padIndex
{
    // check that padIndex is valid
    if (padIndex >= CFStringGetLength(SELF)) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    
    // create a mutable copy of self to work with
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringPad(string, (CFStringRef)padString, newLength, padIndex);
    return [(id)string autorelease];
}

// line and paragraph extents

- (void)getLineStart:(NSUInteger *)startPtr
                 end:(NSUInteger *)lineEndPtr
         contentsEnd:(NSUInteger *)contentsEndPtr
            forRange:(NSRange)range
{
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) >= length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange r = CFRangeMake( range.location, range.length );
    CFStringGetLineBounds((CFStringRef)self, r, (CFIndex *)startPtr, (CFIndex *)lineEndPtr, (CFIndex *)contentsEndPtr);
}

- (NSRange)lineRangeForRange:(NSRange)range {
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) >= length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFIndex start, end;
    CFRange r = CFRangeMake( range.location, range.length );
    CFStringGetLineBounds( (CFStringRef)self, r, &start, &end, NULL );
    return NSMakeRange( start, end-start+1 );
}

- (void)getParagraphStart:(NSUInteger *)startPtr
                      end:(NSUInteger *)parEndPtr
              contentsEnd:(NSUInteger *)contentsEndPtr
                 forRange:(NSRange)range
{
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) >= length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange r = CFRangeMake( range.location, range.length );
    CFStringGetParagraphBounds( (CFStringRef)self, r, (CFIndex *)startPtr, (CFIndex *)parEndPtr, (CFIndex *)contentsEndPtr );
}

- (NSRange)paragraphRangeForRange:(NSRange)range {
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) >= length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFIndex start, end;
    CFRange r = CFRangeMake( range.location, range.length );
    CFStringGetParagraphBounds( (CFStringRef)self, r, &start, &end, NULL );
    return NSMakeRange( start, end-start+1 );
}

#pragma mark - Encoding methods

- (NSStringEncoding)fastestEncoding {
    CFStringEncoding encoding = CFStringGetFastestEncoding(SELF);
    return CFStringConvertEncodingToNSStringEncoding(encoding);
}

- (NSStringEncoding)smallestEncoding {
    CFStringEncoding encoding = CFStringGetSmallestEncoding(SELF);
    return CFStringConvertEncodingToNSStringEncoding(encoding);
}

// External representation
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy {
    
    // check whether we can honour lossy
    //if( (lossy == NO) && ([self canBeConvertedToEncoding: encoding] == NO) ) return nil;
    
    // set the lossByte according to lossy, meaning it will return NULL if lossy encoding is attempted
    UInt8 lossByte = lossy ? '?' : 0; // need to find out what Founation uses here
    
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    
    return [(id)CFStringCreateExternalRepresentation(kCFAllocatorDefault, SELF, enc, lossByte) autorelease];
}

// External representation
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding {
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    return [(id)CFStringCreateExternalRepresentation(kCFAllocatorDefault, SELF, enc, 0) autorelease];
}

- (BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding {
    // TODO
    //CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    return YES;
}

- (const char *)UTF8String {
    // TODO: This needs to return a buffer which we are responsible for fixing
    NSUInteger size = CFStringGetMaximumSizeForEncoding( CFStringGetLength((CFStringRef)self), kCFStringEncodingUTF8 );
    char *buffer = malloc(size);
    
    if( CFStringGetCString( (CFStringRef)self, buffer, size, kCFStringEncodingUTF8 ) ) return buffer;
    
    free(buffer);
    return NULL;
}

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding {
    // until we fix -lengthOfBytesUsingEncoding this will be the maximum
    NSUInteger size = [self lengthOfBytesUsingEncoding: encoding] + 1; // space for \n
    
    char *buffer = malloc( size );
    
    if( [self getCString: buffer maxLength: size encoding: encoding] ) return buffer;
    
    free(buffer);
    return NULL;
}

- (BOOL)getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(NSStringEncoding)encoding {
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    return CFStringGetCString( (CFStringRef)self, buffer, (CFIndex)maxBufferCount, enc );
}

- (BOOL)getBytes:(void *)buffer
       maxLength:(NSUInteger)maxBufferCount
      usedLength:(NSUInteger *)usedBufferCount
        encoding:(NSStringEncoding)encoding
         options:(NSStringEncodingConversionOptions)options
           range:(NSRange)range
  remainingRange:(NSRangePointer)leftover
{
    // check that range is valid
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    // convert NSRane range into a CFRange
    CFRange r = CFRangeMake( range.location, range.length );
    
    // convert the encoding
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    
    // interpret the NSStringEncodingConversionOptions in options
    UInt8 lossByte = (options & NSStringEncodingConversionAllowLossy) ? '?' : 0;
    Boolean xRep = (options & NSStringEncodingConversionExternalRepresentation);
    
    CFIndex result = CFStringGetBytes( (CFStringRef)self, r, enc, lossByte, xRep, (UInt8 *)buffer, (CFIndex)maxBufferCount, (CFIndex *)usedBufferCount );
    return (result == 0) ? NO : YES;
}

/*
 *    "These return the maximum and exact number of bytes needed to store the receiver in the
 *    specified encoding in non-external representation. The first one is O(1), while the second
 *    one is O(n). These do not include space for a terminating null."
 */
- (NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)enc
{
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(enc);
    return (NSUInteger)CFStringGetMaximumSizeForEncoding( (CFIndex)CFStringGetLength((CFStringRef)self), encoding );
}

- (NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)enc {
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(enc);
    return (NSUInteger)CFStringGetMaximumSizeForEncoding( (CFIndex)CFStringGetLength((CFStringRef)self), encoding );
}

- (NSString *)decomposedStringWithCanonicalMapping {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringNormalize(string, kCFStringNormalizationFormD);
    return [(id)string autorelease];
}

- (NSString *)precomposedStringWithCanonicalMapping {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringNormalize(string, kCFStringNormalizationFormC);
    return [(id)string autorelease];
}

- (NSString *)decomposedStringWithCompatibilityMapping {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringNormalize(string, kCFStringNormalizationFormKD);
    return [(id)string autorelease];
}

- (NSString *)precomposedStringWithCompatibilityMapping {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringNormalize(string, kCFStringNormalizationFormKC);
    return [(id)string autorelease];
}

- (NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale *)locale {
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFStringFold(string, (CFOptionFlags)options, (CFLocaleRef)locale);
    return [(id)string autorelease];
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target
                                        withString:(NSString *)replacement
                                           options:(NSStringCompareOptions)options
                                             range:(NSRange)searchRange
{
    // check that range is valid
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    CFRange range = CFRangeMake( searchRange.location, searchRange.length );
    
    CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
    CFStringFindAndReplace( new, (CFStringRef)target, (CFStringRef)replacement, range, (CFOptionFlags)options );
    return [(id)new autorelease];
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString: target
                                           withString: replacement
                                              options: 0
                                                range: NSMakeRange( 0, [self length] )];
}

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    // check that range is valid
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    CFRange r = CFRangeMake( range.location, range.length );
    
    CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
    CFStringReplace( new, r, (CFStringRef)replacement );
    return [(id)new autorelease];
}

- (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    if (loc >= CFStringGetLength(SELF)) {
        [NSException raise:NSRangeException format:@"TODO"];
    }
    CFStringInsert(MSELF, (CFIndex)loc, (CFStringRef)aString);
}

- (void)deleteCharactersInRange:(NSRange)range {
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (range.location >= length) || ((range.location+range.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange r = CFRangeMake( (CFIndex)range.location, (CFIndex)range.length );
    CFStringDelete( (CFMutableStringRef)self , r );
}

- (void)appendString:(NSString *)aString {
    CFStringAppend(MSELF, (CFStringRef)aString);
}

- (void)appendFormat:(NSString *)format, ... {

    va_list arguments;
    va_start( arguments, format );
    
    CFStringAppendFormatAndArguments( (CFMutableStringRef)self, NULL, (CFStringRef)format, arguments );
    
    va_end( arguments );
}

- (void)setString:(NSString *)aString {
    CFStringReplaceAll(MSELF, (CFStringRef)aString);
}

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target
                              withString:(NSString *)replacement
                                 options:(NSStringCompareOptions)options
                                   range:(NSRange)searchRange
{
    //printf("replaceOccurencesOfString...\n");
    //    PF_CHECK_STR_MUTABLE(self)
    
    if( (target == nil) || (replacement == nil) )
        [NSException raise: NSInvalidArgumentException format:@"TODO"];
    
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( length == 0 ) return 0;
    
    if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) > length) )
        [NSException raise: NSRangeException format:@"TODO"];
    
    CFRange range = CFRangeMake( searchRange.location, searchRange.length );
    
    // I think these are the only allowable options
    options &= (NSBackwardsSearch | NSAnchoredSearch | NSLiteralSearch | NSCaseInsensitiveSearch);
    
    return CFStringFindAndReplace( (CFMutableStringRef)self, (CFStringRef)target, (CFStringRef)replacement, range, options );
}

- (NSArray *)pathComponents {
    return [(id)CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault, SELF, CFSTR("/")) autorelease];
}

- (BOOL)isAbsolutePath {
    return CFStringHasPrefix(SELF, CFSTR("/") );
}

- (NSString *)stringByAbbreviatingWithTildeInPath {
    
    NSString *home = NSHomeDirectory();
    
    if( !CFStringHasPrefix(SELF, (CFStringRef)home) ) {
        return [(id)CFStringCreateCopy(kCFAllocatorDefault, SELF) autorelease];
    }
        
    return [@"~" stringByAppendingString: [self substringFromIndex: CFStringGetLength((CFStringRef)home)]];
}

- (NSString *)stringByExpandingTildeInPath {
    
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( (length == 0) || !CFStringHasPrefix((CFStringRef)self, CFSTR("~")) ) {
        return [(id)CFStringCreateCopy(kCFAllocatorDefault, SELF) autorelease];
    }
        
        unichar sbuf[length];
    unichar *buffer = (unichar *)CFStringGetCharactersPtr((CFStringRef)self);
    if( buffer == NULL )
    {
        CFRange range = CFRangeMake(0, length);
        CFStringGetCharacters((CFStringRef)self, range, sbuf);
        buffer = sbuf;
    }
    
    int i;
    for( i = 1; ((buffer[i] != '/') && (i < length)); i++ ) ;
    
    NSString *homeDir;
    if( i == 1 ) // "~/"
    {
        homeDir = NSHomeDirectory();
    }
    else // "~user"
    {
        CFStringRef userName = CFStringCreateWithCharacters( kCFAllocatorDefault, buffer+1, i-1 );
        homeDir = NSHomeDirectoryForUser( (NSString *)userName );
        [(id)userName release];
        if( (homeDir == nil) || (CFStringGetLength((CFStringRef)homeDir) == 0) )
        {
            if( buffer[length-1] == '/' ) length--; // strip trailing "/"
            return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer, length) autorelease];
        }
    }
    
    // the path should not contain a leading slash
    if( buffer[i] == '/' ) i++;
    
    // if there's no path component, we can just return the new homeDir string
    if( i == length ) return homeDir;
    
    /*    It may be quicker to allocate a buffer of [homeDir length] + length - i, copy into it from both
     string buffers, and then create a new string from it... maybe */
    CFStringRef path = CFStringCreateWithCharacters( kCFAllocatorDefault, buffer+i, length-i );
    NSString *new = [homeDir stringByAppendingString: (NSString *)path];
    [(id)path release];
    
    return [(id)new autorelease];
}


- (NSString *)stringByStandardizingPath {
    // TODO
    return nil;
}

- (NSString *)stringByResolvingSymlinksInPath {
    // TODO
    return nil;
}


- (NSArray *)stringsByAppendingPaths:(NSArray *)paths {
    
    NSUInteger count = [paths count];
    id buffer[count];
    
    id *ptr = buffer;
    for( NSString *string in paths )
        *ptr++ = [self stringByAppendingPathComponent: string];
    
    return [(id)CFArrayCreate(kCFAllocatorDefault, (const void **)buffer, count, ARRAY_CALLBACKS) autorelease];
}


- (NSUInteger)completePathIntoString:(NSString **)outputName
                       caseSensitive:(BOOL)flag
                    matchesIntoArray:(NSArray<NSString *> **)outputArray
                         filterTypes:(NSArray *)filterTypes
{
    // TODO
    return 0;
}

- (const char *)fileSystemRepresentation {
    
    NSUInteger size = CFStringGetMaximumSizeOfFileSystemRepresentation( (CFStringRef)self );
    const char *buffer = malloc(size);
    
    if( CFStringGetFileSystemRepresentation( (CFStringRef)self, (char *)buffer, size ) == true )
        return buffer;
    
    free((void *)buffer);
    [NSException raise:NSCharacterConversionException format:@"TODO"];
    return nil;
}

- (BOOL)getFileSystemRepresentation:(char *)cname maxLength:(NSUInteger)max {
    return CFStringGetFileSystemRepresentation(SELF, cname, max);
}

/*
 *    The following are adapted from Cocotron. (I think the retention policies are wrong.)
 *
 *    The original copyright notice is reproduced here:
 */

/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

- (NSString *)lastPathComponent {
    
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    if( length == 0 ) return @"";
    
    unichar  sbuf[length];
    
    unichar *buffer = (unichar *)CFStringGetCharactersPtr( (CFStringRef)self );
    if( buffer == 0 )
    {
        CFRange range = CFRangeMake(0, length);
        CFStringGetCharacters((CFStringRef)self, range, sbuf);
        buffer = sbuf;
    }
    
    if( buffer[length-1] == '/' ) length--;
    
    for( int i = length; --i >= 0; ) {
        if( (buffer[i] == '/') && (i < length - 1) ) {
            return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer+i+1, length-i-1 ) autorelease];
        }
    }
    
    return [(id)CFStringCreateCopy(kCFAllocatorDefault, SELF) autorelease];
}

- (NSString *)pathExtension {
    
    NSUInteger length = CFStringGetLength((CFStringRef)self);
    unichar  buffer[length];
    int      i;
    
    CFRange range = CFRangeMake(0, length);
    CFStringGetCharacters((CFStringRef)self, range, buffer);
    
    if( (length > 0) && (buffer[length-1] == '/') ) //ISSLASH(buffer[length-1]))
        length--;
    
    for( i = length; --i>=0; )
    {
        if(buffer[i] == '/')
            return @"";
        if(buffer[i]=='.')
        {
            range.location = i + 1;
            range.length = length - i - 1;
            return (NSString *)CFStringCreateWithSubstring(kCFAllocatorDefault, SELF, range);
        }
    }
    
    return @"";
}

/*
 *    There could be a '/' (i) at the end of self, or (ii) at the begining of str. Since it's
 *    a little easier to skip the trailing slash, we'll do that and then add the extra in if
 *    str doesn't provide it.
 */
- (NSString *)stringByAppendingPathComponent:(NSString *)str {
    
    NSUInteger selfLength = CFStringGetLength((CFStringRef)self);
    if( selfLength == 0 ) return [[str copy] autorelease];
    
    NSUInteger otherLength = [str length];
    NSUInteger totalLength = selfLength + 1 + otherLength; // actaully max length
    unichar  buffer[totalLength];
    
    CFRange range = CFRangeMake(0, selfLength);
    CFStringGetCharacters( (CFStringRef)self, range, buffer );
    
    // check for a leading slash on the other string
    if( [str hasPrefix: @"/"] )
    {
        totalLength--;
        if( buffer[selfLength-1] == '/' )
        {
            selfLength--; // shorten self
            totalLength--; // shorter self, less extra char
        }
    }
    else
    {
        if( buffer[selfLength-1] != '/' )
        {
            buffer[selfLength] = '/';
            selfLength++; // extra char, so totalLength is correct
        }
        else
            totalLength--; // we don't need the extra char
    }
    
    [str getCharacters: buffer+selfLength];
    
    // finally, is the entire string has a trailing "/", it should be removed
    if( buffer[totalLength-1] == '/' ) totalLength--;
    
    return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer, totalLength) autorelease];
}

- (NSString *)stringByDeletingLastPathComponent {

    NSUInteger length = CFStringGetLength((CFStringRef)self);
    unichar  sbuf[length];
    
    unichar *buffer = (unichar *)CFStringGetCharactersPtr( (CFStringRef)self );
    if( buffer == 0 )
    {
        CFRange range = CFRangeMake(0, length);
        CFStringGetCharacters((CFStringRef)self, range, sbuf);
        buffer = sbuf;
    }
    
    for( int i = length; --i>=0; ) {
        if( buffer[i] == '/' ) {
            if( i == 0 ) {
                return @"/";
            } else {
                if( (i + 1) < length ) {
                    return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer, i) autorelease];
                }
            }
        }
    }
    return @"";
}

- (NSString *)stringByAppendingPathExtension:(NSString *)str {
    
    NSUInteger selfLength = CFStringGetLength((CFStringRef)self);
    
    if(selfLength && CFStringHasSuffix((CFStringRef)self, CFSTR("/")))
        selfLength--;
    
    NSUInteger otherLength = [str length];
    NSUInteger totalLength = selfLength + 1 + otherLength;
    unichar characters[totalLength];
    
    CFRange range = CFRangeMake(0, selfLength);
    CFStringGetCharacters((CFStringRef)self, range, characters);
    
    characters[selfLength] = '.';
    [str getCharacters: characters + selfLength + 1];
    
    return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, (const UniChar *)characters, totalLength) autorelease];
}

- (NSString *)stringByDeletingPathExtension {
    
    NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
    unichar  sbuf[length];
    
    unichar *buffer = (unichar *)CFStringGetCharactersPtr( (CFStringRef)self );
    if( buffer == 0 )
    {
        CFRange range = CFRangeMake(0, length);
        CFStringGetCharacters((CFStringRef)self, range, sbuf);
        buffer = sbuf;
    }
    
    if( (length > 1) && (buffer[length-1] == '/') ) length--;
    
    for( int i = length; --i>=0; ) {
        if( (buffer[i] == '/') || (buffer[i-1] == '/') ) {
            break;
        }
        if(buffer[i] == '.') {
            return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer, i) autorelease];
        }
    }
    
    return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, buffer, length ) autorelease];
}

/** END OF COCOTRON ADDITIONS **/

/** DEPRECATED METHODS (for reasons of compatability) **/

// for dscl DSoException
- (const char *)cString
{
    return [self cStringUsingEncoding: NSASCIIStringEncoding];
}

- (const char *)lossyCString { };
- (NSUInteger)cStringLength { };
- (void)getCString:(char *)bytes { };
- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength { };
- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength range:(NSRange)aRange remainingRange:(NSRangePointer)leftoverRange  { };

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile { };
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically { };

- (id)initWithContentsOfFile:(NSString *)path { };
- (id)initWithContentsOfURL:(NSURL *)url { };
+ (id)stringWithContentsOfFile:(NSString *)path { };
+ (id)stringWithContentsOfURL:(NSURL *)url { };


- (id)initWithCStringNoCopy:(char *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer  { };
- (id)initWithCString:(const char *)bytes length:(NSUInteger)length { };

// also for dscl: DSoNodeConfig
- (id)initWithCString:(const char *)bytes { return [self initWithCString: bytes encoding: NSASCIIStringEncoding]; }

+ (id)stringWithCString:(const char *)bytes length:(NSUInteger)length { };
+ (id)stringWithCString:(const char *)bytes {};

@end

#undef SELF
#undef MSELF

@interface __NSCFConstantString : __NSCFString
@end

@implementation __NSCFConstantString
- (id)retain { return self; }
- (oneway void)release { }
- (id)autorelease { return self; }
- (NSUInteger)retainCount { return NSIntegerMax; }
- (id)copyWithZone:(NSZone *)zone { return self; }
- (BOOL)isNSCFConstantString__ { return YES; }
@end


// TODO: Work out whether we can implement NSTaggedPointerString
/*
00000000005da0e8 S _OBJC_METACLASS_$_NSTaggedPointerString
00000000005d6dd0 s _OBJC_METACLASS_$_NSTaggedPointerStringCStringContainer
00000000005d9468 S _OBJC_CLASS_$_NSTaggedPointerString
00000000005d6df8 s _OBJC_CLASS_$_NSTaggedPointerStringCStringContainer

000000000007cf60 t -[NSTaggedPointerString UTF8String]
0000000000014870 t -[NSTaggedPointerString _fastCStringContents:]
0000000000014860 t -[NSTaggedPointerString _fastCharacterContents]
0000000000040420 t -[NSTaggedPointerString _getCString:maxLength:encoding:]
00000000000d55a0 t -[NSTaggedPointerString _isCString]
0000000000045ba0 t -[NSTaggedPointerString autorelease]
00000000000bf1a0 t -[NSTaggedPointerString cStringUsingEncoding:]
0000000000014640 t -[NSTaggedPointerString characterAtIndex:]
0000000000078670 t -[NSTaggedPointerString compare:options:range:locale:]
0000000000015460 t -[NSTaggedPointerString copyWithZone:]
000000000004cf00 t -[NSTaggedPointerString fastestEncoding]
000000000004b330 t -[NSTaggedPointerString getBytes:maxLength:usedLength:encoding:options:range:remainingRange:]
0000000000014880 t -[NSTaggedPointerString getCharacters:range:]
000000000002a9e0 t -[NSTaggedPointerString hash]
000000000001b680 t -[NSTaggedPointerString isEqual:]
0000000000064000 t -[NSTaggedPointerString isEqualToString:]
000000000003f7c0 t -[NSTaggedPointerString isNSString__]
0000000000014620 t -[NSTaggedPointerString length]
0000000000080ec0 t -[NSTaggedPointerString lowercaseStringWithLocale:]
000000000004a150 t -[NSTaggedPointerString release]
0000000000125ee0 t -[NSTaggedPointerString retainCount]
000000000004a140 t -[NSTaggedPointerString retain]
0000000000125f00 t -[NSTaggedPointerString smallestEncoding]
000000000004b040 t -[NSTaggedPointerString substringWithRange:]
0000000000084c10 t -[NSTaggedPointerString uppercaseStringWithLocale:]
0000000000080100 t -[NSTaggedPointerStringCStringContainer release]
0000000000125eb0 t -[NSTaggedPointerStringCStringContainer retain]

000000000000de40 t +[NSTaggedPointerString _setAsTaggedStringClass]
0000000000125ed0 t +[NSTaggedPointerString automaticallyNotifiesObserversForKey:]
0000000000125e10 t +[NSTaggedPointerStringCStringContainer taggedPointerStringCStringContainer]
*/
