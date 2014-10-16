//
//  ARState.m
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import "ARState.h"
#import <QCAR/State.h>
#import <QCAR/Renderer.h>
#import <QCAR/Tool.h>
#import <QCAR/TrackableResult.h>


namespace {
    void makeIdentity(ARMatrix44F* mat) {
        mat->data[0] = 1; mat->data[4] = 0; mat->data[8] = 0; mat->data[12] = 0;
        mat->data[1] = 0; mat->data[5] = 1; mat->data[9] = 0; mat->data[13] = 0;
        mat->data[2] = 0; mat->data[6] = 0; mat->data[10] = 1; mat->data[14] = 0;
        mat->data[3] = 0; mat->data[7] = 0; mat->data[11] = 0; mat->data[15] = 1;
    }
    
    void setFromQCARMatrix(ARMatrix44F& dest, const QCAR::Matrix44F& src) {
        for (int i = 0; i < 16; ++i) dest.data[i] = src.data[i];
    }
}

@implementation ARTarget {
    const QCAR::TrackableResult* mTrackableResult;
    const QCAR::Trackable* mTrackable;
}

- (id) initWithTrackable:(const QCAR::Trackable*) trackable {
    self = [super init];
    if (self) {
        if (!trackable) return nil;
        
        mTrackableResult = NULL;
        mTrackable = trackable;
    }
    return self;
}

- (BOOL) isTracked {
    return mTrackableResult != NULL;
}

- (void) linkToTrackableResult:(const QCAR::TrackableResult*) trackableResult {
    mTrackableResult = trackableResult;
}

- (ARMatrix44F) getModelViewMatrix {
    ARMatrix44F mvMat;
    if ([self isTracked]) {
        QCAR::Matrix44F qcarMVMatrix = QCAR::Tool::convertPose2GLMatrix(mTrackableResult->getPose());
        setFromQCARMatrix(mvMat, qcarMVMatrix);
    } else {
        makeIdentity(&mvMat);
    }
    return mvMat;
}

- (NSString*) getName {
    return [NSString stringWithUTF8String:mTrackable->getName()];
}

@end


@implementation ARState

- (NSArray*) getTrackedTargets {
    NSMutableArray* targets = [[NSMutableArray alloc] init];
    
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    
    for (int i = 0; i < state.getNumTrackableResults(); ++i) {
        const QCAR::TrackableResult* trackableResult = state.getTrackableResult(i);
        const QCAR::Trackable* trackable = &(trackableResult->getTrackable());
        ARTarget* target = [[ARTarget alloc] initWithTrackable:trackable];
        [target linkToTrackableResult:trackableResult];
        [targets addObject:target];
    }
 
    QCAR::Renderer::getInstance().end();
    
    return targets;
}

@end

