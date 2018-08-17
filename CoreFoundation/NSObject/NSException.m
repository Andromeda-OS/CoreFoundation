//
//  NSException.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Figure out what one of these is
// S _OBJC_EHTYPE_$_NSException


@implementation NSException

@synthesize name;
@synthesize reason;
@synthesize userInfo;

// TODO:
// t -[NSException callStackReturnAddresses]
// t -[NSException callStackSymbols]
// t -[NSException copyWithZone:]
// t -[NSException dealloc]
// t -[NSException description]
// t -[NSException encodeWithCoder:]
// t -[NSException hash]
// t -[NSException initWithCoder:]
// t -[NSException init]
// t -[NSException isEqual:]
// t _objectIsKindOfNSException

#pragma mark - factory methods

+ (void)raise:(NSString *)name format:(NSString *)format, ... {
    va_list argList;
    va_start( argList, format );
    [self raise:name format:format arguments:argList];
    va_end( argList );
}

+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList {
    CFStringRef reason = NULL;
    if (format) {
        reason = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, (CFStringRef)format, argList);
    }
    [[self exceptionWithName:name reason:(NSString *)reason userInfo:nil] raise];
}

+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo {
    return [[[self alloc] initWithName:name reason:reason userInfo:userInfo] autorelease];
}

#pragma mark -

- (id)initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo {
    if (self = [super init]) {
        name = [aName copy];
        reason = [aReason copy];
        userInfo = [aUserInfo copy];
    }
    return self;
}

- (void)raise {
    // TODO: I am sorry. Will someone who knows what they're doing please fix this.
    @throw self;
}

@end
