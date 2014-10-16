//
//  ARDataSetManager.m
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import "ARDataSetManager.h"
#import <QCAR/DataSet.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ImageTracker.h>


@implementation ARDataSetManager {
    NSMutableDictionary* dataSetByName;
}

QCAR::ImageTracker* getImageTracker() {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    if (NULL == imageTracker) {
        NSLog(@"ERROR: failed to get the ImageTracker from the tracker manager");
        return NULL;
    }
    return imageTracker;
}

- (QCAR::DataSet*) getDataSetByName:(NSString*) name {
    NSValue* value = [dataSetByName objectForKey:name];
    if (nil == value) return NULL;
    return (QCAR::DataSet*)[value pointerValue];
}

- (id) init {
    self = [super init];
    if (self) {
        dataSetByName = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL) createDataSetByName:(NSString*) name {
    NSLog(@"Attempt to create dataSet (%@)", name);
    
    if (NULL != [self getDataSetByName:name]) {
        NSLog(@"dataset (%@) already exists.", name);
        return NO;
    }
    
    QCAR::ImageTracker* imageTracker = getImageTracker();
    if (NULL == imageTracker) return NO;
    
    QCAR::DataSet* dataSet = imageTracker->createDataSet();
    if (NULL == dataSet) {
        NSLog(@"ERROR: failed to create dataset (%@)", name);
        return NO;
    }
    
    NSLog(@"INFO: successfully created dataset (%@)", name);
    return YES;
}

- (BOOL) createDataSetByName:(NSString*) name DataFile:(NSString*) dataFile {
    BOOL ok = [self createDataSetByName:name];
    if (!ok) return NO;
    
    QCAR::DataSet* dataSet = [self getDataSetByName:name];
    if (NULL == dataSet) return NO;
    
    // Load the data set from the app's resources location
    if (!dataSet->load([dataFile cStringUsingEncoding:NSASCIIStringEncoding], QCAR::STORAGE_APPRESOURCE)) {
        NSLog(@"ERROR: failed to load data set");
        
        QCAR::ImageTracker* imageTracker = getImageTracker();
        imageTracker && imageTracker->destroyDataSet(dataSet);
        return NO;
    }
    
    [dataSetByName setObject:[NSValue valueWithPointer:dataSet] forKey:name];
    return YES;
}

- (BOOL) removeDataSetByName:(NSString*) name {
    QCAR::DataSet* dataSet = [self getDataSetByName:name];
    if (NULL == dataSet) return NO;
    
    [self deactivateDataSetByName:name];
    
    QCAR::ImageTracker* imageTracker = getImageTracker();
    
    if (!imageTracker->destroyDataSet(dataSet)) {
        NSLog(@"Failed to destroy data set %@.", name);
        return NO;
    }
    
    [dataSetByName removeObjectForKey:name];
    NSLog(@"datasets %@ destroyed", name);
    
    return YES;
}

- (BOOL) isDataSetActive:(NSString*) name {
    QCAR::DataSet* dataSet = [self getDataSetByName:name];
    if (NULL == dataSet) return NO;
    return dataSet->isActive();
}

- (BOOL) activateDataSetByName:(NSString*) name {
    QCAR::DataSet* dataSet = [self getDataSetByName:name];
    if (NULL == dataSet) return NO;

    QCAR::ImageTracker* imageTracker = getImageTracker();
    if (imageTracker == NULL) return NO;
    
    if (!imageTracker->activateDataSet(dataSet)) {
        NSLog(@"Failed to activate data set.");
        return NO;
    }
    
    // [self setExtendedTrackingForDataSet:dataSet start:YES];
    NSLog(@"Successfully activated data set.");
    return YES;
}

- (BOOL) deactivateDataSetByName:(NSString*) name {
    QCAR::DataSet* dataSet = [self getDataSetByName:name];
    if (NULL == dataSet) return NO;
    
    // [self setExtendedTrackingForDataSet:theDataSet start:NO];
    
    QCAR::ImageTracker* imageTracker = getImageTracker();
    
    if (imageTracker == NULL) return NO;

    if (!imageTracker->deactivateDataSet(dataSet)) {
        NSLog(@"Failed to deactivate data set.");
        return NO;
    }
    
    return YES;
}

- (NSArray*) getDateSetNameList {
    return [dataSetByName allKeys];
}

- (NSString*) getActiveDataSet {
    NSArray* allDataSets = [self getDateSetNameList];
    for (NSString* dataSetName in allDataSets) {
        if ([self isDataSetActive:dataSetName]) {
            return dataSetName;
        }
    }
    return nil;
}



@end
