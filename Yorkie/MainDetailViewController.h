//
//  YorkieDetailViewController.h
//  Yorkie
//
//  Created by Carlos Butron on 26/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainSaveViewController.h"

@interface MainDetailViewController : UIViewController<UICollectionViewDataSource, SaveYorkieViewControllerEditDelegate>

//get from the last view if we need to delete or edit Yorkie
@property BOOL save;
@property BOOL edit;
@property NSInteger idYorkie;
@property NSInteger iphoneModel; //to save the iPhone model and present the screen size in a perfect way
@property (nonatomic, strong) NSString *cellIdentifier; //personal size of cell from Main collectionView

@end
