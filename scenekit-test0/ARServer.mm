//
//  ARServer.m
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import "ARServer.h"
#import <QCAR/QCAR.h>
#import <QCAR/Matrices.h>
#import <QCAR/QCAR_iOS.h>
#import <QCAR/Tool.h>
#import <QCAR/Renderer.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ImageTracker.h>
#import <QCAR/VideoBackgroundConfig.h>
#import <QCAR/UpdateCallback.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIScreen.h>

#define APPLICATION_ERROR_DOMAIN @"scenekit-test0"

namespace {
    const int QCAR_INIT_FLAG = QCAR::GL_20;
    const UIInterfaceOrientation ORIENTATION = UIInterfaceOrientationPortrait;
    
    void setFromQCARMatrix(ARMatrix44F& dest, const QCAR::Matrix44F& src) {
        for (int i = 0; i < 16; ++i) dest.data[i] = src.data[i];
    }
    
    void makeIdentity(ARMatrix44F* mat) {
        mat->data[0] = 1; mat->data[4] = 0; mat->data[8] = 0; mat->data[12] = 0;
        mat->data[1] = 0; mat->data[5] = 1; mat->data[9] = 0; mat->data[13] = 0;
        mat->data[2] = 0; mat->data[6] = 0; mat->data[10] = 1; mat->data[14] = 0;
        mat->data[3] = 0; mat->data[7] = 0; mat->data[11] = 0; mat->data[15] = 1;
    }
    
    struct tagViewport {
        int posX;
        int posY;
        int sizeX;
        int sizeY;
    } viewport;
}

@implementation ARServer {
    ARMatrix44F _projectionMatrix;
    CGSize mViewSize;
}

- (id) initWithSize:(CGSize) size Done:(void (^)(ARContext*)) done {
    return [self initWithSize:size Done:done Fail:nil];
}

- (id) initWithSize:(CGSize) size Done:(void (^)(ARContext*)) done Fail:(void (^)()) fail {
    self = [super init];
    if (self) {
        makeIdentity(&_projectionMatrix);
        mViewSize = size;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self initQCARInBackgroundWithSize:size Done:done Fail: fail];
        });
    }
    return self;
}

- (void) initQCARInBackgroundWithSize:(CGSize) size Done:(void (^)(ARContext*)) done Fail:(void (^)()) fail {
    QCAR::setInitParameters(QCAR_INIT_FLAG);
    NSInteger initSuccess = 0;
    do {
        initSuccess = QCAR::init();
    } while (0 <= initSuccess && 100 > initSuccess);
    
    if (100 == initSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self prepareARWithSize:size Done:done Fail:fail];
        });
    } else {
        fail();
    }
}

- (void) prepareARWithSize:(CGSize) size Done:(void (^)(ARContext*)) done Fail:(void (^)()) fail {
    QCAR::onSurfaceCreated();
    // Always true for now
    if (ORIENTATION == UIInterfaceOrientationPortrait) {
        QCAR::onSurfaceChanged(size.width, size.height);
        QCAR::setRotation(QCAR::ROTATE_IOS_90);
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[self initQCARInBackgroundWithSize:size Done:done Fail: fail];
        [self initTrackerWithDone:done Fail:fail];
    });
    
    //[self initTrackerWithDone:done Fail:fail];
}

- (void) initTrackerWithDone:(void (^)(ARContext*)) done Fail:(void (^)()) fail {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ImageTracker::getClassType());
    if (trackerBase == NULL) {
        NSLog(@"Failed to initialize ImageTracker.");
        fail();
    }
    
    NSLog(@"Successfully initialized ImageTracker.");
    
    ARContext* ctx = [[ARContext alloc] initWithServer: self];
    done(ctx);
}

- (BOOL) isRetinaDisplay {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && 2.0 == [UIScreen mainScreen].scale);
}

- (NSError *) NSErrorWithCode:(int) code {
    return [NSError errorWithDomain:APPLICATION_ERROR_DOMAIN code:code userInfo:nil];
}

// Configure QCAR with the video background size
- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    // Get the default video mode
    QCAR::CameraDevice& cameraDevice = QCAR::CameraDevice::getInstance();
    QCAR::VideoMode videoMode = cameraDevice.getVideoMode(QCAR::CameraDevice::MODE_DEFAULT);
    
    // Configure the video background
    QCAR::VideoBackgroundConfig config;
    config.mEnabled = true;
    config.mSynchronous = true;
    config.mPosition.data[0] = 0.0f;
    config.mPosition.data[1] = 0.0f;
    
    // --- View is portrait ---

    float aspectRatioVideo = (float)videoMode.mWidth / (float)videoMode.mHeight;
    float aspectRatioView = viewHeight / viewWidth;
    
    if (aspectRatioVideo < aspectRatioView) {
        config.mSize.data[0] = (int)videoMode.mHeight * (viewHeight / (float)videoMode.mWidth);
        config.mSize.data[1] = (int)viewHeight;
    } else {
        config.mSize.data[0] = (int)viewWidth;
        config.mSize.data[1] = (int)videoMode.mWidth * (viewWidth / (float)videoMode.mHeight);
    }
    
    // Calculate the viewport for the app to use when rendering
    viewport.posX = ((viewWidth - config.mSize.data[0]) / 2) + config.mPosition.data[0];
    viewport.posY = (((int)(viewHeight - config.mSize.data[1])) / (int) 2) + config.mPosition.data[1];
    viewport.sizeX = config.mSize.data[0];
    viewport.sizeY = config.mSize.data[1];
    
//#ifdef DEBUG_SAMPLE_APP
    NSLog(@"VideoBackgroundConfig: size: %d,%d", config.mSize.data[0], config.mSize.data[1]);
    NSLog(@"VideoMode:w=%d h=%d", videoMode.mWidth, videoMode.mHeight);
    NSLog(@"width=%7.3f height=%7.3f", viewWidth, viewHeight);
    NSLog(@"ViewPort: X,Y: %d,%d Size X,Y:%d,%d", viewport.posX,viewport.posY,viewport.sizeX,viewport.sizeY);
//#endif
    
    QCAR::Renderer::getInstance().setVideoBackgroundConfig(config);
}

- (NSError*) startAROnBackCameraWithViewWidth:(float)viewWidth andHeight:(float)viewHeight {
    // initialize the camera
    if (!QCAR::CameraDevice::getInstance().init(QCAR::CameraDevice::CAMERA_BACK)) {
        return [self NSErrorWithCode:-1];
    }
    
    // start the camera
    if (!QCAR::CameraDevice::getInstance().start()) {
        return [self NSErrorWithCode:-1];
    }
    
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
    if(tracker == 0) {
        return [self NSErrorWithCode:-1];
    }    
    tracker->start();
    
    // configure QCAR video background
    [self configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
    
    // Cache the projection matrix
    const QCAR::CameraCalibration& cameraCalibration = QCAR::CameraDevice::getInstance().getCameraCalibration();
    setFromQCARMatrix(_projectionMatrix, QCAR::Tool::getProjectionGL(cameraCalibration, 2.0f, 5000.0f));
    return nil;
}

- (NSError*) startAR {
    float w = mViewSize.width, h = mViewSize.height;
    NSError* err = [self startAROnBackCameraWithViewWidth:w andHeight:h];
    QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
    return err;
}

- (ARMatrix44F) getProjectionMatrix {
    return _projectionMatrix;
}


@end
