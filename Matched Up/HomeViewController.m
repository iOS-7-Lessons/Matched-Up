//
//  HomeViewController.m
//  Matched Up
//
//  Created by Eray on 05/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "HomeViewController.h"
#import "TestUser.h"

@interface HomeViewController ()

// IBOutlets

@property (weak, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    
    [TestUser saveTestUserToParse];
    
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
            [self updateView];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}
- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}
- (IBAction)infoButtonPressed:(UIButton *)sender {
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}

#pragma mark - Helper Methods

- (void)queryForCurrentPhotoIndex {
    NSLog(@"Photos Data %@", self.photos); // TEST
    self.photo = self.photos[self.currentPhotoIndex];
    PFFile *file = self.photo[kPhotoPictureKey];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.photoImageView.image = [UIImage imageWithData:data];
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    PFQuery *isLikeQuery = [PFQuery queryWithClassName:kActivityClassKey];
    [isLikeQuery whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [isLikeQuery whereKey:kActivityPhotoKey equalTo:self.photo];
    [isLikeQuery whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
    [isLikeQuery whereKey:kActivityToUserKey equalTo:self.photo[kPhotoUserKey]];
    
    PFQuery *isDislikeQuery = [PFQuery queryWithClassName:kActivityClassKey];
    [isDislikeQuery whereKey:kActivityTypeKey equalTo:kActivityTypeDislikeKey];
    [isDislikeQuery whereKey:kActivityPhotoKey equalTo:self.photo];
    [isDislikeQuery whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
    [isLikeQuery whereKey:kActivityToUserKey equalTo:self.photo[kPhotoUserKey]];
    
    PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[isLikeQuery, isDislikeQuery]];
    [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.activities = [objects mutableCopy];
            if ([self.activities count] > 0) {
                PFObject *activity = self.activities[0];
                if ([activity[kActivityTypeKey] isEqualToString:kActivityTypeLikeKey]) {
                    self.isLikedByCurrentUser = YES;
                    self.isDislikedByCurrentUser = NO;
                }
                else if ([activity[kActivityTypeKey] isEqualToString:kActivityTypeDislikeKey]) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = YES;
                }
            } else {
                self.isLikedByCurrentUser = NO;
                self.isDislikedByCurrentUser = NO;
            }
            self.likeButton.enabled = YES;
            self.dislikeButton.enabled = YES;
        }
    }];
}

- (void)updateView {
    self.firstNameLabel.text = self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kPhotoUserKey][kCCUserTagLineKey];
}

- (void)setupNextPhoto {
    if (self.currentPhotoIndex + 1 < [self.photos count]) {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No more users" message:@"Check later to see more users" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:kActivityClassKey];
    [likeActivity setObject:kActivityTypeLikeKey forKey:kActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            self.isLikedByCurrentUser = YES;
            self.isDislikedByCurrentUser = NO;
            [self.activities addObject:likeActivity];
            [self setupNextPhoto];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)saveDislike {
    PFObject *dislikeActivity = [PFObject objectWithClassName:kActivityClassKey];
    [dislikeActivity setObject:kActivityTypeDislikeKey forKey:kActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            self.isLikedByCurrentUser = NO;
            self.isDislikedByCurrentUser = YES;
            [self.activities addObject:dislikeActivity];
            [self setupNextPhoto];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)checkLike {
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser) {
        PFObject *activity = [self.activities lastObject];
        [activity deleteInBackground];
        [self.activities removeLastObject];
        [self saveLike];
    }
    else [self saveLike];
}

- (void)checkDislike {
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser) {
        PFObject *activity = [self.activities lastObject];
        [activity deleteInBackground];
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else [self saveDislike];
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
