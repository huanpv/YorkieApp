//
//  Routine.m
//  Yorkie
//
//  Created by Carlos Butron on 12/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "Routine.h"

@implementation Routine
    
- (instancetype) initWithRoutineID:(NSInteger )routineID
                       andYorkieID:(NSInteger )yorkieID
                  andRoutineTypeID:(NSInteger )routineTypeID
                  andRoutineNotice:(NSInteger )routineNotice
                           andName:(NSString *)name
                      andStartDate:(NSString *)startDate
                       andNextDate:(NSDate   *)nextDate
                       andLastDate:(NSString *)lastDate
                      andFrecuency:(NSInteger )frecuency
                      andImageDesc:(NSString *)imageDesc
                      andImageName:(NSString *)imageName {
 
    if (self = [super init]) {
        _routineID = routineID;
        _yorkieID = yorkieID;
        _routineTypeID = routineTypeID;
        _routineNotice = routineNotice;
        _name = name;
        _startDate = startDate;
        _nextDate = nextDate;
        _lastDate = lastDate;
        _frecuency = frecuency;
        _imageDesc = imageDesc;
        _imageName = imageName;
    }
    
    return self;
}

@end
