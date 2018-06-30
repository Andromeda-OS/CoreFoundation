//
//  NSBlock.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// The definitions of NSBlock etc. are not public. Block instances report different classes as their type.

// These are defined elsewhere, but I'm not sure where
//U __NSConcreteAutoBlock
//U __NSConcreteFinalizingBlock
//U __NSConcreteGlobalBlock
//U __NSConcreteMallocBlock
//U __NSConcreteStackBlock
//U __NSConcreteWeakBlockVariable

/*
0000000000007ad0 t ___CFMakeNSBlockClasses
*/

/*
00000000005d9008 S _OBJC_CLASS_$_NSBlock
00000000005d9c88 S _OBJC_METACLASS_$_NSBlock

00000000001bd020 t +[NSBlock allocWithZone:]
00000000001bd040 t +[NSBlock alloc]

000000000007d850 t -[NSBlock copyWithZone:]
00000000000418e0 t -[NSBlock copy]
00000000001bd060 t -[NSBlock invoke]
00000000001bd070 t -[NSBlock performAfterDelay:]
*/

/*
00000000005d9710 S _OBJC_CLASS_$___NSAutoBlock
00000000005da390 S _OBJC_METACLASS_$___NSAutoBlock

00000000001bd160 t -[__NSAutoBlock copyWithZone:]
00000000001bd150 t -[__NSAutoBlock copy]
*/

/*
00000000005d9738 S _OBJC_CLASS_$___NSBlockVariable
00000000005da3b8 S _OBJC_METACLASS_$___NSBlockVariable

00000000005d6878 S _OBJC_IVAR_$___NSBlockVariable.byref_destroy
00000000005d6870 S _OBJC_IVAR_$___NSBlockVariable.byref_keep
00000000005d6880 S _OBJC_IVAR_$___NSBlockVariable.containedObject
00000000005d6860 S _OBJC_IVAR_$___NSBlockVariable.flags
00000000005d6858 S _OBJC_IVAR_$___NSBlockVariable.forwarding
00000000005d6868 S _OBJC_IVAR_$___NSBlockVariable.size
*/

/*
00000000005d97b0 S _OBJC_CLASS_$___NSGlobalBlock
00000000005da430 S _OBJC_METACLASS_$___NSGlobalBlock

00000000001bd1b0 t -[__NSGlobalBlock _isDeallocating]
00000000001bd1a0 t -[__NSGlobalBlock _tryRetain]
000000000007f3e0 t -[__NSGlobalBlock copyWithZone:]
00000000000713c0 t -[__NSGlobalBlock copy]
0000000000094470 t -[__NSGlobalBlock release]
00000000001bd190 t -[__NSGlobalBlock retainCount]
0000000000048520 t -[__NSGlobalBlock retain]
*/

/*
00000000005d9788 S _OBJC_CLASS_$___NSFinalizingBlock
00000000005da408 S _OBJC_METACLASS_$___NSFinalizingBlock

00000000001bd170 t -[__NSFinalizingBlock finalize]
*/

/*
00000000005d9a58 S _OBJC_CLASS_$___NSStackBlock
00000000005da6d8 S _OBJC_METACLASS_$___NSStackBlock

00000000001bd110 t -[__NSStackBlock autorelease]
000000000007fdc0 t -[__NSStackBlock release]
00000000001bd100 t -[__NSStackBlock retainCount]
000000000007fdb0 t -[__NSStackBlock retain]
*/

/*
00000000005d9a30 S _OBJC_CLASS_$___NSMallocBlock
00000000005da6b0 S _OBJC_METACLASS_$___NSMallocBlock

00000000001bd140 t -[__NSMallocBlock _isDeallocating]
00000000001bd130 t -[__NSMallocBlock _tryRetain]
0000000000056eb0 t -[__NSMallocBlock release]
00000000001bd120 t -[__NSMallocBlock retainCount]
0000000000055df0 t -[__NSMallocBlock retain]
*/
