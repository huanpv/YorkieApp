//
//  SaveYorkieViewController.h
//  Yorkie
//
//  Created by Carlos Butron on 19/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextFieldLimit.h"

//this protocol-delegate send an alert to reload collectionCell detail view when
//user edit data
@protocol SaveYorkieViewControllerEditDelegate
-(void)reloadDetail;
@end

@interface MainSaveViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource,UIPickerViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UITextFieldLimitDelegate>

@property(retain,nonatomic) id<SaveYorkieViewControllerEditDelegate> delegate;
//get from the last view if we need to delete or edit Yorkie
@property BOOL save;
@property BOOL edit;
@property NSInteger idYorkie;

@end
