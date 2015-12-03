//
//  RoutineCollectionCell.h
//  Yorkie
//
//  Created by Carlos Butron on 05/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutineCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *routineValuesView;
@property (weak, nonatomic) IBOutlet UIImageView *imageYorkie;
@property (weak, nonatomic) IBOutlet UIImageView *imageRoutine;
@property (weak, nonatomic) IBOutlet UILabel *routineLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateNextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;

@end
