//
//  SettingsCreditsViewController.m
//  Yorkie
//
//  Created by Carlos Butron on 25/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "SettingsCreditsViewController.h"

@interface SettingsCreditsViewController ()
@property (weak, nonatomic) IBOutlet UIView *versionView;
@property (weak, nonatomic) IBOutlet UIView *developmentView;
@property (weak, nonatomic) IBOutlet UIView *thankstoView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *developmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *thankstoLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentManagerLabel;

@end

@implementation SettingsCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionView.layer.cornerRadius = 5.0;
    self.developmentView.layer.cornerRadius = 5.0;
    self.thankstoView.layer.cornerRadius = 5.0;
    
    self.versionLabel.text = NSLocalizedString(@"Version", nil);
    self.developmentLabel.text = NSLocalizedString(@"Development", nil);
    self.thankstoLabel.text = NSLocalizedString(@"Thanks to", nil);
    self.contentManagerLabel.text = NSLocalizedString(@"Content Manager", nil);
    
    self.title = NSLocalizedString(@"Credits", nil);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
