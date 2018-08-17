//
//  NSEnumerator.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSEnumerator
@end

/*
00000000005d9148 S _OBJC_CLASS_$_NSEnumerator
00000000005d9dc8 S _OBJC_METACLASS_$_NSEnumerator

00000000000948b0 t -[NSEnumerator allObjects]
000000000005b8e0 t -[NSEnumerator countByEnumeratingWithState:objects:count:]
0000000000195b90 t -[NSEnumerator nextObject]
*/

/*
00000000005d8108 s _OBJC_CLASS_$___NSEnumerator0
00000000005d80e0 s _OBJC_METACLASS_$___NSEnumerator0

0000000000196140 t +[__NSEnumerator0 _alloc]
0000000000196100 t +[__NSEnumerator0 allocWithZone:]
00000000001960e0 t +[__NSEnumerator0 new]
0000000000195fe0 t +[__NSEnumerator0 sharedInstance]

0000000000196170 t -[__NSEnumerator0 _init]
00000000001961e0 t -[__NSEnumerator0 autorelease]
0000000000196120 t -[__NSEnumerator0 init]
00000000001961a0 t -[__NSEnumerator0 nextObject]
00000000001961d0 t -[__NSEnumerator0 release]
00000000001961b0 t -[__NSEnumerator0 retainCount]
00000000001961c0 t -[__NSEnumerator0 retain]

0000000000196050 t ___33+[__NSEnumerator0 sharedInstance]_block_invoke
00000000005dc2b8 d ___NSEnumerator0__
*/

/*
00000000005d9760 S _OBJC_CLASS_$___NSFastEnumerationEnumerator
00000000005d8090 s _OBJC_CLASS_$___NSSingleObjectEnumerator
00000000005da3e0 S _OBJC_METACLASS_$___NSFastEnumerationEnumerator
00000000005d80b8 s _OBJC_METACLASS_$___NSSingleObjectEnumerator

00000000000770d0 t +[__NSFastEnumerationEnumerator allocWithZone:]

0000000000077fd0 t -[__NSFastEnumerationEnumerator dealloc]
00000000000770f0 t -[__NSFastEnumerationEnumerator initWithObject:]
00000000000773b0 t -[__NSFastEnumerationEnumerator nextObject]

00000000005d6638 s _OBJC_IVAR_$___NSFastEnumerationEnumerator._count
00000000005d6630 s _OBJC_IVAR_$___NSFastEnumerationEnumerator._index
00000000005d6650 s _OBJC_IVAR_$___NSFastEnumerationEnumerator._mut
00000000005d6620 s _OBJC_IVAR_$___NSFastEnumerationEnumerator._obj
00000000005d6648 s _OBJC_IVAR_$___NSFastEnumerationEnumerator._objects
00000000005d6628 s _OBJC_IVAR_$___NSFastEnumerationEnumerator._origObj
00000000005d6640 s _OBJC_IVAR_$___NSFastEnumerationEnumerator._state

0000000000195d90 t ___48-[__NSFastEnumerationEnumerator initWithObject:]_block_invoke

0000000000195ea0 t -[__NSSingleObjectEnumerator dealloc]
0000000000195f20 t -[__NSSingleObjectEnumerator description]
0000000000195e00 t -[__NSSingleObjectEnumerator initWithObject:]
0000000000195e80 t -[__NSSingleObjectEnumerator init]
0000000000195ef0 t -[__NSSingleObjectEnumerator nextObject]

00000000005d6658 s _OBJC_IVAR_$___NSSingleObjectEnumerator._theObjectToReturn
*/
