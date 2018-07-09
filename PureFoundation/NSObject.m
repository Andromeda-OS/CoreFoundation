//
//  NSObject.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSObject is defined in libobjc

@interface NSObject (__NSCFType)
- (CFTypeID)_cfTypeID;
@end

@implementation NSObject (__NSCFType)
- (CFTypeID)_cfTypeID {
    return 1; // == __kCFTypeTypeID
}
@end


// TODO: Need to indeirect export NSObject

/*
000000000028ac5e S $ld$add$os10.5$_OBJC_CLASS_$_NSObject
000000000028ac5f S $ld$add$os10.5$_OBJC_METACLASS_$_NSObject
000000000028ac60 S $ld$add$os10.6$_OBJC_CLASS_$_NSObject
000000000028ac61 S $ld$add$os10.6$_OBJC_METACLASS_$_NSObject
000000000028ac62 S $ld$add$os10.7$_OBJC_CLASS_$_NSObject
000000000028ac63 S $ld$add$os10.7$_OBJC_METACLASS_$_NSObject

U _OBJC_CLASS_$_NSObject
I _OBJC_CLASS_$_NSObject (indirect for _OBJC_CLASS_$_NSObject)
U _OBJC_IVAR_$_NSObject.isa
I _OBJC_IVAR_$_NSObject.isa (indirect for _OBJC_IVAR_$_NSObject.isa)
U _OBJC_METACLASS_$_NSObject
I _OBJC_METACLASS_$_NSObject (indirect for _OBJC_METACLASS_$_NSObject)

00000000000ac960 T __NSObjectLoadWeak
0000000000098370 T __NSObjectLoadWeakRetained
0000000000055cd0 T __NSObjectStoreWeak

0000000000001590 t ___26+[NSObject(NSObject) load]_block_invoke

000000000019d320 t ___CFOAInitializeNSObject
000000000019d2c0 t ___CFZombifyNSObject
*/

/*
000000000019d6d0 t +[NSObject(NSObject) __allocWithZone_OA:]
000000000010bf30 t +[NSObject(NSObject) _copyDescription]
000000000019d860 t +[NSObject(NSObject) dealloc]
00000000000d8310 t +[NSObject(NSObject) description]
000000000019d4a0 t +[NSObject(NSObject) doesNotRecognizeSelector:]
000000000019d7e0 t +[NSObject(NSObject) init]
000000000009cd20 t +[NSObject(NSObject) instanceMethodSignatureForSelector:]
0000000000001540 t +[NSObject(NSObject) load]
00000000000a2cf0 t +[NSObject(NSObject) methodSignatureForSelector:]
*/

/*
000000000019d8d0 t -[NSObject(NSKindOfAdditions) isNSArray__]
000000000019d8e0 t -[NSObject(NSKindOfAdditions) isNSCFConstantString__]
000000000019d8f0 t -[NSObject(NSKindOfAdditions) isNSData__]
000000000019d900 t -[NSObject(NSKindOfAdditions) isNSDate__]
000000000019d910 t -[NSObject(NSKindOfAdditions) isNSDictionary__]
000000000019d920 t -[NSObject(NSKindOfAdditions) isNSNumber__]
000000000019d930 t -[NSObject(NSKindOfAdditions) isNSObject__]
000000000019d940 t -[NSObject(NSKindOfAdditions) isNSOrderedSet__]
000000000019d950 t -[NSObject(NSKindOfAdditions) isNSSet__]
000000000019d960 t -[NSObject(NSKindOfAdditions) isNSString__]
000000000019d970 t -[NSObject(NSKindOfAdditions) isNSTimeZone__]
000000000019d980 t -[NSObject(NSKindOfAdditions) isNSValue__]
*/

/*
000000000019d620 t -[NSObject(NSObject) ___tryRetain_OA]
000000000019d690 t -[NSObject(NSObject) __autorelease_OA]
000000000019d710 t -[NSObject(NSObject) __dealloc_zombie]
000000000019d660 t -[NSObject(NSObject) __release_OA]
000000000019d5f0 t -[NSObject(NSObject) __retain_OA]
000000000004fa70 t -[NSObject(NSObject) _copyDescription]
0000000000098010 t -[NSObject(NSObject) description]
000000000019d560 t -[NSObject(NSObject) doesNotRecognizeSelector:]
0000000000097e20 t -[NSObject(NSObject) methodSignatureForSelector:]
*/

