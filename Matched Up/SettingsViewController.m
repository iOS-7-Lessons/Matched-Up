//
//  SettingsViewController.m
//  Matched Up
//
//  Created by Eray on 06/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISlider *ageSlider;
@property (weak, nonatomic) IBOutlet UISwitch *showMenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showWomenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *singlesOnlySwitch;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:kMaxAgeKey];
    self.showMenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kMenEnabledKey];
    self.showWomenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kWomenEnabledKey];
    self.singlesOnlySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSingleEnabledKey];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.showMenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.showWomenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singlesOnlySwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
//    self.ageLabel.text = [NSString stringWithFormat:@"19"];
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selectors

- (void)valueChanged:(id)sender {
    if (sender == self.ageSlider) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.ageSlider.value forKey:kMaxAgeKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    } else if (sender == self.showMenSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.showMenSwitch.isOn forKey:kMenEnabledKey];
    } else if (sender == self.showWomenSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.showWomenSwitch.isOn forKey:kWomenEnabledKey];
    } else if (sender == self.singlesOnlySwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.singlesOnlySwitch.isOn forKey:kSingleEnabledKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - IBActions

- (IBAction)logoutButtonPressed:(UIButton *)sender {
}

- (IBAction)editProfileButtonPressed:(UIButton *)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
