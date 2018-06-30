//
//  NSError.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// __NSCFError is defined here in CoreFoundation. It is the class which is used to bridge to CFErrorRef.
// NSError (and NSCFError, whatever that is) are defined in Foundation

static id PFErrorUserInfoValue(CFErrorRef error, NSString *key) {
    CFDictionaryRef userInfo = CFErrorCopyUserInfo(error);
    if (!userInfo) return nil;
    const void *value = CFDictionaryGetValue(userInfo, key);
    CFRelease(userInfo);
    return [(id)value autorelease];
}

@interface __NSCFError : NSError
@end

#define SELF ((CFErrorRef)self)

@implementation __NSCFError

// TODO:
// +[__NSCFError automaticallyNotifiesObserversForKey:]
// -[__NSCFError classForCoder]

- (CFTypeID)_cfTypeID {
    return CFErrorGetTypeID();
}

- (NSString *)description {
    return [(id)CFErrorCopyDescription(SELF) autorelease];
}

- (NSInteger)code {
    return CFErrorGetCode(SELF);
}

- (NSString *)domain {
    return (id)CFErrorGetDomain(SELF);
}

- (NSDictionary *)userInfo {
    return [(id)CFErrorCopyUserInfo(SELF) autorelease];
}

// Standard bridged-class over-rides
- (void)dealloc {} // this is missing [super dealloc] on purpose, XCode
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)localizedDescription {
    return [(id)CFErrorCopyDescription(SELF) autorelease];
}

- (NSString *)localizedFailureReason {
    return [(id)CFErrorCopyFailureReason(SELF) autorelease];
}

- (NSString *)localizedRecoverySuggestion {
    return PFErrorUserInfoValue(SELF, NSLocalizedRecoverySuggestionErrorKey);
}

- (NSArray *)localizedRecoveryOptions {
    return PFErrorUserInfoValue(SELF, NSLocalizedRecoveryOptionsErrorKey);
}

- (id)recoveryAttempter {
    return PFErrorUserInfoValue(SELF, NSRecoveryAttempterErrorKey);
}

- (NSString *)helpAnchor {
    return PFErrorUserInfoValue(SELF, NSHelpAnchorErrorKey);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CFStringRef domain = CFErrorGetDomain(SELF);
    CFIndex code = CFErrorGetCode(SELF);
    CFDictionaryRef userInfo = CFErrorCopyUserInfo(SELF);
    CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, domain, code, userInfo);
    CFRelease(userInfo);
    return [(id)error autorelease];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // PF_TODO
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // PF_TODO
    return nil;
}

@end

#undef SELF
