//
//  NotificationMessage.m
//  Yorkie
//
//  Created by Carlos Butron on 15/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "NotificationMessage.h"

@implementation NotificationMessage

+ (NSString*)notificationMessage:(NSInteger)routineTypeID withYorkieName:(NSString *)yorkieName{

    NSString * noticeName;
    switch (routineTypeID) {
        case 1: //hair salon
            noticeName = [NSString stringWithFormat:@"%@ %@", yorkieName, NSLocalizedString(@"has an appointment at the hair salon", nil)];
            break;
        case 2: //bath
            noticeName = [NSString stringWithFormat:@"%@ %@", yorkieName, NSLocalizedString(@"has a bath pending", nil)];
            break;
        case 3: //antiparasitic
            noticeName = [NSString stringWithFormat:@"%@ %@", yorkieName, NSLocalizedString(@"needs to take the antiparasitic pill", nil)];
            break;
        case 4: //dental care
            noticeName = [NSString stringWithFormat:@"%@ %@", yorkieName, NSLocalizedString(@"needs a dental care", nil)];
            break;
        case 5: //vaccine
            noticeName = [NSString stringWithFormat:@"%@ %@", yorkieName, NSLocalizedString(@"needs the vaccines", nil)];
            break;
        case 6: //pills
            noticeName = [NSString stringWithFormat:@"%@ %@", yorkieName, NSLocalizedString(@"needs the pills", nil)];
            break;
        case 7: //medicine
            noticeName = [NSString stringWithFormat:@"%@ %@", yorkieName, NSLocalizedString(@"needs the medicine", nil)];
            break;
        default:
            break;
    }

    return noticeName;
}

@end
