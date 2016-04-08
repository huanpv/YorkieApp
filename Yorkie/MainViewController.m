//
//  ViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 09/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "MainViewController.h"
#import "Yorkie.h"
#import "Weight.h"
#import "Routine.h"
#import "MainSaveViewController.h"
#import "MainDetailViewController.h"
#import "sqlite3.h" //database
#import "FMDatabase.h" // from cocoa pods and github
#import "LoadImageFromBundle.h"
#import "ZFModalTransitionAnimator.h"
#import "DateofNextEvent.h"

@interface MainViewController ()

@property (nonatomic, strong) NSMutableArray * yorkieArray; //insert all the yorkies
@property (nonatomic, strong) NSMutableArray * yorkieRoutineArray; //insert all the routines of each yorkie
@property NSInteger iphoneModel; //to save the iPhone model and present the screen size in a perfect way
@property (nonatomic, strong) NSString *cellIdentifier; //personal size of cell from Main collectionView
@property (strong, nonatomic) IBOutlet UIPageControl *pageControlYorkie;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;

//to send data to detail or routine
@property NSInteger yorkieID;
@property NSInteger routineID; //only for routine
@property (nonatomic, strong) NSString * yorkieName;

//when you dont have any Yorkie, show a image with a litle help
@property (weak, nonatomic) IBOutlet UIView *viewHelp;
@property (weak, nonatomic) IBOutlet UIImageView *imageHelp;

@end

BOOL firstTime=YES; //if is the first init set the number of pages before compare
                    //order the collectionview where insert a new yorkie

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated {
    [self styleNavBar];
    [self databaseDidOpen];
    [self reloadCollectionViewData];
}

- (void)reloadCollectionViewData {
    [self.collectionView reloadData];
}

//custom navigation bar
- (void)styleNavBar {
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //if is the first use delete all the old local notifications
    static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:hasRunAppOnceKey] == NO) {
        // Some code you want to run on first use...
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [defaults setBool:YES forKey:hasRunAppOnceKey];
    }
    
    for(UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSLog(@"FIREDATE: %@ ALERTBODY: %@ TIMEZONE: %@ USERINFO: %@ BADGE: %ld", notify.fireDate, notify.alertBody,  notify.timeZone, notify.userInfo, (long)notify.applicationIconBadgeNumber);
    }
    
    //to reload table when we welcome back from background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionViewData) name:@"ReloadAppDelegateTable" object:nil];
    
    //get screen size
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat height = CGRectGetHeight(screen);

    //set model (get the iPhone model screen size and set the custom cell for that size)
    switch ((int)height) {
        case 480:
            self.iphoneModel = 4;
            self.cellIdentifier = @"Cell4";
            break;
        case 568:
            self.iphoneModel = 5;
            self.cellIdentifier = @"Cell5";
            break;
        case 667:
            self.iphoneModel = 6;
            self.cellIdentifier = @"Cell6";
            break;
        case 736:
            self.iphoneModel = 7;
            self.cellIdentifier = @"Cell6p";
            break;
        default:
            self.iphoneModel = 7;
            self.cellIdentifier = @"Cell6p";
            break;
    }

    //image for help user to add a new yorkie
    [self.imageHelp setImage:[UIImage imageNamed:NSLocalizedString(@"introImage", nil)]];
}

- (void)databaseDidOpen {
    //copy database to DocumentDirectory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = paths.firstObject;
    NSString * sourcePath = [[NSBundle mainBundle] pathForResource:@"Yorkie" ofType:@"sqlite"];
    NSString * destinationPath = [documentsDirectory stringByAppendingPathComponent:@"yorkie.sqlite"];
    
    if ([fileManager fileExistsAtPath:destinationPath]==NO) {
        //NO FILE IN DOCUMENTS -> copy it to the bundle
        [fileManager copyItemAtPath:sourcePath
                             toPath:destinationPath
                              error:nil];
    }
    
    //upload data from documents Directory
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"yorkie.sqlite"];

    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *results = [database executeQuery:@"SELECT * FROM yorkie, weight where yorkie.idYorkie = weight.idYorkie"];

    self.yorkieArray = [[NSMutableArray alloc] init];
    
    while([results next]) {
        Yorkie *yorkie	= [[Yorkie alloc] init];
        yorkie.yorkieID = [results intForColumn:@"idYorkie"];
        yorkie.photo = [results stringForColumn:@"photo"];
        yorkie.name = [results stringForColumn:@"name"];
        yorkie.gender = [results stringForColumn:@"gender"];
        yorkie.bornDate = [results stringForColumn:@"bornDate"];
        Weight * weight = [[Weight alloc] init];
        weight.weight = [NSNumber numberWithDouble:[results doubleForColumn:@"weight"]];
        weight.date = [results stringForColumn:@"date"];
        yorkie.weight = weight;

        [self.yorkieArray addObject:yorkie];

        //upload pageControlYorkie position
        CGFloat pageWidth = self.collectionView.frame.size.width;
        float currentPage = self.collectionView.contentOffset.x / pageWidth;
        
        if (0.0f != fmodf(currentPage, 1.0f)) {
            self.pageControlYorkie.currentPage = currentPage + 1;
        } else {
            self.pageControlYorkie.currentPage = currentPage;
        }
    }
    
    [database close];

    //if yorkie is equal to zero set an image to help user and hide collectionView
    if (self.yorkieArray.count==0) {
        self.collectionView.hidden = YES;
        self.viewHelp.hidden = NO;
        self.imageHelp.hidden = NO;
    } else {
        self.collectionView.hidden = NO;
        self.viewHelp.hidden = YES;
        self.imageHelp.hidden = YES;
    }

    if (firstTime) { //if is the first init set the number of pages before compare
        self.pageControlYorkie.numberOfPages = self.yorkieArray.count;
        firstTime = NO;
    }
    
    if (self.pageControlYorkie.numberOfPages<self.yorkieArray.count) {
        self.pageControlYorkie.numberOfPages = self.yorkieArray.count;
        [self.collectionView reloadData];
        NSIndexPath *saveIndexPath = [NSIndexPath indexPathForItem:self.pageControlYorkie.numberOfPages-1 inSection:0];

        //Update the position of Yorkie in PageControl
        self.pageControlYorkie.currentPage = saveIndexPath.row;
        [self.collectionView scrollToItemAtIndexPath:saveIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    
    //update title depends of the number of Yorkies == 1 or >1
    self.pageControlYorkie.numberOfPages = self.yorkieArray.count;
    
    if (self.pageControlYorkie.numberOfPages<2) {
        self.navigationItem.title = @"Yorkie";
    } else {
        self.navigationItem.title = @"Yorkies";
    }
}

#pragma mark - UICollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.yorkieArray.count;
}

//table highlight when tap photo disallow
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//table highlight when tap photo disallow
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // NOTE: This is called, as long as both shouldSelectItemAtIndexPath: AND shouldHighlightItemAtIndexPath: return YES. If either returns NO, the cell is not actually selected.
    //NSLog(@"Did select collection view cell: %@", indexPath);
}

//get the cell of Collection View
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainCollectionCell * yorkieCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    yorkieCollectionCell.imageYorkie.clipsToBounds = YES;
    yorkieCollectionCell.imageYorkie.layer.cornerRadius = 5;
    yorkieCollectionCell.imageYorkie.layer.masksToBounds = YES;
    [yorkieCollectionCell.imageYorkie setContentMode:UIViewContentModeScaleAspectFill];
    
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
    self.yorkieName = yorkie.name; //to save in global variable and send in segue like title to routine
    yorkieCollectionCell.cellIdentifier = self.cellIdentifier;
    yorkieCollectionCell.yorkieIdentifier = yorkie.yorkieID;
    
    self.yorkieID = yorkie.yorkieID;

    yorkieCollectionCell.cellData = [self databaseRoutineDidOpen:self.yorkieID]; //send routine data to main tableview
 
    [yorkieCollectionCell.tableView reloadData]; //Reload data to avoid error that repeat values of cells
    
    //scroll allways to top before start
    NSIndexPath *tableIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [yorkieCollectionCell.tableView scrollToRowAtIndexPath:tableIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];

    yorkieCollectionCell.delegate = self;

    //TAP on photo
    UITapGestureRecognizer *tapPhoto=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    UITapGestureRecognizer *tapLabel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    [yorkieCollectionCell.imageYorkie addGestureRecognizer:tapPhoto];
    [yorkieCollectionCell.labelYorkie addGestureRecognizer:tapLabel];

    return yorkieCollectionCell;
}

//get the routine data to show in mainviewcontroller tableview
- (NSArray *)databaseRoutineDidOpen:(NSInteger)idYorkie  {
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *results = [database executeQuery:@"SELECT routine.idYorkie, routine.idRoutine, routine.comment, routine.startDate, routine.frequency, routine.lastDate , routineType.idRoutineType,  routineType.description, routineType.image FROM routine, routineType where ? = routine.idYorkie and routineType.idRoutineType = routine.idRoutineType order by routine.startDate", [NSString stringWithFormat:@"%ld",(long)idYorkie]];

    self.yorkieRoutineArray = [[NSMutableArray alloc] init];

    while([results next]) {
        Routine *routine= [[Routine alloc] init];
        routine.yorkieID = [results intForColumn:@"idYorkie"];
        routine.routineID = [results intForColumn:@"idRoutine"];
        routine.routineTypeID = [results intForColumn:@"idRoutineType"];
        routine.name = [results stringForColumn:@"comment"];
        routine.startDate = [results stringForColumn:@"startDate"];
        routine.frecuency = [results intForColumn:@"frequency"];
        routine.imageDesc = [results stringForColumn:@"description"];
        routine.imageName = [results stringForColumn:@"image"];
        routine.lastDate = [results stringForColumn:@"lastDate"];
        
        // Convert to new Date Format
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        NSDate *lastDate = [dateFormatter dateFromString:routine.lastDate];
        
        // Convert to new Date Format
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString *newDate = [dateFormatter stringFromDate:lastDate];
        // Convert to new Date Format
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        lastDate = [dateFormatter dateFromString:newDate];

        //cast routine.startDate string into NSDate
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSDate *date = [dateFormat dateFromString: routine.startDate];

        //ADVICE WITH RED TEXTFIELD
        //set the days to notice routine before happens
        switch (routine.routineTypeID) {
            case 1://Hair Salon
                routine.routineNotice = 3; //notice 3 days before
                break;
            case 2://Bath
                routine.routineNotice = 3; //notice 3 days before
                break;
            case 3://Antiparasitic
                routine.routineNotice = 3; //notice 3 days before
                break;
            case 4://Dental care
                routine.routineNotice = 5; //notice 5 days before
                break;
            case 5://Vaccine
                routine.routineNotice = 5; //notice 5 days before
                break;
            case 6://Pills
                routine.routineNotice = 1; //notice 1 day before
                break;
            case 7://Medicine
                routine.routineNotice = 1; //notice 1 day before
                break;
            default:
                break;
        }

        //GET NEXT DATE AND SET THE NEXT ROUTINES
        if (lastDate==NULL) {
            routine.nextDate = [DateofNextEvent nextEventDateWithNotificationUpdate:date withRoutineTypeID:routine.routineTypeID withFrequency:routine.frecuency withAdviceBefore:routine.routineNotice withNameYorkie:self.yorkieName andDatabase:database];
        } else {
            routine.nextDate = [DateofNextEvent nextEventDateWithNotificationUpdate:lastDate withRoutineTypeID:routine.routineTypeID withFrequency:routine.frecuency withAdviceBefore:routine.routineNotice withNameYorkie:self.yorkieName andDatabase:database];
        }

        [self.yorkieRoutineArray addObject:routine];
    }
    
    [database close];

    //ORDER ARRAY
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"nextDate"
                                                               ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *order = [self.yorkieRoutineArray sortedArrayUsingDescriptors:descriptors];
    
    //SET "NO EVENT" AT END OF ARRAY
    NSArray *sortedArray = [order sortedArrayUsingComparator: ^(Routine *obj1, Routine *obj2) {
        BOOL str1HasSpace=FALSE;
        BOOL str2HasSpace=FALSE;

        if (obj1.nextDate==NULL) {
            str1HasSpace=TRUE;
        }
        if (obj2.nextDate==NULL) {
            str2HasSpace=TRUE;
        }
        
        if (str1HasSpace && !str2HasSpace) {
            return NSOrderedDescending;
        } else if (str2HasSpace && !str1HasSpace) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];

    return sortedArray;
}

//tap photo yorkie or label name
- (void)cellTap:(UISwipeGestureRecognizer *)gesture {
    
    MainDetailViewController *dVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YorkieDetail"];
    dVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    dVC.edit = YES;
    dVC.save = NO;
    dVC.idYorkie = self.yorkieID;
    dVC.cellIdentifier = self.cellIdentifier;
    dVC.iphoneModel = self.iphoneModel;
    dVC.title = @"Yorkie";
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:dVC];
    self.animator.dragable = YES;
    self.animator.bounces = NO;
    self.animator.behindViewAlpha = 1.0f;//0.5f;
    self.animator.behindViewScale = 1.0f;
    self.animator.transitionDuration = 0.5f;//0.7f;

    self.animator.direction = ZFModalTransitonDirectionBottom;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dVC];
    navController.transitioningDelegate = self.animator;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - CollectionView layout

// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
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
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
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
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
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
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    switch (self.iphoneModel) {
        case 4: //iPhone 4
            return UIEdgeInsetsMake(8,20,0,0);
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

#pragma mark - scrollView methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //upload pageControlYorkie position
    CGFloat pageWidth = self.collectionView.frame.size.width;
    float currentPage = self.collectionView.contentOffset.x / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f)) {
        self.pageControlYorkie.currentPage = currentPage + 1;
    }
    else {
        self.pageControlYorkie.currentPage = currentPage;
    }
}

#pragma mark - NSNotification to select table cell

//send data to routineViewController
- (void)tableCellDidSelect:(Routine*)cell {
    //if date is empty show "no event"
    if ((cell.startDate==NULL) || ([cell.startDate isEqualToString:@""])) {
        RoutineSaveViewController *dVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SaveEditRoutine"];
        dVC.edit = NO;
        dVC.idRoutine = cell.routineID;
        dVC.title = self.yorkieName;
        dVC.iphoneModel = self.iphoneModel;
        dVC.routine = cell;
   
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dVC];
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        RoutineViewController *dVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YorkieRoutine"];
        dVC.idRoutine = cell.routineID;
        dVC.idYorkie = cell.yorkieID;
        dVC.routineDescription = cell.imageDesc;
        dVC.routineImage = cell.imageName;
        dVC.iphoneModel = self.iphoneModel; //iPhone model to use in collectionView
        dVC.cellIdentifier = self.cellIdentifier; //to set size in the collectionView
        dVC.title = self.yorkieName;
        [ [self navigationController] pushViewController:dVC animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"save"]) {
        UINavigationController *navTmp = segue.destinationViewController;
        MainSaveViewController * sVC = ((MainSaveViewController *)[navTmp topViewController]);
        sVC.save = YES;
        sVC.edit = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
