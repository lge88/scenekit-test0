//
//  ARContext.m
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import "ARContext.h"

#define APPLICATION_ERROR_DOMAIN @"scenekit-test0.vision2.ucsd.edu"

@implementation ARContext {
    ARDataSetManager* mDataSetManager;
    ARState* mARState;
    ARServer* mARServer;
}

- (id) initWithServer:(ARServer *)server {
    self = [super init];
    if (self) {
        if (!server) return nil;
        
        mDataSetManager = [[ARDataSetManager alloc] init];
        mARState = [[ARState alloc] init];
        mARServer = server;
    }
    return self;
}

- (ARDataSetManager*) getDataSetManager {
    return mDataSetManager;
}

- (ARState*) getARState {
    return mARState;
}

- (BOOL) startAR {
    NSError* error = [mARServer startAR];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return NO;
    }
    return YES;
}

- (ARMatrix44F) getProjectionMatrix {
    return [mARServer getProjectionMatrix];
}

- (void) drawVideoBackground {
    [mARState drawVideoBackground];
}

- (BOOL) isRetina {
    return [mARServer isRetinaDisplay];
}


@end
