//
//  UITextFieldLimit.h
//  UITextFieldLimit
//
//  Created by Jonathan Gurebo on 2014-04-12.
//  Copyright (c) 2014 Jonathan Gurebo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UITextFieldLimit;

@protocol UITextFieldLimitDelegate<UITextFieldDelegate>

@optional
-(void)textFieldLimit:(UITextFieldLimit *)textFieldLimit didWentOverLimitWithDisallowedText:(NSString *)text inDisallowedRange:(NSRange)range;
-(void)textFieldLimit:(UITextFieldLimit *)textFieldLimit didReachLimitWithLastEnteredText:(NSString *)text inRange:(NSRange)range;
@end

@interface UITextFieldLimit : UITextField<UITextFieldDelegate> {
    long limit;
    UILabel *limitLabel;
}
@property (nonatomic, assign) id<UITextFieldLimitDelegate> delegate;

@property (readwrite, nonatomic) long limit;
@property (retain, nonatomic) UILabel *limitLabel;

@end
