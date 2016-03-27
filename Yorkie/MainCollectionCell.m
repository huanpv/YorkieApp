//
//  YorkieCollectionCell.m
//  Yorkie
//
//  Created by Carlos Butron on 07/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "MainCollectionCell.h"
#import "MainMenuCell.h"
#import "Routine.h"
#import "DateofNextEvent.h"

@implementation MainCollectionCell

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.cellData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.layer.cornerRadius = 5;
    MainMenuCell *yorkieMenuCell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    Routine *routine= [[Routine alloc] init];
    routine = self.cellData[indexPath.row];
    yorkieMenuCell.imageYorkieMenuCell.image = [UIImage imageNamed:routine.imageName];
    
    //if date is empty show "no event"
    if (routine.nextDate==NULL) {
        yorkieMenuCell.labelYorkieMenuCell.text = [NSString stringWithFormat:NSLocalizedString(@"No event", nil)];
        yorkieMenuCell.labelYorkieMenuCell.textColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:158.0/255.0 alpha:1];
        
    } else {
        
        if ([DateofNextEvent noticeNextEventDate:routine.nextDate withBeforeDays:routine.routineNotice withRoutineID:routine.routineID]) {
            yorkieMenuCell.labelYorkieMenuCell.text = [DateofNextEvent age:routine.nextDate];
            yorkieMenuCell.labelYorkieMenuCell.textColor = [UIColor redColor];
        } else {
            if (routine.nextDate==NULL){
                yorkieMenuCell.labelYorkieMenuCell.text = [NSString stringWithFormat:NSLocalizedString(@"No event", nil)];
                yorkieMenuCell.labelYorkieMenuCell.textColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:158.0/255.0 alpha:1];
            } else {
            yorkieMenuCell.labelYorkieMenuCell.text = [DateofNextEvent age:routine.nextDate];
            yorkieMenuCell.labelYorkieMenuCell.textColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:158.0/255.0 alpha:1];
            }
        }
    }
    
    //color of selected cell
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:0.35];
    [yorkieMenuCell setSelectedBackgroundView:bgColorView];
    
    return yorkieMenuCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //DESELECT THE CELL WHEN USER TAPS IT
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[self delegate] tableCellDidSelect:self.cellData[indexPath.row]];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        dispatch_async(dispatch_get_main_queue(), ^
            {
            for (UITableViewCell* cell in self.tableView.visibleCells)
            cell.highlighted = NO;
            });
    }
}

@end
