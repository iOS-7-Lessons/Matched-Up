//
//  ProfileViewController.m
//  Matched Up
//
//  Created by Eray on 06/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFFile *imageFile = self.photo[kPhotoPictureKey];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.profilePictureImageView.image = image;
        }
    }];
    
    PFUser *user = self.photo[kPhotoUserKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kUserProfileKey][kUserProfileAgeKey]];
    self.locationLabel.text = user[kUserProfileKey][kUserProfileLocationKey];
    
    if (user[kUserProfileKey][kUserProfileRelationshipStatusKey] == nil)
        self.statusLabel.text = @"Single";
     else self.statusLabel.text = user[kUserProfileKey][kUserProfileRelationshipStatusKey];
        
    self.taglineLabel.text = user[kUserTagLineKey];
    
    self.title = user[kUserProfileKey][kUserProfileFirstNameKey];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self.delegate didLikePressed];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self.delegate didDislikePressed];
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
