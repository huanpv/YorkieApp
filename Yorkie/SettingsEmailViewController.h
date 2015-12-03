//
//  SettingsEmailViewController.h
//  Yorkie
//
//  Created by Carlos Butron on 24/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsEmailViewController : UIViewController<MFMailComposeViewControllerDelegate,UITextViewDelegate>

@end
