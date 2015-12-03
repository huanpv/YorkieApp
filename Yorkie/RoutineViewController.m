//
//  RoutineViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 10/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "RoutineViewController.h"
#import "RoutineSaveViewController.h"
#import "RoutineCollectionCell.h"
#import "Routine.h"
#import "sqlite3.h" //database
#import "FMDatabase.h" // from cocoa pods and github
#import "LoadImageFromBundle.h"
#import "DateofNextEvent.h"

@interface RoutineViewController ()


@property (nonatomic, strong) Routine *routine;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation RoutineViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Do any additional setup after loading the view.
}




//set custom navigation bar
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self styleNavBar];
    [self databaseRoutineDidOpen];
    [self.collectionView reloadData];

}



//custom navigation bar
- (void)styleNavBar {
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/255.0 green:151.0/255.0 blue:40.0/255.0 alpha:1];
    
    //add buttons to navigation bar
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionEditButton:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)actionEditButton:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RoutineSaveViewController *dVC = [storyboard instantiateViewControllerWithIdentifier:@"SaveEditRoutine"];
    
    dVC.edit = YES;
    dVC.routine = self.routine;
    dVC.idRoutine = self.routine.routineID;
    dVC.iphoneModel = self.iphoneModel;
    dVC.title = self.title;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dVC];
    [self presentViewController:navController animated:YES completion:nil];
    
}




//********COLLECTION VIEW***********//
#pragma mark - UICollectionView Methods


//elements of Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return 1;
    
    
}


//table highlight when tap photo disallow
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


//table highlight when tap photo disallow
-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // NOTE: This is called, as long as both shouldSelectItemAtIndexPath: AND shouldHighlightItemAtIndexPath: return YES. If either returns NO, the cell is not actually selected.
    NSLog(@"Did select collection view cell: %@", indexPath);
}


//get the cell of Collection View
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RoutineCollectionCell * yorkieCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    yorkieCollectionCell.imageYorkie.image = [LoadImageFromBundle loadImage:self.title];
    yorkieCollectionCell.imageYorkie.clipsToBounds = YES;
    yorkieCollectionCell.imageYorkie.layer.cornerRadius = 5.0;
    yorkieCollectionCell.imageYorkie.layer.masksToBounds = YES;
    [yorkieCollectionCell.imageYorkie setContentMode:UIViewContentModeScaleAspectFill];
    yorkieCollectionCell.routineValuesView.clipsToBounds = YES;
    yorkieCollectionCell.routineValuesView.layer.cornerRadius = 5.0;
    yorkieCollectionCell.routineValuesView.layer.masksToBounds = YES;
    
    yorkieCollectionCell.imageRoutine.image = [UIImage imageNamed:self.routineImage];
    yorkieCollectionCell.routineLabel.text = NSLocalizedString(self.routineDescription, nil);
    yorkieCollectionCell.nextLabel.text = NSLocalizedString(@"Next", nil);
    
    
    //fix to spanish language
    if (([yorkieCollectionCell.routineLabel.text isEqualToString:@"Peluquería"]) || ([yorkieCollectionCell.routineLabel.text isEqualToString:@"Vacunación"]) || ([yorkieCollectionCell.routineLabel.text isEqualToString:@"Pastilla"]) || ([yorkieCollectionCell.routineLabel.text isEqualToString:@"Medicina"])) {
        yorkieCollectionCell.nextLabel.text = @"Próxima";
    }
    if ([yorkieCollectionCell.routineLabel.text isEqualToString:@"Cuidado dental"]) {
        
        switch (self.iphoneModel) {
            case 5: {
                UIFont *routineFont = yorkieCollectionCell.routineLabel.font;
                yorkieCollectionCell.routineLabel.font = [routineFont fontWithSize:26]; //if we need to change only the font size
            }
                break;
            case 6: {
                UIFont *routineFont = yorkieCollectionCell.routineLabel.font;
                yorkieCollectionCell.routineLabel.font = [routineFont fontWithSize:28]; //if we need to change only the font size
            }
                break;
            case 7: {
                UIFont *routineFont = yorkieCollectionCell.routineLabel.font;
                yorkieCollectionCell.routineLabel.font = [routineFont fontWithSize:32]; //if we need to change only the font size
            }
                break;
                
            default:
                break;
        }
        

        
    }

    
    //cast routine.startDate string into NSDate
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [dateFormat dateFromString: self.routine.startDate];
    yorkieCollectionCell.dateStartLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Start", nil), [DateofNextEvent age:date]];
    
    if (self.routine.frecuency==1) {
        yorkieCollectionCell.dateFrequencyLabel.text = [NSString stringWithFormat:@"%@ %ld %@", NSLocalizedString(@"Repeat every", nil), (long)self.routine.frecuency, NSLocalizedString(@"day", nil)];
    } else {
        
        if (self.routine.frecuency==365) {
            yorkieCollectionCell.dateFrequencyLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Repeat every year", nil)];
        } else {
        yorkieCollectionCell.dateFrequencyLabel.text = [NSString stringWithFormat:@"%@ %ld %@", NSLocalizedString(@"Repeat every", nil), (long)self.routine.frecuency, NSLocalizedString(@"days", nil)];
        }
    }
    
    
    

    yorkieCollectionCell.dateCommentLabel.text = self.routine.name;
    yorkieCollectionCell.dateNextLabel.text = [DateofNextEvent age:self.routine.nextDate];
    
    
    
    
    //TAP on routine details
    UITapGestureRecognizer *tapRoutineValues=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];

    
    
    [yorkieCollectionCell.routineValuesView addGestureRecognizer:tapRoutineValues];

    
    
    
    return yorkieCollectionCell;
    
}


//tap photo yorkie or label name
-(void)cellTap:(UISwipeGestureRecognizer *)gesture
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RoutineSaveViewController *dVC = [storyboard instantiateViewControllerWithIdentifier:@"SaveEditRoutine"];
    
    dVC.edit = YES;
    dVC.routine = self.routine;
    dVC.idRoutine = self.routine.routineID;
    dVC.iphoneModel = self.iphoneModel;
    dVC.title = self.title;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dVC];
    [self presentViewController:navController animated:YES completion:nil];
    
}



//get the routine data to show in routine view
- (void)databaseRoutineDidOpen  {
    
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
    
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *results = [database executeQuery:@"SELECT routine.idRoutine, routine.idYorkie, routine.idRoutineType, routine.comment, routine.startDate, routine.frequency, routineType.image, routineType.description FROM routine, routineType where ? = routine.idYorkie and ? = routine.idRoutine and routine.idRoutineType = routineType.idRoutineType", [NSString stringWithFormat:@"%ld",(long)self.idYorkie], [NSString stringWithFormat:@"%ld",(long)self.idRoutine]];
    

    self.routine= [[Routine alloc] init];
    
    while([results next]) {

        self.routine.yorkieID = [results intForColumn:@"idYorkie"];
        self.routine.routineID = [results intForColumn:@"idRoutine"];
        self.routine.routineTypeID = [results intForColumn:@"idRoutineType"];
        self.routine.name = [results stringForColumn:@"comment"];
        self.routine.startDate = [results stringForColumn:@"startDate"];
        self.routine.frecuency = [results intForColumn:@"frequency"];
        self.routine.imageDesc = [results stringForColumn:@"description"];
        self.routine.imageName = [results stringForColumn:@"image"];
        
        //cast routine.startDate string into NSDate
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSDate *date = [dateFormat dateFromString: self.routine.startDate];
        
        self.routine.nextDate = [DateofNextEvent nextEventDate:date withFrequency:self.routine.frecuency];

        
    }
    
    [database close];
    
    
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
            mElementSize = CGSizeMake(342, 573);
            break;
        case 7:
            mElementSize = CGSizeMake(389, 666);
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
            return UIEdgeInsetsMake(-6,16,0,0);
            break;
        case 6: //iPhone 6
            return UIEdgeInsetsMake(12,20,0,0);
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
