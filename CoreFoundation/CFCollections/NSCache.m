//
//  NSCache.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// Placeholder until we can import the SwiftFoundation reimplementation

@implementation NSCache
@end

/*
00000000005d9058 S _OBJC_CLASS_$_NSCache
00000000005d9cd8 S _OBJC_METACLASS_$_NSCache

00000000001bd830 t -[NSCache __apply:]
00000000001bd710 t -[NSCache allObjects]
00000000001bd6e0 t -[NSCache countLimit]
00000000000f9d10 t -[NSCache dealloc]
00000000001bd6a0 t -[NSCache delegate]
00000000000607b0 t -[NSCache evictsObjectsWithDiscardedContent]
000000000005ee80 t -[NSCache init]
00000000001bd700 t -[NSCache minimumObjectCount]
00000000001bd650 t -[NSCache name]
00000000000606a0 t -[NSCache objectForKey:]
00000000000eecc0 t -[NSCache removeAllObjects]
00000000000addd0 t -[NSCache removeObjectForKey:]
00000000000babf0 t -[NSCache setCountLimit:]
000000000010f970 t -[NSCache setDelegate:]
000000000005ef60 t -[NSCache setEvictsObjectsWithDiscardedContent:]
0000000000075e30 t -[NSCache setMinimumObjectCount:]
000000000005efa0 t -[NSCache setName:]
00000000000624b0 t -[NSCache setObject:forKey:]
0000000000062580 t -[NSCache setObject:forKey:cost:]
00000000000a2d40 t -[NSCache setTotalCostLimit:]
00000000001bd6c0 t -[NSCache totalCostLimit]

00000000005d68a8 s _OBJC_IVAR_$_NSCache._delegate
00000000005d68a0 s _OBJC_IVAR_$_NSCache._private
00000000005d68b0 s _OBJC_IVAR_$_NSCache._reserved

00000000001bd7d0 t ___21-[NSCache allObjects]_block_invoke

0000000000076390 t ___NSCacheKeyEqual
00000000000607a0 t ___NSCacheKeyHash
00000000000a3000 t ___NSCacheKeyRelease
0000000000062700 t ___NSCacheKeyRetain
00000000000adc80 t ___NSCacheValueRelease
00000000005e6978 b ___NSCacheValueRelease.oGuard
00000000005e6970 b ___NSCacheValueRelease.oMoribundCache
0000000000062720 t ___NSCacheValueRetain

00000000001bd850 t _____NSCacheValueRelease_block_invoke
*/

/*
00000000005d8720 s _OBJC_CLASS_$__NSMoribundCache
00000000005d8748 s _OBJC_METACLASS_$__NSMoribundCache

00000000001bd500 t -[_NSMoribundCache autorelease]
00000000001bd4c0 t -[_NSMoribundCache copyWithZone:]
00000000001bd4b0 t -[_NSMoribundCache copy]
00000000001bd610 t -[_NSMoribundCache countLimit]
00000000001bd510 t -[_NSMoribundCache dealloc]
00000000001bd580 t -[_NSMoribundCache delegate]
00000000001bd630 t -[_NSMoribundCache evictsObjectsWithDiscardedContent]
00000000001bd550 t -[_NSMoribundCache name]
00000000001bd5a0 t -[_NSMoribundCache objectForKey:]
00000000001bd4f0 t -[_NSMoribundCache release]
00000000001bd5e0 t -[_NSMoribundCache removeAllObjects]
00000000001bd5d0 t -[_NSMoribundCache removeObjectForKey:]
00000000001bd4d0 t -[_NSMoribundCache retainCount]
00000000001bd4e0 t -[_NSMoribundCache retain]
00000000001bd620 t -[_NSMoribundCache setCountLimit:]
00000000001bd590 t -[_NSMoribundCache setDelegate:]
00000000001bd640 t -[_NSMoribundCache setEvictsObjectsWithDiscardedContent:]
00000000001bd570 t -[_NSMoribundCache setName:]
00000000001bd5b0 t -[_NSMoribundCache setObject:forKey:]
00000000001bd5c0 t -[_NSMoribundCache setObject:forKey:cost:]
00000000001bd600 t -[_NSMoribundCache setTotalCostLimit:]
00000000001bd5f0 t -[_NSMoribundCache totalCostLimit]

00000000001bd460 t _NSMoribundCache_invalidAccess
00000000005e6968 b _NSMoribundCache_invalidAccess.oGuard

00000000001bd490 t ___NSMoribundCache_invalidAccess_block_invoke
*/
