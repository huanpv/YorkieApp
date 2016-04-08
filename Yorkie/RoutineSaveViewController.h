//
//  SaveDetailViewController.h
//  Yorkie
//
//  Created by Carlos Butron on 26/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextFieldLimit.h"
#import "Routine.h"

@interface RoutineSaveViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource,UIPickerViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITextFieldLimitDelegate, UITextViewDelegate>

@property NSInteger idRoutine;
@property NSInteger iphoneModel; //to save the iPhone model and present the screen size in a perfect way
@property (nonatomic, strong) Routine *routine; //when user comes from RoutineViewController and edit
@property BOOL edit;

@end
