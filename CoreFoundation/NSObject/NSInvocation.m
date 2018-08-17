//
//  NSInvocation.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>

// Placeholder until we can work out a proper implementation

@implementation NSInvocation
@end

/*
00000000005d91e8 S _OBJC_CLASS_$_NSInvocation
00000000005d9e68 S _OBJC_METACLASS_$_NSInvocation

000000000007df10 t +[NSInvocation _invocationWithMethodSignature:frame:]
000000000007efe0 t +[NSInvocation invocationWithMethodSignature:]
0000000000197230 t +[NSInvocation requiredStackSizeForSignature:]

000000000008e1e0 t -[NSInvocation _addAttachedObject:]
0000000000197250 t -[NSInvocation _initWithMethodSignature:frame:buffer:size:]
000000000010ee70 t -[NSInvocation argumentsRetained]
0000000000197360 t -[NSInvocation copyWithZone:]
000000000007f2f0 t -[NSInvocation dealloc]
000000000007e0d0 t -[NSInvocation getArgument:atIndex:]
00000000000abed0 t -[NSInvocation getReturnValue:]
0000000000197340 t -[NSInvocation init]
0000000000197590 t -[NSInvocation invokeSuper]
0000000000197440 t -[NSInvocation invokeUsingIMP:]
0000000000097fd0 t -[NSInvocation invokeWithTarget:]
000000000007f050 t -[NSInvocation invoke]
000000000007e080 t -[NSInvocation methodSignature]
00000000000e14f0 t -[NSInvocation retainArguments]
000000000007e0a0 t -[NSInvocation selector]
000000000007e7d0 t -[NSInvocation setArgument:atIndex:]
0000000000197420 t -[NSInvocation setReturnValue:]
00000000000e14c0 t -[NSInvocation setSelector:]
000000000007f020 t -[NSInvocation setTarget:]
00000000000d6420 t -[NSInvocation target]

00000000005d66b8 s _OBJC_IVAR_$_NSInvocation._container
00000000005d66c8 s _OBJC_IVAR_$_NSInvocation._frame
00000000005d66d8 s _OBJC_IVAR_$_NSInvocation._reserved
00000000005d66d0 s _OBJC_IVAR_$_NSInvocation._retainedArgs
00000000005d66c0 s _OBJC_IVAR_$_NSInvocation._retdata
00000000005d66b0 s _OBJC_IVAR_$_NSInvocation._signature
*/

// TODO: NSBlockInvocation isn't documented but it might be useful to implement

/*
00000000005d9030 S _OBJC_CLASS_$_NSBlockInvocation
00000000005d9cb0 S _OBJC_METACLASS_$_NSBlockInvocation

0000000000197860 t -[NSBlockInvocation invokeSuper]
0000000000197840 t -[NSBlockInvocation invokeUsingIMP:]
0000000000197810 t -[NSBlockInvocation invoke]
00000000001977d0 t -[NSBlockInvocation selector]
00000000001977f0 t -[NSBlockInvocation setSelector:]
*/


