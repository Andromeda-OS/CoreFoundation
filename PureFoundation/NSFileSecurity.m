//
//  NSFileSecurity.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: Import CFFileSecurityRef from https://github.com/Andromeda-OS/CoreFoundation and use as basis of implementation

// On macOS, instances of CFFileSecurityRef map to objective-c class __NSFileSecurity
// TODO: Set up the bridged type for CFFileSecurityRef
// TODO: Implement this class as another toll-free bridged class

@implementation NSFileSecurity
@end

/*
00000000005d9e18 S _OBJC_METACLASS_$_NSFileSecurity
00000000005d9198 S _OBJC_CLASS_$_NSFileSecurity

0000000000109a10 t +[NSFileSecurity allocWithZone:]

00000000001c5700 t -[NSFileSecurity _cfTypeID]
00000000001c5740 t -[NSFileSecurity copyWithZone:]
00000000001c5790 t -[NSFileSecurity encodeWithCoder:]
00000000001c5780 t -[NSFileSecurity initWithCoder:]

00000000005d68c0 s _OBJC_IVAR_$___NSFileSecurity._filesec
*/

/*
00000000005d8860 s _OBJC_METACLASS_$___NSFileSecurity
00000000005d8810 s _OBJC_CLASS_$___NSFileSecurity

0000000000109b60 t +[__NSFileSecurity __new:]
00000000001c5010 t +[__NSFileSecurity allocWithZone:]
00000000001c5000 t +[__NSFileSecurity automaticallyNotifiesObserversForKey:]

0000000000109bf0 t -[__NSFileSecurity _filesec]
000000000011bfc0 t -[__NSFileSecurity clearProperties:]
000000000011fcf0 t -[__NSFileSecurity copyAccessControlList:]
00000000001c4f80 t -[__NSFileSecurity copyWithZone:]
0000000000109c10 t -[__NSFileSecurity dealloc]
00000000001c4ca0 t -[__NSFileSecurity description]
00000000001c5030 t -[__NSFileSecurity encodeWithCoder:]
000000000011fc90 t -[__NSFileSecurity getGroup:]
00000000001c4730 t -[__NSFileSecurity getGroupUUID:]
000000000011c0d0 t -[__NSFileSecurity getMode:]
00000000001c45d0 t -[__NSFileSecurity getOwner:]
00000000001c4690 t -[__NSFileSecurity getOwnerUUID:]
00000000001c4820 t -[__NSFileSecurity hash]
00000000001c52c0 t -[__NSFileSecurity initWithCoder:]
00000000001c4940 t -[__NSFileSecurity isEqual:]
00000000001c47d0 t -[__NSFileSecurity setAccessControlList:]
00000000001c4650 t -[__NSFileSecurity setGroup:]
00000000001c47a0 t -[__NSFileSecurity setGroupUUID:]
000000000011bf60 t -[__NSFileSecurity setMode:]
00000000001c4610 t -[__NSFileSecurity setOwner:]
00000000001c4700 t -[__NSFileSecurity setOwnerUUID:]
*/

/*
00000000005d8838 s _OBJC_CLASS_$___NSPlaceholderFileSecurity
00000000005d8888 s _OBJC_METACLASS_$___NSPlaceholderFileSecurity

0000000000109b20 t +[__NSPlaceholderFileSecurity immutablePlaceholder]
0000000000109a90 t +[__NSPlaceholderFileSecurity initialize]

00000000001c5680 t -[__NSPlaceholderFileSecurity copyWithZone:]
00000000001c5380 t -[__NSPlaceholderFileSecurity dealloc]
00000000001c5600 t -[__NSPlaceholderFileSecurity encodeWithCoder:]
00000000001c5390 t -[__NSPlaceholderFileSecurity initWithCoder:]
0000000000109b30 t -[__NSPlaceholderFileSecurity initWithFileSec:]
00000000001c5310 t -[__NSPlaceholderFileSecurity init]
00000000001c5360 t -[__NSPlaceholderFileSecurity release]
00000000001c5370 t -[__NSPlaceholderFileSecurity retainCount]
00000000001c5350 t -[__NSPlaceholderFileSecurity retain]

0000000000109ac0 t ___41+[__NSPlaceholderFileSecurity initialize]_block_invoke
*/
