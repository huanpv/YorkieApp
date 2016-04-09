//
//  DetailViewController.h
//  Yorkie
//
//  Created by Carlos Butron on 10/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutineViewController : UIViewController

@property NSInteger iphoneModel; //to save the iPhone model and present the screen size in a perfect way
@property (nonatomic, strong) NSString *cellIdentifier; //personal size of cell from Main collectionView
@property NSInteger idYorkie;
@property NSInteger idRoutine;
@property (nonatomic, strong) NSString *routineDescription;
@property (nonatomic, strong) NSString *routineImage;

@end
