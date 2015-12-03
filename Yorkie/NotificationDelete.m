//
//  NotificationDelete.m
//  Yorkie
//
//  Created by Carlos Butron on 28/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "NotificationDelete.h"

@implementation NotificationDelete

+ (void)notificationDelete:(NSInteger)routineID {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAppDelegateTable" object:nil];
    
    //delete local notifications from this routine
    NSString *notificationID = [NSString stringWithFormat:@"%ld", (long)routineID];
    
    for(UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if([[notify.userInfo objectForKey:@"ID"] isEqualToString:notificationID])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
        }
    }
    
}

@end
