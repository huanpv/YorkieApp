//
//  YorkieDetailViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 26/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "MainDetailViewController.h"
#import "MainSaveViewController.h"
#import "LoadImageFromBundle.h"
#import "MainCollectionCell.h"
#import "Yorkie.h"
#import "Weight.h"
#import "sqlite3.h" //database
#import "FMDatabase.h" // from cocoa pods and github

@interface MainDetailViewController ()

@property (nonatomic, strong) NSString *decimal;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSMutableArray * yorkieArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MainDetailViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)databaseDidOpen 
{
    self.decimal = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    
    FMResultSet *results = [database executeQuery:@"SELECT * FROM yorkie, weight where yorkie.idYorkie = ? and yorkie.idYorkie = weight.idYorkie", [NSString stringWithFormat:@"%ld",(long)self.idYorkie]];
    
    self.yorkieArray = [[NSMutableArray alloc] init];
    
    while([results next]) {
        Yorkie *yorkie	= [[Yorkie alloc] init];
        yorkie.yorkieID = [results intForColumn:@"idYorkie"];
        yorkie.photo = [results stringForColumn:@"photo"];
        yorkie.name = [results stringForColumn:@"name"];
        yorkie.gender = [results stringForColumn:@"gender"];
        //set data
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSDate *date = [dateFormat dateFromString: [results stringForColumn:@"bornDate"]];
        
        if (![[results stringForColumn:@"bornDate"] isEqualToString:@""]) {
            yorkie.bornDate = [self age:date];
        }
        
        Weight * weight = [[Weight alloc] init];
        
        if ([NSString stringWithFormat:@"%f",[results doubleForColumn:@"weight"]]!=0) {
            weight.weight = [NSNumber numberWithDouble:[results doubleForColumn:@"weight"]];
        }
        
        yorkie.weight = weight;
        weight.date = [results stringForColumn:@"date"];
        [self.yorkieArray addObject:yorkie];    
    }
    
    [database close];
}

//protocol-delegate if user edit yorkie data reload collectionCell
- (void)reloadDetail 
{
    [self.collectionView reloadData];
}

//set custom navigation bar
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    self.region = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    [self styleNavBar];
    [self databaseDidOpen];
}

//custom navigation bar
- (void)styleNavBar 
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    
    //add buttons to navigation bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionEditButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionDoneButton:)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (IBAction)actionEditButton:(id)sender 
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainSaveViewController *sVC = [storyboard instantiateViewControllerWithIdentifier:@"addyorkie"];
    
    sVC.edit = YES;
    sVC.save = NO;
    sVC.idYorkie = self.idYorkie;
    sVC.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)actionDoneButton:(id)sender 
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//CALCULATE AGE FROM BITHDAY
- (NSString *)age:(NSDate *)dateOfBirth 
{
    NSInteger years;
    NSInteger months;
    NSInteger days = 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) || (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        years = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        years = [dateComponentsNow year] - [dateComponentsBirth year];
    }
    
    if ([dateComponentsNow year] == [dateComponentsBirth year]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] > [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] < [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month] + 12;
    } else {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    }
    
    if ([dateComponentsNow year] == [dateComponentsBirth year] && [dateComponentsNow month] == [dateComponentsBirth month]) {
        days = [dateComponentsNow day] - [dateComponentsBirth day];
    }
    
//    "years" = "years";
//    "year" = "year";
//    "month" = "month";
//    "months" = "months";
//    NSLocalizedString(@"Edit", nil)
    if (years == 0 && months == 0) {
        if (days == 1) {
            return [NSString stringWithFormat:@"%ld %@", (long)days, NSLocalizedString(@"day", nil)];
        } else {
            return [NSString stringWithFormat:@"%ld %@", (long)days, NSLocalizedString(@"days", nil)];
        }
    } else if (years == 0) {
        if (months == 1) {
            return [NSString stringWithFormat:@"%ld %@", (long)months, NSLocalizedString(@"month", nil)];
        } else {
            return [NSString stringWithFormat:@"%ld %@", (long)months, NSLocalizedString(@"months", nil)];
        }
    } else if ((years != 0) && (months == 0)) {
        if (years == 1) {
            return [NSString stringWithFormat:@"%ld %@", (long)years, NSLocalizedString(@"year", nil)];
        } else {
            return [NSString stringWithFormat:@"%ld %@", (long)years, NSLocalizedString(@"years", nil)];
        }
    } else {
        if ((years == 1) && (months == 1)) {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"year", nil), (long)months, NSLocalizedString(@"month", nil)];
        } else if (years == 1) {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"year", nil), (long)months, NSLocalizedString(@"months", nil)];
        } else if (months == 1) {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"years", nil), (long)months, NSLocalizedString(@"month", nil)];
        } else {
            return [NSString stringWithFormat:@"%ld %@ %ld %@", (long)years, NSLocalizedString(@"years", nil), (long)months, NSLocalizedString(@"months", nil)];
        }
    }
}

//********COLLECTION VIEW***********//
#pragma mark - UICollectionView Methods

//elements of Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section 
{
    return 1;
}

//table highlight when tap photo disallow
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}

//table highlight when tap photo disallow
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath 
{
    // NOTE: This is called, as long as both shouldSelectItemAtIndexPath: AND shouldHighlightItemAtIndexPath: return YES. If either returns NO, the cell is not actually selected.
    NSLog(@"Did select collection view cell: %@", indexPath);
}

//get the cell of Collection View
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath 
{
    MainCollectionCell * yorkieCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    yorkieCollectionCell.imageYorkie.clipsToBounds = YES;
    yorkieCollectionCell.imageYorkie.layer.cornerRadius = 5.0;
    yorkieCollectionCell.imageYorkie.layer.masksToBounds = YES;
    [yorkieCollectionCell.imageYorkie setContentMode:UIViewContentModeScaleAspectFill];
    yorkieCollectionCell.detailValuesView.layer.cornerRadius = 5.0;
    
    //Create a transparent view with rect up corners and round bottom corners
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:yorkieCollectionCell.viewYorkie.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = yorkieCollectionCell.viewYorkie.bounds;
    maskLayer.path = maskPath.CGPath;
    yorkieCollectionCell.viewYorkie.layer.mask = maskLayer;

    Yorkie *yorkie = self.yorkieArray[indexPath.row];
    
    yorkieCollectionCell.imageYorkie.image = [LoadImageFromBundle loadImage:yorkie.photo];
    yorkieCollectionCell.labelYorkie.text = yorkie.name;
    yorkieCollectionCell.ageYorkieLabel.text = yorkie.bornDate;
    
    if ([self.decimal isEqualToString:@","]){
        //to accept format weight number with spanish regional format 0,0
        //and transform to international format
        NSString *weightString = [NSString stringWithFormat:@"%@", yorkie.weight.weight];
        weightString = [weightString stringByReplacingOccurrencesOfString:@"." withString:@","];
        //weight number in spanish regional format
        //multilingual support to show lb or kg
        if ([self.region isEqualToString:@"US"]) { //if is "US"
        yorkieCollectionCell.weightYorkieLabel.text = [NSString stringWithFormat:@"%@ lb", weightString];
        } else {
            yorkieCollectionCell.weightYorkieLabel.text = [NSString stringWithFormat:@"%@ kg", weightString];
        }
    } else {
        if ([self.region isEqualToString:@"US"]) { //if is "US"
        yorkieCollectionCell.weightYorkieLabel.text = [NSString stringWithFormat:@"%@ lb", yorkie.weight.weight];
        }
        else {
           yorkieCollectionCell.weightYorkieLabel.text = [NSString stringWithFormat:@"%@ kg", yorkie.weight.weight];
        }
    }
    
    yorkieCollectionCell.genderYorkieLabel.text = yorkie.gender;
    yorkieCollectionCell.cellIdentifier = self.cellIdentifier;
    
    //TAP on photo
    UITapGestureRecognizer *tapPhoto=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    //TAP on name
    UITapGestureRecognizer *tapLabel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    //TAP on view
    UITapGestureRecognizer *tapView=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    //TAP on textfield borndate
    UITapGestureRecognizer *tapBorndate=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    //TAP on textfield weight
    UITapGestureRecognizer *tapWeight=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    //TAP on textfield gender
    UITapGestureRecognizer *tapGender=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];

    [yorkieCollectionCell.imageYorkie addGestureRecognizer:tapPhoto];
    [yorkieCollectionCell.labelYorkie addGestureRecognizer:tapLabel];
    [yorkieCollectionCell.detailValuesView addGestureRecognizer:tapView];
    [yorkieCollectionCell.ageYorkieLabel addGestureRecognizer:tapBorndate];
    [yorkieCollectionCell.weightYorkieLabel addGestureRecognizer:tapWeight];
    [yorkieCollectionCell.genderYorkieLabel addGestureRecognizer:tapGender];
    
    //if borndate, weight and gender are empty then
    if (([yorkie.weight.weight isEqual:@0]) && (yorkie.bornDate==NULL) && ([yorkieCollectionCell.genderYorkieLabel.text isEqualToString:@""]) ) {
        
        yorkieCollectionCell.ageYorkieLabel.text = NSLocalizedString(@"Tap 'edit' to fill", nil);
        yorkieCollectionCell.weightYorkieLabel.text = NSLocalizedString(@"date of birth, weight", nil);
        yorkieCollectionCell.genderYorkieLabel.text = NSLocalizedString(@"and gender", nil);
    } else {
        if ([yorkie.weight.weight isEqual:@0]){
            yorkieCollectionCell.weightYorkieLabel.text = NSLocalizedString(@"add weight", nil);
        }
        
        if (yorkie.bornDate==NULL) {
            yorkieCollectionCell.ageYorkieLabel.text = NSLocalizedString(@"add date of birth", nil);
        }
        
        if ([yorkieCollectionCell.genderYorkieLabel.text isEqualToString:@""]) {
            yorkieCollectionCell.genderYorkieLabel.text = NSLocalizedString(@"add gender", nil);
        }
    }
    
    return yorkieCollectionCell;
}

//tap photo yorkie or label name
- (void)cellTap:(UISwipeGestureRecognizer *)gesture 
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainSaveViewController *sVC = [storyboard instantiateViewControllerWithIdentifier:@"addyorkie"];
    
    sVC.edit = YES;
    sVC.save = NO;
    sVC.idYorkie = self.idYorkie;
    sVC.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sVC];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - CollectionView layout

// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath 
{
    CGSize mElementSize = CGSizeMake(0, 0);
    
    switch (self.iphoneModel) {
        case 4:
            mElementSize = CGSizeMake(290, 388);
            break;
        case 5:
            mElementSize = CGSizeMake(290, 475);
            break;
        case 6:
            mElementSize = CGSizeMake(342, 583);
            break;
        case 7:
            mElementSize = CGSizeMake(389, 656);
            break;
        default:
            mElementSize = CGSizeMake(389, 656);
            break;
    }
    
    return mElementSize;
}

//vertical separation between cells
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section 
{
    switch (self.iphoneModel) {
        case 4: //iPhone 4
            return 0.0;
            break;
        case 5: //iPhone 5
            return 0.0;
            break;
        case 6: //iPhone 6
            return 0.0;
            break;
        case 7: //iPhone 6 Plus
            return 0.0;
            break;
        default: //default
            return 0.0;
            break;
    }
}

//horizontal separation between cells
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section 
{
    switch (self.iphoneModel) {
        case 4: //iPhone 4
            return 38.0;
            break;
        case 5: //iPhone 5
            return 38.0;
            break;
        case 6: //iPhone 6
            return 41.0;
            break;
        case 7: //iPhone 6 Plus
            return 25.0;
            break;
        default: //default
            return 0.0;
            break;
    }
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section 
{
    switch (self.iphoneModel) {
        case 4: //iPhone 4
            return UIEdgeInsetsMake(8,18,0,0);
            break;
        case 5: //iPhone 5
            return UIEdgeInsetsMake(8,18,0,0);
            break;
        case 6: //iPhone 6
            return UIEdgeInsetsMake(8,20,0,0);
            break;
        case 7: //iPhone 6 plus
            return UIEdgeInsetsMake(0,12,0,0);
            break;
        default: //default
            return UIEdgeInsetsMake(0,0,0,0);// top, left, bottom, right
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section 
{
    switch (self.iphoneModel) {
        case 4: //iPhone 4
            return CGSizeMake(19, 0);
            break;
        case 5: //iPhone 5
            return CGSizeMake(19, 0);
            break;
        case 6: //iPhone 6
            return CGSizeMake(19, 0);
            break;
        case 7: //iPhone 6 plus
            return CGSizeMake(12, 0);
            break;
        default: //default
            return CGSizeMake(0, 0);
            break;
    }
}

@end
