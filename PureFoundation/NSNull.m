//
//  NSNull.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Work out how (if) we should implement +[NSNull allocWithZone:]

@implementation NSNull

+ (instancetype)alloc {
    return (id)kCFNull;
}

+ (NSNull *)null {
    return (id)kCFNull;
}

- (CFTypeID)_cfTypeID {
    return CFNullGetTypeID();
}

- (NSString *)description {
    return @"<null>";
}

#pragma clang diagnostics push
#pragma clang diagnostics ignored "-Wobjc-missing-super-calls"
- (void)dealloc {}
#pragma clang diagnostics pop

- (instancetype)retain {}
- (oneway void)release {}
- (NSUInteger)retainCount { return NSUIntegerMax; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // PF_TODO
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return self;
}

@end
