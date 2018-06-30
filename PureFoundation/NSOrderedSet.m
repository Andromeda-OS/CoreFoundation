//
//  NSOrderedSet.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSOrderedSet and NSMutableOrderedSet are implemented here in CF
// Coding and KVO support is implemented in Foundation

// Placeholder until we can import the SwiftFoundation reimplementation

@implementation NSOrderedSet
@end

@implementation NSMutableOrderedSet
@end

/*
00000000005d9350 S _OBJC_CLASS_$_NSOrderedSet
00000000005d9fd0 S _OBJC_METACLASS_$_NSOrderedSet

00000000000905b0 t +[NSOrderedSet allocWithZone:]
00000000001c2d50 t +[NSOrderedSet newOrderedSetWithObjects:count:]
0000000000105c60 t +[NSOrderedSet orderedSetWithArray:]
00000000001c3660 t +[NSOrderedSet orderedSetWithArray:copyItems:]
00000000001c3600 t +[NSOrderedSet orderedSetWithArray:range:]
00000000001c3590 t +[NSOrderedSet orderedSetWithArray:range:copyItems:]
00000000001c3290 t +[NSOrderedSet orderedSetWithObject:]
00000000001c3300 t +[NSOrderedSet orderedSetWithObjects:]
00000000001c3240 t +[NSOrderedSet orderedSetWithObjects:count:]
000000000010bbe0 t +[NSOrderedSet orderedSetWithOrderedSet:]
00000000001c3730 t +[NSOrderedSet orderedSetWithOrderedSet:copyItems:]
00000000001c36d0 t +[NSOrderedSet orderedSetWithOrderedSet:range:]
00000000000f20e0 t +[NSOrderedSet orderedSetWithOrderedSet:range:copyItems:]
00000000001c37f0 t +[NSOrderedSet orderedSetWithSet:]
00000000001c37a0 t +[NSOrderedSet orderedSetWithSet:copyItems:]
0000000000090570 t +[NSOrderedSet orderedSet]
00000000001c3830 t +[NSOrderedSet supportsSecureCoding]

00000000001c0a30 t -[NSOrderedSet allObjects]
0000000000091290 t -[NSOrderedSet array]
00000000001c3ce0 t -[NSOrderedSet classForCoder]
0000000000119030 t -[NSOrderedSet containsObject:]
00000000001c0ba0 t -[NSOrderedSet containsObject:inRange:]
00000000000fa2a0 t -[NSOrderedSet copyWithZone:]
00000000001c0c90 t -[NSOrderedSet countByEnumeratingWithState:objects:count:]
00000000001c0eb0 t -[NSOrderedSet countForObject:]
00000000001c0dc0 t -[NSOrderedSet countForObject:inRange:]
00000000001c0980 t -[NSOrderedSet count]
00000000001c2a30 t -[NSOrderedSet descriptionWithLocale:]
00000000001c26d0 t -[NSOrderedSet descriptionWithLocale:indent:]
00000000001c2a90 t -[NSOrderedSet description]
00000000001c3840 t -[NSOrderedSet encodeWithCoder:]
000000000010c200 t -[NSOrderedSet enumerateObjectsAtIndexes:options:usingBlock:]
0000000000100b90 t -[NSOrderedSet enumerateObjectsUsingBlock:]
00000000001c0f20 t -[NSOrderedSet enumerateObjectsWithOptions:usingBlock:]
00000000001002a0 t -[NSOrderedSet firstObject]
00000000001c1110 t -[NSOrderedSet getObjects:]
00000000001c0fc0 t -[NSOrderedSet getObjects:range:]
00000000001c2ae0 t -[NSOrderedSet hash]
00000000001c09b0 t -[NSOrderedSet indexOfObject:]
00000000001c11c0 t -[NSOrderedSet indexOfObject:inRange:]
00000000000f1d30 t -[NSOrderedSet indexOfObject:inSortedRange:options:usingComparator:]
000000000010f200 t -[NSOrderedSet indexOfObjectAtIndexes:options:passingTest:]
00000000001c1380 t -[NSOrderedSet indexOfObjectPassingTest:]
00000000001c12c0 t -[NSOrderedSet indexOfObjectWithOptions:passingTest:]
00000000001c1400 t -[NSOrderedSet indexesOfObjectsAtIndexes:options:passingTest:]
00000000001c1600 t -[NSOrderedSet indexesOfObjectsPassingTest:]
00000000001c1540 t -[NSOrderedSet indexesOfObjectsWithOptions:passingTest:]
00000000000fa350 t -[NSOrderedSet initWithArray:]
00000000001c2ea0 t -[NSOrderedSet initWithArray:copyItems:]
00000000001c2e80 t -[NSOrderedSet initWithArray:range:]
00000000000fa3c0 t -[NSOrderedSet initWithArray:range:copyItems:]
00000000001c3a90 t -[NSOrderedSet initWithCoder:]
00000000001c2ef0 t -[NSOrderedSet initWithObject:]
00000000001c2f20 t -[NSOrderedSet initWithObjects:]
00000000001c2d20 t -[NSOrderedSet initWithObjects:count:]
00000000001c31f0 t -[NSOrderedSet initWithOrderedSet:]
00000000001c31a0 t -[NSOrderedSet initWithOrderedSet:copyItems:]
00000000001c3180 t -[NSOrderedSet initWithOrderedSet:range:]
00000000000f2150 t -[NSOrderedSet initWithOrderedSet:range:copyItems:]
0000000000117940 t -[NSOrderedSet initWithSet:]
0000000000117960 t -[NSOrderedSet initWithSet:copyItems:]
00000000001c1680 t -[NSOrderedSet intersectsOrderedSet:]
0000000000116210 t -[NSOrderedSet intersectsSet:]
00000000000f1c30 t -[NSOrderedSet isEqual:]
00000000001c2b30 t -[NSOrderedSet isEqualToOrderedSet:]
00000000001c0a20 t -[NSOrderedSet isNSOrderedSet__]
00000000001c1850 t -[NSOrderedSet isSubsetOfOrderedSet:]
00000000001c1a10 t -[NSOrderedSet isSubsetOfSet:]
00000000000f1ba0 t -[NSOrderedSet lastObject]
00000000000f9d90 t -[NSOrderedSet mutableCopyWithZone:]
00000000001c09f0 t -[NSOrderedSet objectAtIndex:]
00000000000ff3b0 t -[NSOrderedSet objectAtIndexedSubscript:]
00000000001c1bd0 t -[NSOrderedSet objectAtIndexes:options:passingTest:]
00000000001054c0 t -[NSOrderedSet objectEnumerator]
00000000001c1dc0 t -[NSOrderedSet objectPassingTest:]
00000000001c1d00 t -[NSOrderedSet objectWithOptions:passingTest:]
0000000000118340 t -[NSOrderedSet objectsAtIndexes:]
00000000001c1e40 t -[NSOrderedSet objectsAtIndexes:options:passingTest:]
00000000001c2040 t -[NSOrderedSet objectsPassingTest:]
00000000001c1f80 t -[NSOrderedSet objectsWithOptions:passingTest:]
00000000000fa950 t -[NSOrderedSet reverseObjectEnumerator]
00000000000fa200 t -[NSOrderedSet reversedOrderedSet]
00000000001c2650 t -[NSOrderedSet set]
00000000001c20c0 t -[NSOrderedSet sortedArrayFromRange:options:usingComparator:]
00000000001c25b0 t -[NSOrderedSet sortedArrayUsingComparator:]
00000000001c2510 t -[NSOrderedSet sortedArrayWithOptions:usingComparator:]
*/

/*
00000000005d92d8 S _OBJC_CLASS_$_NSMutableOrderedSet
00000000005d9f58 S _OBJC_METACLASS_$_NSMutableOrderedSet

00000000000951f0 t +[NSMutableOrderedSet orderedSetWithCapacity:]

000000000012fb20 t -[NSMutableOrderedSet _mutate]
0000000000090e40 t -[NSMutableOrderedSet addObject:]
000000000012fb30 t -[NSMutableOrderedSet addObjects:count:]
00000000000f9660 t -[NSMutableOrderedSet addObjectsFromArray:]
000000000012fc40 t -[NSMutableOrderedSet addObjectsFromArray:range:]
000000000012fec0 t -[NSMutableOrderedSet addObjectsFromOrderedSet:]
000000000012fd80 t -[NSMutableOrderedSet addObjectsFromOrderedSet:range:]
000000000012ff90 t -[NSMutableOrderedSet addObjectsFromSet:]
0000000000134d20 t -[NSMutableOrderedSet classForCoder]
0000000000130050 t -[NSMutableOrderedSet exchangeObjectAtIndex:withObjectAtIndex:]
0000000000134c20 t -[NSMutableOrderedSet initWithCapacity:]
0000000000134c50 t -[NSMutableOrderedSet initWithObjects:count:]
000000000012fa90 t -[NSMutableOrderedSet insertObject:atIndex:]
0000000000130b50 t -[NSMutableOrderedSet insertObjects:atIndexes:]
00000000000f99d0 t -[NSMutableOrderedSet insertObjects:count:atIndex:]
0000000000130250 t -[NSMutableOrderedSet insertObjectsFromArray:atIndex:]
00000000000f9730 t -[NSMutableOrderedSet insertObjectsFromArray:range:atIndex:]
0000000000130710 t -[NSMutableOrderedSet insertObjectsFromOrderedSet:atIndex:]
0000000000130470 t -[NSMutableOrderedSet insertObjectsFromOrderedSet:range:atIndex:]
0000000000130930 t -[NSMutableOrderedSet insertObjectsFromSet:atIndex:]
0000000000130f00 t -[NSMutableOrderedSet intersectOrderedSet:]
00000000000fa660 t -[NSMutableOrderedSet intersectSet:]
0000000000131550 t -[NSMutableOrderedSet minusOrderedSet:]
000000000011c440 t -[NSMutableOrderedSet minusSet:]
0000000000131200 t -[NSMutableOrderedSet moveObjectsAtIndexes:toIndex:]
0000000000118fa0 t -[NSMutableOrderedSet removeAllObjects]
00000000001317a0 t -[NSMutableOrderedSet removeFirstObject]
0000000000131820 t -[NSMutableOrderedSet removeLastObject]
0000000000103e20 t -[NSMutableOrderedSet removeObject:]
00000000001318a0 t -[NSMutableOrderedSet removeObject:inRange:]
000000000012fac0 t -[NSMutableOrderedSet removeObjectAtIndex:]
00000000001176d0 t -[NSMutableOrderedSet removeObjectsAtIndexes:]
0000000000132cc0 t -[NSMutableOrderedSet removeObjectsAtIndexes:options:passingTest:]
0000000000131fe0 t -[NSMutableOrderedSet removeObjectsInArray:]
0000000000131e50 t -[NSMutableOrderedSet removeObjectsInArray:range:]
0000000000132780 t -[NSMutableOrderedSet removeObjectsInOrderedSet:]
0000000000132630 t -[NSMutableOrderedSet removeObjectsInOrderedSet:range:]
0000000000118240 t -[NSMutableOrderedSet removeObjectsInRange:]
0000000000131be0 t -[NSMutableOrderedSet removeObjectsInRange:inArray:]
00000000001319b0 t -[NSMutableOrderedSet removeObjectsInRange:inArray:range:]
00000000001324d0 t -[NSMutableOrderedSet removeObjectsInRange:inOrderedSet:]
00000000001321c0 t -[NSMutableOrderedSet removeObjectsInRange:inOrderedSet:range:]
0000000000132870 t -[NSMutableOrderedSet removeObjectsInRange:inSet:]
0000000000132ae0 t -[NSMutableOrderedSet removeObjectsInSet:]
0000000000132fb0 t -[NSMutableOrderedSet removeObjectsPassingTest:]
0000000000132e70 t -[NSMutableOrderedSet removeObjectsWithOptions:passingTest:]
0000000000133160 t -[NSMutableOrderedSet replaceObject:]
0000000000133030 t -[NSMutableOrderedSet replaceObject:inRange:]
000000000012faf0 t -[NSMutableOrderedSet replaceObjectAtIndex:withObject:]
0000000000133210 t -[NSMutableOrderedSet replaceObjectsAtIndexes:withObjects:]
0000000000118010 t -[NSMutableOrderedSet replaceObjectsInRange:withObjects:count:]
00000000001338b0 t -[NSMutableOrderedSet replaceObjectsInRange:withObjectsFromArray:]
00000000001335f0 t -[NSMutableOrderedSet replaceObjectsInRange:withObjectsFromArray:range:]
0000000000133db0 t -[NSMutableOrderedSet replaceObjectsInRange:withObjectsFromOrderedSet:]
0000000000133af0 t -[NSMutableOrderedSet replaceObjectsInRange:withObjectsFromOrderedSet:range:]
0000000000133ff0 t -[NSMutableOrderedSet replaceObjectsInRange:withObjectsFromSet:]
0000000000134230 t -[NSMutableOrderedSet setArray:]
0000000000134430 t -[NSMutableOrderedSet setObject:]
00000000001342f0 t -[NSMutableOrderedSet setObject:atIndex:]
0000000000134410 t -[NSMutableOrderedSet setObject:atIndexedSubscript:]
0000000000134510 t -[NSMutableOrderedSet setOrderedSet:]
00000000001345e0 t -[NSMutableOrderedSet setSet:]
0000000000117c50 t -[NSMutableOrderedSet sortRange:options:usingComparator:]
0000000000134730 t -[NSMutableOrderedSet sortUsingComparator:]
0000000000117b90 t -[NSMutableOrderedSet sortWithOptions:usingComparator:]
00000000001346a0 t -[NSMutableOrderedSet sortedArrayFromRange:options:usingComparator:]
00000000001347e0 t -[NSMutableOrderedSet unionOrderedSet:]
0000000000134a00 t -[NSMutableOrderedSet unionSet:]
*/

/*
00000000005d8b80 s _OBJC_CLASS_$___NSOrderedSetArrayProxy
00000000005d6d30 s _OBJC_CLASS_$___NSOrderedSetI
00000000005d7eb0 s _OBJC_CLASS_$___NSOrderedSetM
00000000005d7af0 s _OBJC_CLASS_$___NSOrderedSetReverseEnumerator
00000000005d7b40 s _OBJC_CLASS_$___NSOrderedSetReversed
00000000005d8bd0 s _OBJC_CLASS_$___NSOrderedSetSetProxy

00000000005d8ba8 s _OBJC_METACLASS_$___NSOrderedSetArrayProxy
00000000005d6d58 s _OBJC_METACLASS_$___NSOrderedSetI
00000000005d7ed8 s _OBJC_METACLASS_$___NSOrderedSetM
00000000005d7b18 s _OBJC_METACLASS_$___NSOrderedSetReverseEnumerator
00000000005d7b68 s _OBJC_METACLASS_$___NSOrderedSetReversed
00000000005d8bf8 s _OBJC_METACLASS_$___NSOrderedSetSetProxy

00000000005d6ae8 s _OBJC_IVAR_$___NSOrderedSetArrayProxy._orderedSet
00000000005d6160 s _OBJC_IVAR_$___NSOrderedSetI._list
00000000005d6158 s _OBJC_IVAR_$___NSOrderedSetI._szidx
00000000005d6150 s _OBJC_IVAR_$___NSOrderedSetI._used
00000000005d6520 s _OBJC_IVAR_$___NSOrderedSetM._array
00000000005d6518 s _OBJC_IVAR_$___NSOrderedSetM._set
00000000005d6510 s _OBJC_IVAR_$___NSOrderedSetM._used
00000000005d63e0 s _OBJC_IVAR_$___NSOrderedSetReverseEnumerator._idx
00000000005d63d8 s _OBJC_IVAR_$___NSOrderedSetReverseEnumerator._obj
00000000005d63f0 s _OBJC_IVAR_$___NSOrderedSetReversed._cnt
00000000005d63e8 s _OBJC_IVAR_$___NSOrderedSetReversed._orderedSet
00000000005d6af0 s _OBJC_IVAR_$___NSOrderedSetSetProxy._orderedSet


00000000000906f0 t +[__NSOrderedSetI __new:::]
00000000001229a0 t +[__NSOrderedSetI allocWithZone:]
0000000000122810 t +[__NSOrderedSetI automaticallyNotifiesObserversForKey:]
0000000000090c90 t +[__NSOrderedSetM __new:::]
0000000000174c00 t +[__NSOrderedSetM allocWithZone:]
0000000000174990 t +[__NSOrderedSetM automaticallyNotifiesObserversForKey:]

00000000001d81b0 t -[__NSOrderedSetArrayProxy copyWithZone:]
0000000000091340 t -[__NSOrderedSetArrayProxy count]
0000000000095470 t -[__NSOrderedSetArrayProxy dealloc]
0000000000091310 t -[__NSOrderedSetArrayProxy initWithOrderedSet:]
0000000000091360 t -[__NSOrderedSetArrayProxy objectAtIndex:]
0000000000105cc0 t -[__NSOrderedSetI copyWithZone:]
00000000000f2520 t -[__NSOrderedSetI countByEnumeratingWithState:objects:count:]
00000000000fa330 t -[__NSOrderedSetI count]
00000000000f25b0 t -[__NSOrderedSetI dealloc]
0000000000105ce0 t -[__NSOrderedSetI enumerateObjectsWithOptions:usingBlock:]
0000000000122820 t -[__NSOrderedSetI getObjects:range:]
00000000001190a0 t -[__NSOrderedSetI indexOfObject:]
0000000000105f60 t -[__NSOrderedSetI objectAtIndex:]
0000000000090ee0 t -[__NSOrderedSetM _mutate]
00000000000f1cb0 t -[__NSOrderedSetM containsObject:]
00000000000910a0 t -[__NSOrderedSetM countByEnumeratingWithState:objects:count:]
00000000001749a0 t -[__NSOrderedSetM countForObject:]
0000000000090f40 t -[__NSOrderedSetM count]
00000000000954c0 t -[__NSOrderedSetM dealloc]
0000000000100310 t -[__NSOrderedSetM enumerateObjectsWithOptions:usingBlock:]
00000000000f23f0 t -[__NSOrderedSetM getObjects:range:]
00000000000f2650 t -[__NSOrderedSetM indexOfObject:]
0000000000090f60 t -[__NSOrderedSetM insertObject:atIndex:]
0000000000091380 t -[__NSOrderedSetM objectAtIndex:]
0000000000103eb0 t -[__NSOrderedSetM removeObjectAtIndex:]
00000000001747f0 t -[__NSOrderedSetM replaceObjectAtIndex:withObject:]
0000000000174a20 t -[__NSOrderedSetM setObject:atIndex:]
00000000000faaa0 t -[__NSOrderedSetReverseEnumerator dealloc]
00000000000fa9d0 t -[__NSOrderedSetReverseEnumerator initWithObject:]
00000000000faa30 t -[__NSOrderedSetReverseEnumerator nextObject]
00000000000fa3a0 t -[__NSOrderedSetReversed count]
00000000000faaf0 t -[__NSOrderedSetReversed dealloc]
00000000001558a0 t -[__NSOrderedSetReversed indexOfObject:]
00000000000fa250 t -[__NSOrderedSetReversed initWithOrderedSet:]
00000000001558f0 t -[__NSOrderedSetReversed objectAtIndex:]
00000000001d8320 t -[__NSOrderedSetSetProxy copyWithZone:]
00000000001d8290 t -[__NSOrderedSetSetProxy count]
00000000001d8240 t -[__NSOrderedSetSetProxy dealloc]
00000000001d8210 t -[__NSOrderedSetSetProxy initWithOrderedSet:]
00000000001d82b0 t -[__NSOrderedSetSetProxy member:]
00000000001d8300 t -[__NSOrderedSetSetProxy objectEnumerator]

00000000005dd6d8 d ___NSOrderedSet0__
00000000001f4690 s ___NSOrderedSetCapacities
0000000000166fe0 t ___NSOrderedSetChunkIterate
000000000010c490 t ___NSOrderedSetEnumerate
00000000000f1c10 t ___NSOrderedSetEquateKeys
000000000010f340 t ___NSOrderedSetGetIndexPassingTest
00000000001675b0 t ___NSOrderedSetGetIndexesPassingTest
0000000000091080 t ___NSOrderedSetHashKey
00000000005de9f8 d ___NSOrderedSetMCB
000000000010c340 t ___NSOrderedSetParameterCheckIterate
00000000001f4480 s ___NSOrderedSetSizes


0000000000105ee0 t ___58-[__NSOrderedSetI enumerateObjectsWithOptions:usingBlock:]_block_invoke
00000000001c24b0 t ___61-[NSOrderedSet sortedArrayFromRange:options:usingComparator:]_block_invoke
0000000000167310 t _____NSOrderedSetEnumerate_block_invoke
0000000000167460 t _____NSOrderedSetGetIndexPassingTest_block_invoke
0000000000167c80 t _____NSOrderedSetGetIndexesPassingTest_block_invoke
0000000000117ff0 t ___57-[NSMutableOrderedSet sortRange:options:usingComparator:]_block_invoke
*/

/*
00000000005d87e8 s _OBJC_CLASS_$___NSPlaceholderOrderedSet
00000000005d87c0 s _OBJC_METACLASS_$___NSPlaceholderOrderedSet

00000000001bf840 t +[__NSPlaceholderOrderedSet allocWithZone:]
00000000000dd790 t +[__NSPlaceholderOrderedSet immutablePlaceholder]
0000000000090650 t +[__NSPlaceholderOrderedSet initialize]
0000000000090b90 t +[__NSPlaceholderOrderedSet mutablePlaceholder]

00000000001bf890 t -[__NSPlaceholderOrderedSet count]
00000000001bf880 t -[__NSPlaceholderOrderedSet dealloc]
00000000001bf950 t -[__NSPlaceholderOrderedSet indexOfObject:]
0000000000095230 t -[__NSPlaceholderOrderedSet initWithCapacity:]
0000000000090ba0 t -[__NSPlaceholderOrderedSet initWithObjects:count:]
00000000000acb70 t -[__NSPlaceholderOrderedSet init]
00000000001bfad0 t -[__NSPlaceholderOrderedSet insertObject:atIndex:]
00000000001bfa10 t -[__NSPlaceholderOrderedSet objectAtIndex:]
00000000001bf860 t -[__NSPlaceholderOrderedSet release]
00000000001bfb90 t -[__NSPlaceholderOrderedSet removeObjectAtIndex:]
00000000001bfc50 t -[__NSPlaceholderOrderedSet replaceObjectAtIndex:withObject:]
00000000001bf870 t -[__NSPlaceholderOrderedSet retainCount]
00000000001bf850 t -[__NSPlaceholderOrderedSet retain]

0000000000090680 t ___39+[__NSPlaceholderOrderedSet initialize]_block_invoke
*/
