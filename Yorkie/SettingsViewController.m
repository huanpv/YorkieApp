//
//  SettingsViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 21/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"

@interface SettingsViewController ()

@property (strong, nonatomic) NSArray *labelFeedbackArray;
@property (strong, nonatomic) NSArray *labelSettingsArray;
@property (strong, nonatomic) NSArray *imageFeedbackArray;
@property (strong, nonatomic) NSArray *imageSettingsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageSettings;
@property NSInteger cellHeight; //cell size

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imageSettings setImage:[UIImage imageNamed:NSLocalizedString(@"buyImage", nil)]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView.hidden = true;
    self.labelSettingsArray = @[@"iCloud backup", @"Themes", NSLocalizedString(@"Dog Age real/human", nil)];
    self.imageSettingsArray = @[@"icloud.png", @"themes.png",@"dogAge.png"];
    self.labelFeedbackArray = @[NSLocalizedString(@"Send us an email", nil), NSLocalizedString(@"Rate Yorkie", nil), NSLocalizedString(@"Credits", nil)];
    self.imageFeedbackArray = @[@"email.png", @"star.png", @"credits.png"];
    self.title = NSLocalizedString(@"Settings", nil);
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0) {
        return 3;
    } else {
        return 3;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if (section ==0) {
        return @"Settings";
    } else {
        return @"Feedback";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = nil;
    
    if (indexPath.section == 0) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"DogAge"];
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                viewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsEmail"];
                break;
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1000836606&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]]];
                break;
            case 2:
                viewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsCredits"];
                break;
            default:
                viewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsEmail"];
                break;
        }
    }
    [[self navigationController] pushViewController:viewController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat height = CGRectGetHeight(screen);
    
    switch ((int)height) {
        case 480:
            self.cellHeight = 50;
            break;
            
        default:
            self.cellHeight = 55;
            break;
    }
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    SettingsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"feedbackCell"];

    if (indexPath.section == 0) {
        cell.labelFeedback.text = self.labelSettingsArray[indexPath.row];
        UIImage *image = [UIImage imageNamed:self.imageSettingsArray[indexPath.row]];
        [cell.imageFeedback setImage:image];
        //color of selected cell
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:0.35];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    if (indexPath.section == 1) {
        cell.labelFeedback.text = self.labelFeedbackArray[indexPath.row];
        UIImage *image = [UIImage imageNamed:self.imageFeedbackArray[indexPath.row]];
        [cell.imageFeedback setImage:image];
        //color of selected cell
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:0.35];
        [cell setSelectedBackgroundView:bgColorView];
    }
    return cell;
}

@end
