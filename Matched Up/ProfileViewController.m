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
    
    PFObject *photo = self.photo;
    PFFile *imageFile = self.photo[kPhotoPictureKey];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.profilePictureImageView.image = image;
        }
    }];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%@", photo[kPhotoUserKey][kUserProfileKey][kUserProfileAgeKey]];
    self.locationLabel.text = photo[kPhotoUserKey][kUserProfileKey][kUserProfileLocationKey];
    self.statusLabel.text = photo[kPhotoUserKey][kUserProfileKey][kUserProfileRelationshipStatusKey];
    self.taglineLabel.text = photo[kPhotoUserKey][kUserProfileKey][kUserTagLineKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
