//
//  NotificationBeforeDays.m
//  Yorkie
//
//  Created by Carlos Butron on 15/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "NotificationBeforeDays.h"

@implementation NotificationBeforeDays

+ (NSInteger)notificationBeforeDays:(NSInteger)routineTypeID {
    
    
    NSInteger beforeDays;
    switch (routineTypeID) {
        case 1: //hair salon
            beforeDays = 3;
            break;
        case 2: //bath
            beforeDays = 3;
            break;
        case 3: //antiparasitic
            beforeDays = 3;
            break;
        case 4: //dental care
            beforeDays = 5;
            break;
        case 5: //vaccine
            beforeDays = 5;
            break;
        case 6: //pills
            beforeDays = 1;
            break;
        case 7: //medicine
            beforeDays = 1;
            break;
            
        default:
            break;
    }
    
    
    return beforeDays;
    
}

@end
