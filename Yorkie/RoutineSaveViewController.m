//
//  SaveDetailViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 26/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "RoutineSaveViewController.h"
#import "sqlite3.h" //database
#import "FMDatabase.h" // from cocoa pods and github
#import "MainViewController.h"
#import "NotificationMessage.h"
#import "NotificationBeforeDays.h"
#import "NotificationDelete.h"
#import "DateofNextEvent.h"

@interface RoutineSaveViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewSaveRoutine;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *frequencyTextField;
@property (weak, nonatomic) IBOutlet UITextField *daysTextField;
@property (weak, nonatomic) IBOutlet UITextFieldLimit *commentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageRoutine;
@property (weak, nonatomic) IBOutlet UILabel *routineLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;

//move view to edit textfields
@property CGPoint originalCenter;
@property CGFloat currentTextFieldOriginY;
@property CGFloat currentTextFieldHeight;

//locale info
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *region;

//property picker (frequency)
@property (nonatomic, strong) UIPickerView *myPickerView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (nonatomic, strong) NSArray *pickerArray;

@end


@implementation RoutineSaveViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    [self.commentTextField setLimit:35];
    self.imageRoutine.image = [UIImage imageNamed:self.routine.imageName];
    self.nextLabel.text = NSLocalizedString(@"Next", nil);
    self.routineLabel.text = NSLocalizedString(self.routine.imageDesc, nil);
    
    //picker with frequency
    [self addPickerView];
    
    //fix to spanish language
    if (([self.routineLabel.text isEqualToString:@"Peluquería"]) || ([self.routineLabel.text isEqualToString:@"Vacunación"])) {
        self.nextLabel.text = @"Próxima";
    }
    
    //fix to spanish language
    if (([self.routineLabel.text isEqualToString:@"Peluquería"]) || ([self.routineLabel.text isEqualToString:@"Vacunación"]) || ([self.routineLabel.text isEqualToString:@"Pastilla"]) || ([self.routineLabel.text isEqualToString:@"Medicina"])) {
        self.nextLabel.text = @"Próxima";
    }

    self.startDateTextField.delegate = self;
    self.frequencyTextField.delegate = self;
    self.daysTextField.delegate = self;
    self.commentTextField.delegate = self;

    //iPhone language
    self.language = [[NSLocale preferredLanguages] objectAtIndex:0];
    self.region = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    self.deleteButton.layer.cornerRadius = 5;  //delete button corner radius

    self.viewSaveRoutine.clipsToBounds = YES;
    self.viewSaveRoutine.layer.cornerRadius = 5;
    self.viewSaveRoutine.layer.masksToBounds = YES;

    //datepicker with startDate
    self.datePicker = [[UIDatePicker alloc]init];
    self.datePicker.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:178.0/255.0 blue:185.0/255.0 alpha:1];
    
    if (self.edit) { //if come from edit set date is equal to saved yorkie date
        self.daysTextField.text = [NSString stringWithFormat:@"%ld", (long)self.routine.frecuency];
        
        //set frequency text
        switch (self.routine.frecuency) {
            case 0:
                self.frequencyTextField.text = NSLocalizedString(@"Never", nil);
                break;
            case 1:
                self.frequencyTextField.text = NSLocalizedString(@"Every day", nil);
                break;
            case 7:
                self.frequencyTextField.text = NSLocalizedString(@"Every week", nil);
                break;
            case 14:
                self.frequencyTextField.text = NSLocalizedString(@"Every 2 weeks", nil);
                break;
            case 21:
                self.frequencyTextField.text = NSLocalizedString(@"Every 3 weeks", nil);
                break;
            case 30:
                self.frequencyTextField.text = NSLocalizedString(@"Every month", nil);
                break;
            case 60:
                self.frequencyTextField.text = NSLocalizedString(@"Every 2 months", nil);
                break;
            case 90:
                self.frequencyTextField.text = NSLocalizedString(@"Every 3 months", nil);
                break;
            case 180:
                self.frequencyTextField.text = NSLocalizedString(@"Every 6 months", nil);
                break;
            case 365:
                self.frequencyTextField.text = NSLocalizedString(@"Every year", nil);
                break;
                
            default: {
                self.frequencyTextField.text = NSLocalizedString(@"Custom", nil);
                self.daysTextField.enabled = TRUE;
            }
                break;
        }

        self.commentTextField.text = self.routine.name;

            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            //multilingual support to show date of birth
            if ([self.region isEqualToString:@"US"]) { //if is "US"
                NSString *str = self.routine.startDate; // here this is your date with format dd-MM-yyy
                [dateFormat setDateFormat:@"dd/MM/yyyy"]; // here set format of date which is in your output date (means above str with format)
                NSDate *date = [dateFormat dateFromString: str]; // here you can fetch date from string with define format
                dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MM/dd/yyyy"];// here set format which you want...
                
                NSString *convertedString = [dateFormat stringFromDate:date]; //here convert date in NSString
                self.startDateTextField.text = convertedString;
            } else { //if is "es" or others
                self.startDateTextField.text = self.routine.startDate;
                [dateFormat setDateFormat:@"dd/MM/yyyy"];
            }
        
            if (self.startDateTextField.text.length==0){
                [self.datePicker setDate:[NSDate date]];
            } else {
                NSDate *eventDate = [dateFormat dateFromString:self.startDateTextField.text];
                [self.datePicker setDate:eventDate];
            }
    }

    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.startDateTextField setInputView:self.datePicker];

    //set the placeholder of textfield to support multilingual
    NSAttributedString *startDateTextField = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Start date", nil)]];
    self.startDateTextField.attributedPlaceholder = startDateTextField;
    self.startDateTextField.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    
    NSAttributedString *frequencyTextField = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Frequency", nil)]];
    self.frequencyTextField.attributedPlaceholder = frequencyTextField;
    self.frequencyTextField.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    
    NSAttributedString *daysTextField = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"days", nil)]];
    self.daysTextField.attributedPlaceholder = daysTextField;
    self.daysTextField.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    
    NSAttributedString *commentTextField = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Comment", nil)]];
    self.commentTextField.attributedPlaceholder = commentTextField;
    self.commentTextField.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];

    self.startDateTextField.delegate = self;
    self.frequencyTextField.delegate = self;
    self.daysTextField.delegate = self;
    self.commentTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    //disabled days textfield until frequency textfield are in custom mode
    if ([self.frequencyTextField.text isEqualToString:NSLocalizedString(@"Custom", nil)]) {
        self.daysTextField.enabled = TRUE;
    } else {
        self.daysTextField.enabled = FALSE;
    }

    if ([self.routineLabel.text isEqualToString:@"Cuidado dental"]) {
        switch (self.iphoneModel) {
            case 4: {
                UIFont *routineFont = self.routineLabel.font;
                self.routineLabel.font = [routineFont fontWithSize:22]; //if we need to change only the font size
                UIFont *nextFont = self.nextLabel.font;
                self.nextLabel.font = [nextFont fontWithSize:22];
            }
            case 5: {
                UIFont *routineFont = self.routineLabel.font;
                self.routineLabel.font = [routineFont fontWithSize:24]; //if we need to change only the font size
                UIFont *nextFont = self.nextLabel.font;
                self.nextLabel.font = [nextFont fontWithSize:24];
            }
                break;
            case 6: {
                UIFont *routineFont = self.routineLabel.font;
                self.routineLabel.font = [routineFont fontWithSize:28]; //if we need to change only the font size
                UIFont *nextFont = self.nextLabel.font;
                self.nextLabel.font = [nextFont fontWithSize:42];
            }
                break;
            case 7: {
                UIFont *routineFont = self.routineLabel.font;
                self.routineLabel.font = [routineFont fontWithSize:30]; //if we need to change only the font size
                UIFont *nextFont = self.nextLabel.font;
                self.nextLabel.font = [nextFont fontWithSize:46];
            }
                break;
            default:
                break;
        }
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.view.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1.0];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionSaveButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionCancelButton:)];
    self.navigationItem.leftBarButtonItem = leftButton;

    //get screen size
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat height = CGRectGetHeight(screen);
    
    if (self.edit) {
        
        //set delete button to support iPhone 4s
        switch ((int)height) {
            case 480: {
                self.deleteButton.hidden = YES;
                //add trash button to navigation bar
                UIBarButtonItem *myTrash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemTrash
                                                                                     target: self
                                                                                     action: @selector(actionDeleteButton:)];
            
                NSArray* barButtons = [self.navigationItem.rightBarButtonItems arrayByAddingObject: myTrash];
                self.navigationItem.rightBarButtonItems = barButtons;
            }
            break;
            default:
                self.deleteButton.hidden = NO;
            break;
        }
    } else {
       self.deleteButton.hidden = YES;
    }

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
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //get the frame origin y of the active textField
    self.currentTextFieldOriginY = self.viewSaveRoutine.frame.origin.y;
    self.currentTextFieldHeight = self.viewSaveRoutine.frame.size.height;

    if (textField.tag ==1) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //multilingual support to show date of birth
        if ([self.region isEqualToString:@"US"]) { //if is "US"
            NSString *str = self.startDateTextField.text; // here this is your date with format dd-MM-yyy
            [dateFormat setDateFormat:@"dd/MM/yyyy"]; // here set format of date which is in your output date (means above str with format)
            NSDate *date = [dateFormat dateFromString: str]; // here you can fetch date from string with define format
            dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];// here set format which you want...
            NSString *convertedString = [dateFormat stringFromDate:date]; //here convert date in NSString
            self.startDateTextField.text = convertedString;
        } else { //if is "es" or others
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
        }
        textField.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate: self.datePicker.date]];
    }
    
    if (textField.tag ==2) {
        
        NSInteger indexSelected = [self.myPickerView selectedRowInComponent:0];
        [self.myPickerView selectRow:indexSelected inComponent:0 animated:YES];
        NSString *frequencyPicker = [[self.myPickerView delegate] pickerView:self.myPickerView titleForRow:indexSelected forComponent:0];
        self.frequencyTextField.text = frequencyPicker;        
        
        switch (indexSelected) {
            case 0: //nunca
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"0";
                break;
            case 1: //todos los días
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"1";
                break;
            case 2: //todas las semanas
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"7";
                break;
            case 3: //cada 2 semanas
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"14";
                break;
            case 4: //cada 3 semanas
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"21";
                break;
            case 5: //todos los meses
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"30";
                break;
            case 6: //cada dos meses
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"60";
                break;
            case 7: //cada 3 meses
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"90";
                break;
            case 8: //cada 6 meses
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"180";
                break;
            case 9: //todos los años
                self.daysTextField.enabled = FALSE;
                self.daysTextField.text = @"365";
                break;
            case 10: //custom
                self.daysTextField.enabled = TRUE;
                self.daysTextField.text = @"";
                break;
            default:
                break;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    /* resign first responder, hide keyboard, move views */
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat deltaHeight = kbSize.height;
    
    //only if the position of keyboard is biggest than textfield
    if ((self.currentTextFieldOriginY+self.currentTextFieldHeight+14) > (self.view.frame.size.height-deltaHeight)) {
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y + ((self.view.frame.size.height-deltaHeight)-(self.currentTextFieldOriginY+self.currentTextFieldHeight+8)) );
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.view.center = self.originalCenter;    
}

#pragma mark - datepicker bornDate textfield

- (void)updateTextField:(UIDatePicker *)sender {
    UIDatePicker *picker = (UIDatePicker*)self.startDateTextField.inputView;

    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 400;
    NSDate *newDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                                   toDate: [NSDate date]
                                                                  options:0];
    [picker setMaximumDate:newDate];
    [picker setMinimumDate:[NSDate date]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    
    //multilingual support for datepicker update
    if ([self.region isEqualToString:@"US"]) {
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
    }
    else {
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
    }
    
    NSString *dateString = [dateFormat stringFromDate:eventDate];
    self.startDateTextField.text = [NSString stringWithFormat:@"%@",dateString];
}

#pragma -mark hide keyboard Methods
//hide keyboard on return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//hide keyboard on touch outside textField
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center = self.originalCenter;
    }];
    
    [self.view endEditing:YES];
}

- (IBAction)actionDeleteButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Confirm deleted", nil)]
                          message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete this routine?", nil)]
                          delegate:self
                          cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Cancel", nil)]
                          otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Delete", nil)],nil];
    [alert show];
}

//alertview to confirm delete Yorkie action
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            [alertView dismissWithClickedButtonIndex:0 animated:NO];
            //this is the "Cancel"-Button
            //do something
        }
            break;
        case 1:
        {
            //open database
            NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = [docPaths objectAtIndex:0];
            NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
            
            FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
            [database open];
            
            //edit Yorkie Row
            BOOL successYorkie = [database executeUpdate:@"UPDATE routine SET startDate = '', lastDate = '' , frequency = '', comment = '' WHERE idRoutine = ?", [NSString stringWithFormat:@"%ld", (long)self.idRoutine], nil];
            
            if (!successYorkie) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            
            [database close];

            [NotificationDelete notificationDelete:self.idRoutine];

            MainViewController *mVC = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mVC];
            [self presentViewController:navController animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)actionSaveButton:(id)sender {
    if ([self.startDateTextField.text isEqualToString:@""]) { //filter to check start date not empty
        
            NSAttributedString *startDateLabel = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Start date", nil)] attributes:@{ NSForegroundColorAttributeName : [UIColor redColor] }];
            self.startDateTextField.attributedPlaceholder = startDateLabel;
            self.startDateTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Alert", nil)]
                                                                  message:[NSString stringWithFormat:NSLocalizedString(@"Fill start date field before save", nil)]
                                                                 delegate:nil
                                                        cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)]
                                                        otherButtonTitles: nil];
            [myAlertView show];
    } else {  //if startDate not empty
        //to save format date with multilingual support
        // "es" - "en" and others
        //allways save in "es" format dd/MM/yyyy
        if ([self.region isEqualToString:@"US"]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSString *str = self.startDateTextField.text; /// here this is your date with format dd-MM-yyy
        
            [dateFormat setDateFormat:@"MM/dd/yyyy"]; //// here set format of date which is in your output date (means above str with format)
        
            NSDate *date = [dateFormat dateFromString: str]; // here you can fetch date from string with define format
        
            dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yyyy"];// here set format which you want...
        
            NSString *convertedString = [dateFormat stringFromDate:date]; //here convert date in NSString
            self.startDateTextField.text = convertedString;
        }

        //open database
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [docPaths objectAtIndex:0];
        NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];

        FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
        [database open];
    
        //edit Yorkie Row
        BOOL successYorkie = [database executeUpdate:@"UPDATE routine SET startDate = ?, frequency = ?, comment = ? WHERE idRoutine = ?", [NSString stringWithFormat:@"%@", self.startDateTextField.text], [NSString stringWithFormat:@"%@", self.daysTextField.text], [NSString stringWithFormat:@"%@", self.commentTextField.text], [NSString stringWithFormat:@"%ld", (long)self.idRoutine], nil];

        if (!successYorkie) {
            NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
            // do whatever you need to upon error
        }
    
        [database close];

        //SET LOCAL NOTIFICATIONS.
        
        //FIRST IF EXIST SOME NOTIFICATION FROM THIS ROUTINE DELETE IT
        //delete local notifications from this routine
        NSString *notificationID = [NSString stringWithFormat:@"%ld", (long)self.routine.routineTypeID];
        
        for(UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications])
        {
            if([[notify.userInfo objectForKey:@"ID"] isEqualToString:notificationID])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:notify];
            }
        }

        //THEN CREATE A NEW ONES
        //this set the message text notification and the number of days before
        NSString *noticeName;
        NSInteger advice = 0;
        switch (self.routine.routineTypeID) {
            case 1: //hair salon
                noticeName = [NotificationMessage notificationMessage:self.routine.routineTypeID withYorkieName:self.title];
                //
                advice = [NotificationBeforeDays notificationBeforeDays:self.routine.routineTypeID];
                break;
            case 2: //bath
                noticeName = [NotificationMessage notificationMessage:self.routine.routineTypeID withYorkieName:self.title];
                //
                advice = [NotificationBeforeDays notificationBeforeDays:self.routine.routineTypeID];
                break;
            case 3: //antiparasitic
                noticeName = [NotificationMessage notificationMessage:self.routine.routineTypeID withYorkieName:self.title];
                //
                advice = [NotificationBeforeDays notificationBeforeDays:self.routine.routineTypeID];
                break;
            case 4: //dental care
                noticeName = [NotificationMessage notificationMessage:self.routine.routineTypeID withYorkieName:self.title];
                //
                advice = [NotificationBeforeDays notificationBeforeDays:self.routine.routineTypeID];
                break;
            case 5: //vaccine
                noticeName = [NotificationMessage notificationMessage:self.routine.routineTypeID withYorkieName:self.title];
                //
                advice = [NotificationBeforeDays notificationBeforeDays:self.routine.routineTypeID];
                break;
            case 6: //pills
                noticeName = [NotificationMessage notificationMessage:self.routine.routineTypeID withYorkieName:self.title];
                //
                advice = [NotificationBeforeDays notificationBeforeDays:self.routine.routineTypeID];
                break;
            case 7: //medicine
                noticeName = [NotificationMessage notificationMessage:self.routine.routineTypeID withYorkieName:self.title];
                //
                advice = [NotificationBeforeDays notificationBeforeDays:self.routine.routineTypeID];
                break;
                
            default:
                break;
        }
        
        //get the date from textfield and convert to NSDATE
        NSString *dateString = self.startDateTextField.text;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // this is important - we set our input date format to match our input string
        // if format doesn't match you'll get nil from your string, so be careful
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *dateFromString = [[NSDate alloc] init];  //from startDateTextField
        NSDate *dateFromStringNext = [[NSDate alloc] init];  //from nextDate
        // voila!
        dateFromString = [dateFormatter dateFromString:dateString];

        //calculate the routine from startDate result in errors then is better to transform
        //startDate to nextDate to fix
        dateFromStringNext = [DateofNextEvent nextEventDate:dateFromString withFrequency:[self.daysTextField.text integerValue]];

        //GET TODAY DATE AND STARTDATE WITHOUT TIME AND COMPARE
        //get today date into today and startDate into myDate
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate * today = [NSDate date];
        NSDate * myDate = dateFromStringNext;
        
        //set date without time
        unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents* componentsToday = [calendar components:flags fromDate:today];
        NSDateComponents* componentsMyDate = [calendar components:flags fromDate:dateFromStringNext];
        
        today = [calendar dateFromComponents:componentsToday];   //from todays date
        myDate = [calendar dateFromComponents:componentsMyDate]; //from startDate
        
        
        NSDate * myDateForLoop = [calendar dateFromComponents:componentsMyDate];
        unsigned int distanceDate = 6;
        BOOL notifyWithLongAdvice = FALSE;
        
        for (int i=0; i<6; i++) {
            //startDate from 0 to 5 days and compare with today
            myDateForLoop = [cal dateByAddingUnit:NSCalendarUnitDay
                                     value:-i
                                    toDate:myDate
                                   options:0];
            //compare myDate with today
            NSComparisonResult result = [myDateForLoop compare:today];
            
            //if this is true then startDate are between 1-5 days after todays date
            if (result==NSOrderedSame) {
                distanceDate = i;
            }
        }
        
        switch (distanceDate) {
            case 0:
                //without notification
                break;
            case 1:
                //without notification
                break;
            case 2:{
                //notification only the day before
                notifyWithLongAdvice = FALSE;
                [self notificationWithName:noticeName andLongAdvice:notifyWithLongAdvice andDaysBefore:advice andStartDate:myDate];
            }
                break;
            case 3:{
                //notification only the day before
                notifyWithLongAdvice = FALSE;
                [self notificationWithName:noticeName andLongAdvice:notifyWithLongAdvice andDaysBefore:advice andStartDate:myDate];
            }
                break;
            case 4:{
                if ((advice==1) || (advice==3)){
                    //normal notification
                    notifyWithLongAdvice = TRUE;
                    [self notificationWithName:noticeName andLongAdvice:notifyWithLongAdvice andDaysBefore:advice andStartDate:myDate];
                }
                
                if (advice==5){
                    //notification only the day before
                    notifyWithLongAdvice = FALSE;
                    [self notificationWithName:noticeName andLongAdvice:notifyWithLongAdvice andDaysBefore:advice andStartDate:myDate];
                }
            }
                break;
            case 5:{
                if ((advice==1) || (advice==3)){
                    //normal notification
                    notifyWithLongAdvice = TRUE;
                    [self notificationWithName:noticeName andLongAdvice:notifyWithLongAdvice andDaysBefore:advice andStartDate:myDate];
                }
                
                if (advice==5){
                    //notification only the day before
                    notifyWithLongAdvice = FALSE;
                    [self notificationWithName:noticeName andLongAdvice:notifyWithLongAdvice andDaysBefore:advice andStartDate:myDate];
                }
            }
                break;
            default: {
                //normal notification
                notifyWithLongAdvice = TRUE;
                [self notificationWithName:noticeName andLongAdvice:notifyWithLongAdvice andDaysBefore:advice andStartDate:myDate];
            }
                break;
        }
    }

    [self textFieldsResignFirstResponder];
    //if press save or cancel when keyboard shows, to dismiss keyboard velocity syncronized with dismissview
    [self dismissViewControllerAnimated:YES completion:nil];
   
}

- (void)notificationWithName:(NSString*)notifyName andLongAdvice:(BOOL)notifyWithLongAdvice andDaysBefore:(NSInteger)beforeDays andStartDate:(NSDate *)notifyDate {
    //NOTIFY 1 DAY BEFORE
    NSCalendar *cal1 = [NSCalendar currentCalendar];
    NSDate *notifyDate1 = notifyDate;
    //substract the days of frequency from the date of textfield
    notifyDate1 = [cal1 dateByAddingUnit:NSCalendarUnitDay
                                     value:-1
                                    toDate:notifyDate
                                   options:0];
    
    //add to date 12 hours finally date is the
    //DAY BEFORE AT 12.00 IN THE MORNING
    //example 2015-08-14 10:00:00 +0000
    //formato español 14-08-2015 12.00h  (NOTE: SPANISH FORMAT IS THE ORIGINAL TIME +2H)
    notifyDate1 = [notifyDate1 dateByAddingTimeInterval:60*60*12*1];

    // Schedule the notification
    UILocalNotification* localNotification1 = [[UILocalNotification alloc] init];
    localNotification1.fireDate = notifyDate1; //date
    localNotification1.alertBody = [NSString stringWithFormat:@"%@ %@", notifyName, NSLocalizedString(@"tomorrow", nil)];
    
    localNotification1.soundName = UILocalNotificationDefaultSoundName;
    localNotification1.timeZone = [NSTimeZone defaultTimeZone];
    localNotification1.userInfo = @{@"ID" : [NSString stringWithFormat:@"%ld",(long)self.routine.routineTypeID],};
    localNotification1.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification1];

    //NOTIFY WITH LONG ADVICE
    if (notifyWithLongAdvice==TRUE) {
        NSCalendar *calLong = [NSCalendar currentCalendar];
        NSDate *notifyDateLong = notifyDate;
        //substract the days of frequency from the date of textfield
        notifyDateLong = [calLong dateByAddingUnit:NSCalendarUnitDay
                                     value:-beforeDays
                                    toDate:notifyDate
                                   options:0];
        //add to date 12 hours finally date is the
        //DAY BEFORE AT 12.00 IN THE MORNING
        //example 2015-08-14 10:00:00 +0000
        //formato español 14-08-2015 12.00h  (NOTE: SPANISH FORMAT IS THE ORIGINAL TIME +2H)
        notifyDateLong = [notifyDateLong dateByAddingTimeInterval:60*60*12*1];

        // Schedule the notification
        UILocalNotification* localNotificationLong = [[UILocalNotification alloc] init];
        localNotificationLong.fireDate = notifyDateLong; //date
        localNotificationLong.alertBody = [NSString stringWithFormat:@"%@ %@", notifyName, NSLocalizedString(@"soon", nil)];
        localNotificationLong.soundName = UILocalNotificationDefaultSoundName;
        localNotificationLong.timeZone = [NSTimeZone defaultTimeZone];
        localNotificationLong.userInfo = @{@"ID" : [NSString stringWithFormat:@"%ld",(long)self.routine.routineTypeID],};
        localNotificationLong.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotificationLong];
    }
}

- (IBAction)actionCancelButton:(id)sender {
    [self textFieldsResignFirstResponder];
    //if press save or cancel when keyboard shows, to dismiss keyboard velocity syncronized with dismissview
    [self dismissViewControllerAnimated:YES completion:nil];
}

//if press save or cancel when keyboard shows, to dismiss keyboard velocity syncronized with dismissview
- (void)textFieldsResignFirstResponder {
    [self.startDateTextField resignFirstResponder];
    [self.frequencyTextField resignFirstResponder];
    [self.commentTextField resignFirstResponder];
    [self.daysTextField resignFirstResponder];
}

#pragma mark - picker view frequency textfield

- (void)addPickerView {
    self.pickerArray = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:NSLocalizedString(@"Never", nil)],[NSString stringWithFormat:NSLocalizedString(@"Every day", nil)], [NSString stringWithFormat:NSLocalizedString(@"Every week", nil)], [NSString stringWithFormat:NSLocalizedString(@"Every 2 weeks", nil)], [NSString stringWithFormat:NSLocalizedString(@"Every 3 weeks", nil)], [NSString stringWithFormat:NSLocalizedString(@"Every month", nil)], [NSString stringWithFormat:NSLocalizedString(@"Every 2 months", nil)], [NSString stringWithFormat:NSLocalizedString(@"Every 3 months", nil)], [NSString stringWithFormat:NSLocalizedString(@"Every 6 months", nil)],  [NSString stringWithFormat:NSLocalizedString(@"Every year", nil)], [NSString stringWithFormat:NSLocalizedString(@"Custom", nil)], nil];
    self.myPickerView = [[UIPickerView alloc]init];
    self.myPickerView.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:178.0/255.0 blue:185.0/255.0 alpha:1];
    self.myPickerView.dataSource = self;
    self.myPickerView.delegate = self;
    self.myPickerView.showsSelectionIndicator = YES;
    
    //set default value of picker equal than frequency saved
    switch (self.routine.frecuency) {
        case 0:
            [self.myPickerView selectRow:0 inComponent:0 animated:YES];
            break;
        case 1:
            [self.myPickerView selectRow:1 inComponent:0 animated:YES];
            break;
        case 7:
            [self.myPickerView selectRow:2 inComponent:0 animated:YES];
            break;
        case 14:
            [self.myPickerView selectRow:3 inComponent:0 animated:YES];
            break;
        case 21:
            [self.myPickerView selectRow:4 inComponent:0 animated:YES];
            break;
        case 30:
            [self.myPickerView selectRow:5 inComponent:0 animated:YES];
            break;
        case 60:
            [self.myPickerView selectRow:6 inComponent:0 animated:YES];
            break;
        case 90:
            [self.myPickerView selectRow:7 inComponent:0 animated:YES];
            break;
        case 180:
            [self.myPickerView selectRow:8 inComponent:0 animated:YES];
            break;
        case 365:
            [self.myPickerView selectRow:9 inComponent:0 animated:YES];
            break;
            
        default:
            [self.myPickerView selectRow:0 inComponent:0 animated:YES];
            break;
    }

    self.frequencyTextField.inputView = self.myPickerView;
}

//Picker View Data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerArray count];
}

//Picker View Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.frequencyTextField setText:[self.pickerArray objectAtIndex:row]];
    
    switch (row) {
        case 0: //nunca
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"0";
            break;
        case 1: //todos los días
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"1";
            break;
        case 2: //todas las semanas
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"7";
            break;
        case 3: //cada 2 semanas
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"14";
            break;
        case 4: //cada 3 semanas
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"21";
            break;
        case 5: //todos los meses
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"30";
            break;
        case 6: //cada dos meses
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"60";
            break;
        case 7: //cada 3 meses
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"90";
            break;
        case 8: //cada 6 meses
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"180";
            break;
        case 9: //todos los años
            self.daysTextField.enabled = FALSE;
            self.daysTextField.text = @"365";
            break;
        case 10: //custom
            self.daysTextField.enabled = TRUE;
            self.daysTextField.text = @"";
            break;
            
        default:
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerArray objectAtIndex:row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
