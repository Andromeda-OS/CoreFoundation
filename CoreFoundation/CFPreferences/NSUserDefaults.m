//
//  NSUserDefaults.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
00000000001e3600 t __CFPreferencesDoesNSUserDefaultsExist
00000000005dd928 d __NSUserDefaultsRegisteredAtLeastOnce
*/

@implementation NSUserDefaults
@end

/*
00000000005da188 S _OBJC_METACLASS_$_NSUserDefaults
00000000005d9508 S _OBJC_CLASS_$_NSUserDefaults

00000000001ddbb0 t -[NSUserDefaults _container]
00000000001ddb30 t -[NSUserDefaults _identifier]
00000000001ddc30 t -[NSUserDefaults _observingCFPreferences]
00000000001ddbd0 t -[NSUserDefaults _setContainer:]
00000000001ddb50 t -[NSUserDefaults _setIdentifier:]

00000000005d6b98 S _OBJC_IVAR_$_NSUserDefaults._container_
00000000005d6b90 S _OBJC_IVAR_$_NSUserDefaults._identifier_
00000000005d6ba0 S _OBJC_IVAR_$_NSUserDefaults._kvo_
00000000005d6ba8 S _OBJC_IVAR_$_NSUserDefaults._reserved
*/
