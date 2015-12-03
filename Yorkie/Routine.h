//
//  Routine.h
//  Yorkie
//
//  Created by Carlos Butron on 12/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Routine : NSObject

@property (nonatomic) NSInteger routineID;
@property (nonatomic) NSInteger yorkieID;
@property (nonatomic) NSInteger routineTypeID;
@property (nonatomic) NSInteger routineNotice;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSDate *nextDate;
@property (nonatomic, strong) NSString *lastDate;
@property (nonatomic) NSInteger frecuency;
@property (nonatomic) NSString *imageDesc;
@property (nonatomic) NSString *imageName;

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
                      andImageName:(NSString *)imageName;



@end
