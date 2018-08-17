//
//  NSRunLoop.m
//  CoreFoundation
//
//  Created by Stuart Crook on 17/06/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#import <Foundation/NSObject.h>

// NSRunLoop is declared here, but all methods are implemented in Foundation in the NSRunLoop category

// This redefinition is included here so that the ivars appear public
@interface NSRunLoop : NSObject {
    id          _rl;
    id          _dperf;
    id          _perft;
    id          _info;
    id        _ports;
    void    *_reserved[6];
}
@end

@implementation NSRunLoop
@end
