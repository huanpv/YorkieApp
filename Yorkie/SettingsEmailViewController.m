//
//  SettingsEmailViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 24/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "SettingsEmailViewController.h"

@interface SettingsEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *emailTextView;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
//to move view on textview edit
@property CGPoint originalCenter;
@property CGFloat currentTextFieldOriginY;
@property CGFloat currentTextFieldHeight;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property NSInteger iphoneModel; //to save the iPhone model and present the screen size in a perfect way

@end

@implementation SettingsEmailViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];

    self.commentLabel.text = NSLocalizedString(@"Write a comment", nil);
    //get screen size
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat height = CGRectGetHeight(screen);
    //set model (get the iPhone model screen size and set the custom cell for that size)
    switch ((int)height) {
        case 480:
            self.iphoneModel = 4;
            break;
        case 568:
            self.iphoneModel = 5;
            break;
        case 667:
            self.iphoneModel = 6;
            break;
        case 736:
            self.iphoneModel = 7;
            break;
        default:
            self.iphoneModel = 7;
            break;
    }
    
    self.title = NSLocalizedString(@"Send email", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.emailButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    self.emailButton.layer.cornerRadius = 5;
    self.emailTextView.layer.cornerRadius = 5;
    
    self.emailTextView.delegate = self;
    
    //notification of keyboard willshow and willhide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //original position of view
    self.originalCenter = self.view.center;
}

#pragma mark - Keyboard Control
//control keyboard appears to move view position

- (void)keyboardWillShow:(NSNotification*)notification 
{
    //get the frame origin y of the send button
    self.currentTextFieldOriginY = self.emailButton.frame.origin.y;
    self.currentTextFieldHeight = self.emailButton.frame.size.height;
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat deltaHeight = kbSize.height;
    
    switch (self.iphoneModel) {
        case 4: {
            self.currentTextFieldOriginY = self.emailTextView.frame.origin.y+self.emailTextView.frame.size.height;
            if ((self.currentTextFieldOriginY) > (self.view.frame.size.height-deltaHeight)) {
                self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y + ((self.view.frame.size.height-deltaHeight)-(self.currentTextFieldOriginY+10)) );
            } }
            break;
        case 6: {
            if ((self.currentTextFieldOriginY+self.currentTextFieldHeight+25) > (self.view.frame.size.height-deltaHeight)) {
                self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y + ((self.view.frame.size.height-deltaHeight)-(self.currentTextFieldOriginY+self.currentTextFieldHeight+48)) );
            } }
            break;
        default: {
            if ((self.currentTextFieldOriginY+self.currentTextFieldHeight+25) > (self.view.frame.size.height-deltaHeight)) {
                self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y + ((self.view.frame.size.height-deltaHeight)-(self.currentTextFieldOriginY+self.currentTextFieldHeight+25)) );
            } }
            break;
    }
}

- (void)keyboardWillHide:(NSNotification*)notification 
{
    self.view.center = self.originalCenter;
}

- (IBAction)actionSend:(id)sender 
{
    [self sendEmail];
}



//hide keyboard on touch outside textField
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self.view endEditing:YES];
}

- (void)sendEmail 
{
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        [mailCont setSubject:@"Yorkie Feedback"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"yorkieapp@yahoo.com"]];
        [mailCont setMessageBody:self.emailTextView.text isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    switch (result) {
        case MFMailComposeResultSent:
            //NSLog(@"You sent the email.");
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            //NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            //NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
