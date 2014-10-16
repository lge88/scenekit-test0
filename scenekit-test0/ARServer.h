//
//  ARServer.h
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARContext.h"

@interface ARServer : NSObject

- (id) initWithDone:(void (^)(ARContext*)) done;
- (id) initWithDone:(void (^)(ARContext*)) done Fail:(void (^)()) fail;

@end
