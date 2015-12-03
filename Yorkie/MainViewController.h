//
//  ViewController.h
//  Yorkie
//
//  Created by Carlos Butron on 09/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCollectionCell.h"
#import "RoutineViewController.h"
#import "RoutineSaveViewController.h"
#import "MainMenuCell.h"

@interface MainViewController : UIViewController <UICollectionViewDataSource, YorkieCollectionCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

