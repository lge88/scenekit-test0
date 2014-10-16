//
//  ARServer.m
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import "ARServer.h"

@implementation ARServer

- (id) initWithDone:(void (^)(ARContext*)) done {
    return [self initWithDone:done Fail:nil];
}

- (id) initWithDone:(void (^)(ARContext*)) done Fail:(void (^)()) fail {
    // TODO: do all the tedious init; then when all done, call done() with ARContext object;
    ARContext* ctx = [[ARContext alloc] init];
    done(ctx);
    return self;
}

@end
