//
//  ARServer.h
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import "ARContext.h"
#import <QCAR/UIGLViewProtocol.h>

@class ARContext;

@interface ARServer : NSObject

- (id) initWithSize:(CGSize) size Done:(void (^)(ARContext*)) done;

// TODO: pass error code to fail() block
- (id) initWithSize:(CGSize) size Done:(void (^)(ARContext*)) done Fail:(void (^)()) fail;

- (BOOL) isRetinaDisplay;
- (ARMatrix44F) getProjectionMatrix;
- (NSError*) startAR;

@end
