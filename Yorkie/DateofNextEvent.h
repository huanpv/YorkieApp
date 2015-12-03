//
//  DateofNextEvent.h
//  Yorkie
//
//  Created by Carlos Butron on 08/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h" //database
#import "FMDatabase.h" // from cocoa pods and github

@interface DateofNextEvent : UIViewController

+ (BOOL)noticeNextEventDate:(NSDate *)myDate withBeforeDays:(NSInteger)beforeDays withRoutineID:(NSInteger)routineID;
+ (NSDate*)nextEventDate:(NSDate*)myDate withFrequency:(NSInteger)frequency;
+ (NSDate*)nextEventDateWithNotificationUpdate:(NSDate*)myDate withRoutineTypeID:(NSInteger)routineTypeID withFrequency:(NSInteger)frequency  withAdviceBefore:(NSInteger)adviceBefore withNameYorkie:(NSString *)nameYorkie andDatabase:(FMDatabase *)database;
+ (NSString *)age:(NSDate *)dateOfBirth;

@end









