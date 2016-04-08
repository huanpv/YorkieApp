//
//  NotificationMessage.h
//  Yorkie
//
//  Created by Carlos Butron on 15/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationMessage : NSObject

+ (NSString*)notificationMessage:(NSInteger)routineTypeID withYorkieName:(NSString *)yorkieName;

@end
