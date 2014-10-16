//
//  ARDataSetManager.h
//  scenekit-test0
//
//  Created by Li Ge on 10/15/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARDataSetManager: NSObject
- (BOOL) createDataSetByName:(NSString*) name;
- (BOOL) createDataSetByName:(NSString*) name DataFile:(NSString*) dataFile;
- (BOOL) removeDataSetByName:(NSString*) name;
- (BOOL) isDataSetActive:(NSString*) name;
- (BOOL) activateDataSetByName:(NSString*) name;
- (BOOL) deactivateDataSetByName:(NSString*) name;
- (NSArray*) getDateSetNameList;
@end