//
//  ARState.h
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARMatrix.h"

@interface ARTarget : NSObject

- (BOOL) isTracked;
- (ARMatrix44F) getModelViewMatrix;
- (NSString*) getName;

@end

@interface ARState : NSObject

// A list of ARTarget objects
- (NSArray*) getTrackedTargets;
- (void) drawVideoBackground;

@end
