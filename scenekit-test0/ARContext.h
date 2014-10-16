//
//  ARContext.h
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARDataSetManager.h"
#import "ARState.h"
#import "ARServer.h"

@class ARServer;

@interface ARContext : NSObject

- (id) initWithServer:(ARServer*) server;
- (ARDataSetManager*) getDataSetManager;
- (ARState*) getARState;

- (BOOL) startAR;
- (ARMatrix44F) getProjectionMatrix;

@end
