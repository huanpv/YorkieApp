//
//  SaveYorkieViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 19/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

/* THIS CONTROL IS TO SAVE, EDIT OR DELETE A YORKIE DAT */

#import "MainSaveViewController.h"
#import "sqlite3.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Yorkie.h"
#import "Weight.h"
#import "LoadImageFromBundle.h"
#import "YorkieDelete.h"
#import "RoutineDelete.h"

@interface MainSaveViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoYorkieImageView;
@property (weak, nonatomic) IBOutlet UITextFieldLimit *nameYorkieLabel;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthYorkieLabel;
@property (weak, nonatomic) IBOutlet UITextField *genderYorkieLabel;
@property (weak, nonatomic) IBOutlet UITextField *weightYorkieLabel;
@property (nonatomic, strong) UIPickerView *myPickerView; //property picker (male/female)
@property (nonatomic, strong) NSArray *pickerArray;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property CGPoint originalCenter;
@property CGFloat currentTextFieldOriginY;
@property CGFloat currentTextFieldHeight;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *rectangleView; //this view contain the textedit
@property (weak, nonatomic) IBOutlet UIView *photoEditView;
@property (weak, nonatomic) IBOutlet UILabel *labelEditPhoto;
@property (weak, nonatomic) IBOutlet UIView *viewPhoto;
@property (strong, nonatomic) NSString *nameCheck;

//locale info
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *decimal;
@property (nonatomic, strong) NSString *region;

@property NSInteger cellHeight; //cell size

@end

bool isNameCheck;
bool isCamera;

@implementation MainSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.nameYorkieLabel setLimit:10];
    
    //iPhone language
    self.language = [[NSLocale preferredLanguages] objectAtIndex:0];
    self.decimal = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    self.region = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    if (self.edit) {
        //set the title with nslocalized tu support
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Edit Yorkie", nil)];
        
        //fix to iphone 4 screen size
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat height = CGRectGetHeight(screen);
        
        switch ((int)height) {
            case 480: {
                self.deleteButton.hidden = YES;
                //add trash button to navigation bar
                UIBarButtonItem *myTrash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemTrash
                                                                                         target: self
                                                                                         action: @selector(actionDelete:)];
                
                NSArray* barButtons = [self.navigationItem.rightBarButtonItems arrayByAddingObject: myTrash];
                self.navigationItem.rightBarButtonItems = barButtons;
                }
                break;
            default:
                self.deleteButton.hidden = NO;
                break;
        }
        
        //if the origin is edit yorkie show delete button
        //set the values of edited yorkie in textfields
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [docPaths objectAtIndex:0];
        NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
        
        FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
        [database open];
        
        FMResultSet *results = [database executeQuery:@"SELECT * FROM yorkie, weight where yorkie.idYorkie = ? and yorkie.idYorkie = weight.idYorkie", [NSString stringWithFormat:@"%ld",(long)self.idYorkie]];
        
        while([results next]) {
        self.photoYorkieImageView.image = [LoadImageFromBundle loadImage:[results stringForColumn:@"photo"]];
        self.nameYorkieLabel.text = [results stringForColumn:@"name"];
        //to check not will save 2 dogs with the same name
        self.nameCheck = [results stringForColumn:@"name"];
        self.genderYorkieLabel.text = [results stringForColumn:@"gender"];
        self.dateOfBirthYorkieLabel.text = [results stringForColumn:@"bornDate"];
            
            if ([NSString stringWithFormat:@"%f",[results doubleForColumn:@"weight"]]!=0) {
                self.weightYorkieLabel.text = [results stringForColumn:@"weight"];
            }
            
            if ([self.decimal isEqualToString:@","]){
            //to accept format weight number with spanish regional format 0,0
            //and transform to international format
            self.weightYorkieLabel.text = [self.weightYorkieLabel.text stringByReplacingOccurrencesOfString:@"." withString:@","];
            //weight number in spanish regional format
            }
        
        [self.photoYorkieImageView setAccessibilityIdentifier:[results stringForColumn:@"photo"]];
        }
        [database close];
    } else { //if the origin is add yorkie hide delete button
        self.deleteButton.hidden = YES;
    }
    
    //multilingual delete title button
    [self.deleteButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete", nil)] forState:UIControlStateNormal];
    [self.deleteButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete", nil)] forState:UIControlStateSelected];
    self.deleteButton.layer.cornerRadius = 5;  //delete button corner radius
    
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
    
    //picker with weight
    [self addPickerView];
    
    //datepicker with birthday
    self.datePicker = [[UIDatePicker alloc]init];
    self.datePicker.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:178.0/255.0 blue:185.0/255.0 alpha:1];
    
    if (self.edit) { //if come from edit set date is equal to saved yorkie date
        
        if (self.dateOfBirthYorkieLabel.text.length==0) {
        [self.datePicker setDate:[NSDate date]];
        } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            //multilingual support to show date of birth
            if ([self.region isEqualToString:@"US"]) { //if is "US"
                
                NSString *str = self.dateOfBirthYorkieLabel.text; // here this is your date with format dd-MM-yyy
                [dateFormat setDateFormat:@"dd/MM/yyyy"]; // here set format of date which is in your output date (means above str with format)
                NSDate *date = [dateFormat dateFromString: str]; // here you can fetch date from string with define format
                dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MM/dd/yyyy"]; // here set format which you want...
                NSString *convertedString = [dateFormat stringFromDate:date]; //here convert date in NSString
                self.dateOfBirthYorkieLabel.text = convertedString;
            } else { //if is "es" or others
                [dateFormat setDateFormat:@"dd/MM/yyyy"];
            }
        NSDate *eventDate = [dateFormat dateFromString:self.dateOfBirthYorkieLabel.text];
        [self.datePicker setDate:eventDate];
        }
    } else { //if come from save set date picker is equal to altual date
        //set the title with nslocalized to support
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Add Yorkie", nil)];
        [self.datePicker setDate:[NSDate date]];
    }
    
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.dateOfBirthYorkieLabel setInputView:self.datePicker];

    //set the placeholder of textfield to support multilingual
    NSAttributedString *nameYorkieLabel = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Name", nil)]];
    self.nameYorkieLabel.attributedPlaceholder = nameYorkieLabel;
    self.nameYorkieLabel.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    self.nameYorkieLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSAttributedString *dateOfBirthYorkieLabel = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Date of birth", nil)]];
    self.dateOfBirthYorkieLabel.attributedPlaceholder = dateOfBirthYorkieLabel;
    self.dateOfBirthYorkieLabel.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    self.dateOfBirthYorkieLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSAttributedString *genderYorkieLabel = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Gender", nil)]];
    self.genderYorkieLabel.attributedPlaceholder = genderYorkieLabel;
    self.genderYorkieLabel.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    self.genderYorkieLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSAttributedString *weightYorkieLabel = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Weight", nil)]];
    self.weightYorkieLabel.attributedPlaceholder = weightYorkieLabel;
    self.weightYorkieLabel.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    self.weightYorkieLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.labelEditPhoto.text = [NSString stringWithFormat:NSLocalizedString(@"Edit photo", nil)];
    
    //set delegates keyboard textfields to hide keyboard on enter
    self.nameYorkieLabel.delegate = self;
    self.dateOfBirthYorkieLabel.delegate = self;
    self.genderYorkieLabel.delegate = self;
    self.weightYorkieLabel.delegate = self;
    
    //round the image of the form
    self.photoYorkieImageView.clipsToBounds = YES;
    self.photoYorkieImageView.layer.masksToBounds = YES;
    [self.photoYorkieImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.photoYorkieImageView.layer.cornerRadius = 5;

    //singleTAP in imageView
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap2 setNumberOfTapsRequired:1];
    [self.viewPhoto addGestureRecognizer:singleTap];
    [self.labelEditPhoto addGestureRecognizer:singleTap2];
    
    //put view and edit photo label to top
    [self.view bringSubviewToFront:self.viewPhoto];
    
    //if you dont have camera send an error message
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Error", nil)]
                                                              message:[NSString stringWithFormat:NSLocalizedString(@"Device has no camera", nil)]
                                                             delegate:nil
                                                    cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)]
                                                    otherButtonTitles: nil];
    isCamera = NO;
    [myAlertView show];
    } else {
        isCamera = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    //Create a transparent view with rect up corners and round bottom corners
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.photoEditView.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.photoEditView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.photoEditView.layer.mask = maskLayer;
}

//set custom navigation bar
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self styleNavBar];
}

//custom navigation bar
- (void)styleNavBar {
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
}

#pragma mark - Keyboard Control
//control keyboard appears to move view position

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //get the frame origin y of the active textField
    self.currentTextFieldOriginY = self.rectangleView.frame.origin.y + self.weightYorkieLabel.frame.origin.y;
    self.currentTextFieldHeight = self.weightYorkieLabel.frame.size.height;
    
    if (textField.tag ==2) {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //multilingual support to show date of birth
        if ([self.region isEqualToString:@"US"]) { //if is "US"
            
            NSString *str = self.dateOfBirthYorkieLabel.text; // here this is your date with format dd-MM-yyy
            [dateFormat setDateFormat:@"dd/MM/yyyy"]; // here set format of date which is in your output date (means above str with format)
            NSDate *date = [dateFormat dateFromString: str]; // here you can fetch date from string with define format
            dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];// here set format which you want...
            NSString *convertedString = [dateFormat stringFromDate:date]; //here convert date in NSString
            self.dateOfBirthYorkieLabel.text = convertedString;
        } else { //if is "es" or others
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
        }
        textField.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate: self.datePicker.date]];
    }
    
    if (textField.tag ==4) {
    
        NSInteger indexSelected = [self.myPickerView selectedRowInComponent:0];
        [self.myPickerView selectRow:indexSelected inComponent:0 animated:YES];
        NSString *ww = [[self.myPickerView delegate] pickerView:self.myPickerView titleForRow:indexSelected forComponent:0];

        self.genderYorkieLabel.text = ww;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    /* resign first responder, hide keyboard, move views */
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat deltaHeight = kbSize.height;
    
    //only if the position of keyboard is biggest than textfield
    if ((self.currentTextFieldOriginY+self.currentTextFieldHeight+25) > (self.view.frame.size.height-deltaHeight)) {
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y + ((self.view.frame.size.height-deltaHeight)-(self.currentTextFieldOriginY+self.currentTextFieldHeight+14)) );
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.view.center = self.originalCenter;
}

#pragma mark - datepicker bornDate textfield

- (void)updateTextField:(UIDatePicker *)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.dateOfBirthYorkieLabel.inputView;
    [picker setMaximumDate:[NSDate date]];
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
    self.dateOfBirthYorkieLabel.text = [NSString stringWithFormat:@"%@",dateString];
}

#pragma mark - picker view gender textfield

- (void)addPickerView{
    self.pickerArray = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:NSLocalizedString(@"Male", nil)],[NSString stringWithFormat:NSLocalizedString(@"Female", nil)], nil];
    self.myPickerView = [[UIPickerView alloc]init];
    self.myPickerView.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:178.0/255.0 blue:185.0/255.0 alpha:1];
    self.myPickerView.dataSource = self;
    self.myPickerView.delegate = self;
    self.myPickerView.showsSelectionIndicator = YES;
    
    if (([self.genderYorkieLabel.text isEqualToString:@"Female"]) || ([self.genderYorkieLabel.text isEqualToString:@"Hembra"])) {
        [self.myPickerView selectRow:1 inComponent:0 animated:YES];
    } else {
        [self.myPickerView selectRow:0 inComponent:0 animated:YES];
    }

    self.genderYorkieLabel.inputView = self.myPickerView;
}

//Picker View Data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerArray count];
}

//Picker View Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self.genderYorkieLabel setText:[self.pickerArray objectAtIndex:row]];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerArray objectAtIndex:row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//button cancel on navigation bar
- (IBAction)actionCancelAddYorkie:(id)sender {
    [self textFieldsResignFirstResponder];
    //if press save or cancel when keyboard shows, to dismiss keyboard velocity syncronized with dismissview
    [self dismissViewControllerAnimated:YES completion:nil];
}

//if press save or cancel when keyboard shows, to dismiss keyboard velocity syncronized with dismissview
- (void)textFieldsResignFirstResponder{
    [self.nameYorkieLabel resignFirstResponder];
    [self.dateOfBirthYorkieLabel resignFirstResponder];
    [self.genderYorkieLabel resignFirstResponder];
    [self.weightYorkieLabel resignFirstResponder];
}

//EDIT and SAVE action. Values defined in origin MainViewController
- (IBAction)actionSaveAddYorkie:(id)sender {
    
    isNameCheck = FALSE;
    
    //open database
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];

    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
  
    if (self.nameYorkieLabel.text.length==0){ //filter to check name Yorkie not empty
        //filter to check if name is empty
        NSAttributedString *nameYorkieLabel = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Name", nil)] attributes:@{ NSForegroundColorAttributeName : [UIColor redColor] }];
        self.nameYorkieLabel.attributedPlaceholder = nameYorkieLabel;
        self.nameYorkieLabel.clearButtonMode = UITextFieldViewModeWhileEditing;

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Alert", nil)]
                                                              message:[NSString stringWithFormat:NSLocalizedString(@"Fill name field before save", nil)]
                                                             delegate:nil
                                                    cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)]
                                                    otherButtonTitles: nil];
        [database close];
        [myAlertView show];
        isNameCheck = TRUE;
    }
    
    //filter to check name Yorkie not duplicate
    //Check name before save
    
    //self.namecheck has the value of original name
    //if user edit yorkie and save with a name that exist. "if" will be true
    if (![self.nameYorkieLabel.text isEqualToString:self.nameCheck]) {
        
        //get the idYorkie from the last save to use in save weight table
        NSUInteger count = [database intForQuery:@"SELECT COUNT(name) from yorkie where upper(name)= ? ", [self.nameYorkieLabel.text uppercaseString], nil];
        
        if (count > 0) {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Alert", nil)]
                                                                  message:[NSString stringWithFormat:NSLocalizedString(@"Name exists", nil)]
                                                                 delegate:nil
                                                        cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)]
                                                        otherButtonTitles: nil];
            [database close];
            [myAlertView show];
            isNameCheck = TRUE;
        }
    }

    if (!isNameCheck) {
        //if press save or cancel when keyboard shows, to dismiss keyboard velocity syncronized with dismissview
        [self textFieldsResignFirstResponder];
        //actual date for weight
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];

         //if we need to save yorkie
        if (self.save) {
            NSString *currentImageName = [NSString stringWithFormat:@"%@.png",self.nameYorkieLabel.text];
            self.photoYorkieImageView.accessibilityIdentifier = currentImageName;

            [self saveImage:self.photoYorkieImageView.image];
            NSString *name = self.nameYorkieLabel.text;
            NSString *gender = self.genderYorkieLabel.text;
            NSString *bornDate = self.dateOfBirthYorkieLabel.text;
        
            //to save format date with multilingual support
            // "es" - "en" and others
            //allways save in "es" format dd/MM/yyyy
            if ([self.region isEqualToString:@"US"]) {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                NSString *str = self.dateOfBirthYorkieLabel.text; /// here this is your date with format dd-MM-yyy
            
                [dateFormat setDateFormat:@"MM/dd/yyyy"]; //// here set format of date which is in your output date (means above str with format)
            
                NSDate *date = [dateFormat dateFromString: str]; // here you can fetch date from string with define format
            
                dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd/MM/yyyy"];// here set format which you want...
            
                NSString *convertedString = [dateFormat stringFromDate:date]; //here convert date in NSString
                self.dateOfBirthYorkieLabel.text = convertedString;
                bornDate = self.dateOfBirthYorkieLabel.text;
                }
    
            //save in Yorkie Table
            BOOL successYorkie = [database executeUpdate:@"INSERT INTO yorkie (photo, name, gender, bornDate) VALUES (?, ?, ?, ?)", [NSString stringWithFormat:@"%@", currentImageName], [NSString stringWithFormat:@"%@", name], [NSString stringWithFormat:@"%@", gender], [NSString stringWithFormat:@"%@", bornDate], nil];
        
            //get the idYorkie from the last save to use in save weight table
            FMResultSet *results = [database executeQuery:@"SELECT idYorkie from yorkie where name= ? and gender= ? and bornDate= ?", [NSString stringWithFormat:@"%@", name], [NSString stringWithFormat:@"%@", gender], [NSString stringWithFormat:@"%@", bornDate], nil];
        
            while([results next]) {
                self.idYorkie = [results intForColumn:@"idYorkie"];
            }

            if (!successYorkie) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }

            //to accept format weight number with spanish regional format 0,0
            //and transform to international format
            float number = [[self.weightYorkieLabel.text stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
            //weight number in spanish regional format
            self.weightYorkieLabel.text = [NSString stringWithFormat:@"%.1f",number];

            //save in Weight table
            BOOL successWeight = [database executeUpdate:@"INSERT INTO weight (idYorkie, weight, date) VALUES (?, ?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"%@", self.weightYorkieLabel.text], [DateFormatter stringFromDate:[NSDate date]], nil];

            if (!successWeight) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }

            //SAVE ROUTINES
            //routine 1 = Hair Salon
            BOOL successRoutine1 = [database executeUpdate:@"INSERT INTO routine (idYorkie, idRoutineType) VALUES (?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"1"]];

            if (!successRoutine1) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            //SAVE ROUTINES
            //routine 2 = Bath
            BOOL successRoutine2 = [database executeUpdate:@"INSERT INTO routine (idYorkie, idRoutineType) VALUES (?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"2"]];

            if (!successRoutine2) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            
            //SAVE ROUTINES
            //routine 3 = Antiparasitic
            BOOL successRoutine3 = [database executeUpdate:@"INSERT INTO routine (idYorkie, idRoutineType) VALUES (?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"3"]];

            if (!successRoutine3) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            
            //SAVE ROUTINES
            //routine 4 = Dental Care
            BOOL successRoutine4 = [database executeUpdate:@"INSERT INTO routine (idYorkie, idRoutineType) VALUES (?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"4"]];

            if (!successRoutine4) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            
            //SAVE ROUTINES
            //routine 5 = Vaccines
            BOOL successRoutine5 = [database executeUpdate:@"INSERT INTO routine (idYorkie, idRoutineType) VALUES (?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"5"]];

            if (!successRoutine5) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            
            //SAVE ROUTINES
            //routine 6 = Vaccines
            BOOL successRoutine6 = [database executeUpdate:@"INSERT INTO routine (idYorkie, idRoutineType) VALUES (?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"6"]];

            if (!successRoutine6) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
            
            //SAVE ROUTINES
            //routine 7 = Vaccines
            BOOL successRoutine7 = [database executeUpdate:@"INSERT INTO routine (idYorkie, idRoutineType) VALUES (?, ?)", [NSString stringWithFormat:@"%ld", (long)self.idYorkie ], [NSString stringWithFormat:@"7"]];

            if (!successRoutine7) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }
        } else {  //if we need to edit Yorkie
            NSString *currentImageName = [NSString stringWithFormat:@"%@.png",self.nameYorkieLabel.text]; //name of actual selected yorkie
            self.photoYorkieImageView.accessibilityIdentifier = currentImageName;
            [self saveImage:self.photoYorkieImageView.image];
            NSString *name = self.nameYorkieLabel.text;
            NSString *gender = self.genderYorkieLabel.text;
            NSString *bornDate = self.dateOfBirthYorkieLabel.text;

            //to edit format date with multilingual support
            // "es" - "en" and others
            //allways save in "es" format dd/MM/yyyy
            //
        
            if ([self.region isEqualToString:@"US"]) {
                if (!self.dateOfBirthYorkieLabel.text.length==0) {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    NSString *str = self.dateOfBirthYorkieLabel.text; /// here this is your date with format dd-MM-yyy
            
                    [dateFormat setDateFormat:@"MM/dd/yyyy"]; //// here set format of date which is in your output date (means above str with format)
            
                    NSDate *date = [dateFormat dateFromString: str]; // here you can fetch date from string with define format
            
                    dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd/MM/yyyy"];// here set format which you want...
            
                    NSString *convertedString = [dateFormat stringFromDate:date]; //here convert date in NSString
                    bornDate = convertedString;
                }
            }
        
            //edit Yorkie Row
            BOOL successYorkie = [database executeUpdate:@"UPDATE yorkie SET photo = ?, name = ?, gender = ?, bornDate = ? WHERE idYorkie = ?", [NSString stringWithFormat:@"%@", currentImageName], [NSString stringWithFormat:@"%@", name], [NSString stringWithFormat:@"%@", gender], [NSString stringWithFormat:@"%@", bornDate ], [NSString stringWithFormat:@"%ld", (long)self.idYorkie], nil];

            if (!successYorkie) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
             }

            //to accept format weight number with spanish regional format 0,0
            //and transform to international format
            float number = [[self.weightYorkieLabel.text stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
            //weight number in spanish regional format
            self.weightYorkieLabel.text = [NSString stringWithFormat:@"%.1f",number];

            //edit Weight row
            BOOL successWeight = [database executeUpdate:@"UPDATE weight SET weight = ?, date = ? WHERE idYorkie = ?", [NSString stringWithFormat:@"%@", self.weightYorkieLabel.text], [DateFormatter stringFromDate:[NSDate date]], [NSString stringWithFormat:@"%ld", (long)self.idYorkie], nil];

            if (!successWeight) {
                NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
                // do whatever you need to upon error
            }

            //hey delegate the user edit yorkie data then reload collectionCell
            [[self delegate] reloadDetail];
        }
    
        [database close];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma -delete yorkie Methods

//action delete Yorkie
- (IBAction)actionDelete:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Confirm deleted", nil)]
                          message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete this Yorkie?", nil)]
                          delegate:self
                          cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Cancel", nil)]
                          otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Delete", nil)],nil];
    [alert show];
}

//alertview to confirm delete Yorkie action
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
            //delete yorkie
            [YorkieDelete yorkieDelete:self.idYorkie];
            //delete all the routines of yorkie
            //routine 1 = Hair Salon
            //routine 2 = Bath
            //routine 3 = Antiparasitic
            //routine 4 = Dental Care
            //routine 5 = Vaccines
            //routine 6 = Pills
            //routine 7 = Medicine
            for (int i=1; i<8; i++) {
                [RoutineDelete routineDelete:self.idYorkie withRoutineNumber:i];
            }

            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma -mark hide keyboard Methods

//hide keyboard on return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

//hide keyboard on touch outside textField
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center = self.originalCenter;
    }];

    [self.view endEditing:YES];
}

#pragma -mark yorkieImageView Methods

//***YORKIEIMAGEVIEW CONTROL *******
//SingleTap in imageView
- (void)singleTapping:(UIGestureRecognizer *)recognizer
{
    if (isCamera) { //if the iphone have a camera
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Select the operation to proceed", nil)]
                                                             delegate:self
                                                    cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Cancel", nil)]
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Select Photo", nil)], [NSString stringWithFormat:NSLocalizedString(@"Take Photo", nil)], nil];
    [actionSheet showInView:self.view];
    }
    else { //if the iphone dont have a camera or is broken
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Select the operation to proceed", nil)]
                                                             delegate:self
                                                    cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Cancel", nil)]
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Select Photo", nil)], nil];
    [actionSheet showInView:self.view];
    }
  
}

//actionSheet to select imageAction
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    //action cancel
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        // Handle cancel action
    } else { //if not cancel select photo origin
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        if(buttonIndex == 0) { //button Select Photo
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else if(buttonIndex == 1) { //button Take Photo
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

//get the image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.photoYorkieImageView.image = chosenImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//cancel picker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//save image name.png in documents directory
- (void)saveImage: (UIImage*)image
{
    if (image != nil)
    {
        NSString *currentImageName = self.photoYorkieImageView.accessibilityIdentifier;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithString: currentImageName] ];
        NSData* data = UIImagePNGRepresentation(image);
        
        [data writeToFile:path atomically:YES];
    }
}

@end
