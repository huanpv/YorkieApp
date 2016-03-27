//
//  DateofNextEvent.m
//  Yorkie
//
//  Created by Carlos Butron on 08/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "DateofNextEvent.h"
#import "NotificationMessage.h"
#import "NotificationBeforeDays.h"

@implementation DateofNextEvent

+ (BOOL)noticeNextEventDate:(NSDate *)myDate withBeforeDays:(NSInteger)beforeDays withRoutineID:(NSInteger)routineID{
    
    BOOL red=FALSE;
    
    //get today date
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate * today = [NSDate date];
    NSDate * todayPlus = [NSDate date];
    
    //set date without time
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* componentsToday = [calendar components:flags fromDate:today];
    NSDateComponents* componentsTodayPlus = [calendar components:flags fromDate:todayPlus];
    NSDateComponents* componentsMyDate = [calendar components:flags fromDate:myDate];
    
    today = [calendar dateFromComponents:componentsToday];
    todayPlus = [calendar dateFromComponents:componentsTodayPlus];
    myDate = [calendar dateFromComponents:componentsMyDate];

        //sum before days to today
        todayPlus = [cal dateByAddingUnit:NSCalendarUnitDay
                             value:beforeDays
                            toDate:today
                           options:0];
    
        NSComparisonResult result = [myDate compare:todayPlus];
    
        //    switch (result)
        //    {
        //        case NSOrderedAscending: NSLog(@"%@ is in future from %@", myDate, today); break;
        //        case NSOrderedDescending: NSLog(@"%@ is in past from %@", myDate, today); break;
        //        case NSOrderedSame: NSLog(@"%@ is the same as %@", myDate, today); break;
        //        default: NSLog(@"erorr dates %@, %@", myDate, today); break;
        //    }
        
        //if date is equal today or future than today then return this date
        if ((result==NSOrderedSame) || (result==NSOrderedAscending)) {
            
            red = YES;
            
            //when frequency is 0 if mydate is in past from today. NOT RED
            NSComparisonResult resultFix = [myDate compare:today];
            
                if (resultFix==NSOrderedAscending) {
                    //red = NO;
                    
                    //if frequency is 0 and date is end then delete routine
                    //open database
                    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    NSString *documentsDir = [docPaths objectAtIndex:0];
                    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
                    
                    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
                    [database open];
                    
                    //edit Yorkie Row
                    BOOL successYorkie = [database executeUpdate:@"UPDATE routine SET startDate = '', lastDate = '' , frequency = '', comment = '' WHERE idRoutine = ?", [NSString stringWithFormat:@"%ld", (long)routineID], nil];
                    
                    if (!successYorkie) {
                        NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                        // do whatever you need to upon error
                    }
                    
                    [database close];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAppDelegateTable" object:nil];
                }
        } else {
            red = NO;
        }
        
    return red;
}

+ (NSDate*)nextEventDate:(NSDate*)myDate withFrequency:(NSInteger)frequency {
    
    if (myDate==NULL) {
        return myDate;
    } else if (frequency==0) {
        return myDate;
    } else {
        //get today date
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate * today = [NSDate date];
        
        //set date without time
        unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* componentsToday = [calendar components:flags fromDate:today];
        NSDateComponents* componentsMyDate = [calendar components:flags fromDate:myDate];
        
        today = [calendar dateFromComponents:componentsToday];
        myDate = [calendar dateFromComponents:componentsMyDate];
        
        NSComparisonResult result = [today compare:myDate];
    
    //if date is equal today or future than today then return this date
    //if ((result==NSOrderedSame) || (result==NSOrderedAscending)) {
        if (result==NSOrderedAscending) {
            return myDate;
        } else { //if date is in past sum
            while ((result==NSOrderedDescending) || (result==NSOrderedSame)) {
            // set up date components
            myDate = [cal dateByAddingUnit:NSCalendarUnitDay
                                     value:frequency
                                    toDate:myDate
                                   options:0];
            result = [today compare:myDate];
         }
    }

    return myDate;
    }
}

//nextEventDateWithNotificationUpdate
+ (NSDate*)nextEventDateWithNotificationUpdate:(NSDate*)myDate withRoutineTypeID:(NSInteger)routineTypeID withFrequency:(NSInteger)frequency  withAdviceBefore:(NSInteger)adviceBefore withNameYorkie:(NSString *)nameYorkie andDatabase:(FMDatabase *)database {
    
    if (myDate==NULL) {
        return myDate;
    } else if (frequency==0) {
        return myDate;
    } else {
        //get today date
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate * today = [NSDate date];
        
        //set date without time
        unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* componentsToday = [calendar components:flags fromDate:today];
        NSDateComponents* componentsMyDate = [calendar components:flags fromDate:myDate];
        
        today = [calendar dateFromComponents:componentsToday];
        myDate = [calendar dateFromComponents:componentsMyDate];
        
        NSComparisonResult result = [today compare:myDate];
        
        //if date is equal today or future than today then return this date
        if ((result==NSOrderedSame) || (result==NSOrderedAscending)) {
            return myDate;
        } else { //if date is in past sum
            while (result==NSOrderedDescending) {
                // set up date components
                myDate = [cal dateByAddingUnit:NSCalendarUnitDay
                                         value:frequency
                                        toDate:myDate
                                       options:0];
                result = [today compare:myDate];
            }

            //edit Yorkie Row
            BOOL successYorkie = [database executeUpdate:@"UPDATE routine SET lastDate = ? WHERE idRoutine = ?", [NSString stringWithFormat:@"%@", myDate], [NSString stringWithFormat:@"%ld", (long)routineTypeID], nil];

            if (!successYorkie) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            
            //HERE PUT THE CODE TO DELETE LAST NOTIFICATIONS AND ADD NEW NOTIFICATIONS
            
            //SET LOCAL NOTIFICATIONS.
            
            //FIRST IF EXIST SOME NOTIFICATION FROM THIS ROUTINE DELETE IT
            //delete local notifications from this routine
            NSString *notificationID = [NSString stringWithFormat:@"%ld", (long)routineTypeID];
            
            for(UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications])
            {
                if([[notify.userInfo objectForKey:@"ID"] isEqualToString:notificationID])
                {
                    [[UIApplication sharedApplication] cancelLocalNotification:notify];
                }
            }
            
            
            //SECOND CREATE NEW NOTIFICATIONS (1 DAY BEFORE AND OTHER)

            //NOTIFY 1 DAY BEFORE
            NSCalendar *cal1 = [NSCalendar currentCalendar];
            NSDate *notifyDate1 = myDate;
            //substract the days of frequency from the date of textfield
            notifyDate1 = [cal1 dateByAddingUnit:NSCalendarUnitDay
                                           value:-1
                                          toDate:myDate
                                         options:0];
            
            //add to date 12 hours finally date is the
            //DAY BEFORE AT 12.00 IN THE MORNING
            //example 2015-08-14 10:00:00 +0000
            //formato español 14-08-2015 12.00h  (NOTE: SPANISH FORMAT IS THE ORIGINAL TIME +2H)
            notifyDate1 = [notifyDate1 dateByAddingTimeInterval:60*60*12*1];
            
            // Schedule the notification
            UILocalNotification* localNotification1 = [[UILocalNotification alloc] init];
            localNotification1.fireDate = notifyDate1; //date
            localNotification1.alertBody = [NSString stringWithFormat:@"%@ %@", [NotificationMessage notificationMessage:routineTypeID withYorkieName:nameYorkie], NSLocalizedString(@"tomorrow", nil)];
            
            localNotification1.soundName = UILocalNotificationDefaultSoundName;
            localNotification1.timeZone = [NSTimeZone defaultTimeZone];
            localNotification1.userInfo = @{@"ID" : [NSString stringWithFormat:@"%ld",(long)routineTypeID],};
            localNotification1.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification1];
            
            //NOTIFY WITH LONG ADVICE
            if ((adviceBefore==3) || (adviceBefore==5)) {
                
                NSCalendar *calLong = [NSCalendar currentCalendar];
                NSDate *notifyDateLong = myDate;
                //substract the days of frequency from the date of textfield
                notifyDateLong = [calLong dateByAddingUnit:NSCalendarUnitDay
                                                     value:-adviceBefore
                                                    toDate:myDate
                                                   options:0];
                
                //add to date 12 hours finally date is the
                //DAY BEFORE AT 12.00 IN THE MORNING
                //example 2015-08-14 10:00:00 +0000
                //formato español 14-08-2015 12.00h  (NOTE: SPANISH FORMAT IS THE ORIGINAL TIME +2H)
                notifyDateLong = [notifyDateLong dateByAddingTimeInterval:60*60*12*1];
                
                // Schedule the notification
                UILocalNotification* localNotificationLong = [[UILocalNotification alloc] init];
                localNotificationLong.fireDate = notifyDateLong; //date
                localNotificationLong.alertBody = [NSString stringWithFormat:@"%@ %@", [NotificationMessage notificationMessage:routineTypeID withYorkieName:nameYorkie], NSLocalizedString(@"soon", nil)];
                
                localNotificationLong.soundName = UILocalNotificationDefaultSoundName;
                localNotificationLong.timeZone = [NSTimeZone defaultTimeZone];
                localNotificationLong.userInfo = @{@"ID" : [NSString stringWithFormat:@"%ld",(long)routineTypeID],};
                localNotificationLong.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotificationLong];
            }
        }

        return myDate;
    }
}

//CALCULATE AGE FROM BIRTHDAY TO SET IN TABLEVIEW
//AND WRITE IN FORMAT "14th september" or "14 de septiembre"
+ (NSString *)age:(NSDate *)dateOfBirth {
    
    if (dateOfBirth) {
       //locale info
        NSString *language;
        NSInteger years;
        NSInteger months;
        NSInteger days = 0;
        NSString *daySuffix;
        NSString *newDate;
    
        //iPhone language
        language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dateOfBirth]; // Get necessary date components
    
        months = [components month]; //gives you month
        days = [components day]; //gives you day
        years = [components year]; // gives you year
    
        if ([language isEqualToString:@"es"]) {
            daySuffix=@" de";
        } else {
            if ((days==1) || (days==21) || (days==31)){
                daySuffix=@"st";
            } else if ((days==2) || (days==22)){
                daySuffix=@"nd";
            } else if ((days==3) || (days==23)){
                daySuffix=@"rd";
            } else {
                daySuffix=@"th";
            }
        }
    
        //get a month in int format and return the name of month
        NSDateFormatter *formate = [NSDateFormatter new];
        NSArray *monthNames = [formate standaloneMonthSymbols];
        NSString *monthName = [monthNames objectAtIndex:(months - 1)];

        newDate = [NSString stringWithFormat:@"%ld%@ %@", (long)days, daySuffix, monthName];
    
        return newDate;
    }
    NSString *newDate;
    return newDate;
}

@end
