//
//  YorkieCollectionCell.h
//  Yorkie
//
//  Created by Carlos Butron on 07/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainCollectionCell;

@protocol YorkieCollectionCellDelegate
- (void)tableCellDidSelect:(UITableViewCell *)cell;
@end

@interface MainCollectionCell : UICollectionViewCell<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageYorkie;
@property (weak, nonatomic) IBOutlet UIView *viewYorkie;
@property (weak, nonatomic) IBOutlet UIView *detailValuesView;
@property (weak, nonatomic) IBOutlet UILabel *labelYorkie;
@property (weak, nonatomic) IBOutlet UILabel *ageYorkieLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightYorkieLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderYorkieLabel;
@property (strong,nonatomic) NSArray *cellData;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (weak,nonatomic) id<YorkieCollectionCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger yorkieIdentifier;

@end
