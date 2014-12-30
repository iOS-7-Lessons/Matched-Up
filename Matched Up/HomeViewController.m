//
//  HomeViewController.m
//  Matched Up
//
//  Created by Eray on 05/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "TestUser.h"
#import "MatchViewController.h"

@interface HomeViewController () <MatchViewControllerDelegate>

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
    //    [TestUser saveTestUserToParse];
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.tagLineLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            if ([self allowPhoto] == NO) {
                [self setupNextPhoto];
            } else [self queryForCurrentPhotoIndex];
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
    [self performSegueWithIdentifier:@"homeToMatchesViewControllerSegue" sender:nil];
}
- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}
- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"toProfileViewControllerSegue" sender:nil];
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}

#pragma mark - Helper Methods

- (void)queryForCurrentPhotoIndex {
    //NSLog(@"Photos Data %@", self.photos); // TEST
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.photoImageView.image = [UIImage imageWithData:data];
                [self updateView];
            } else {
                NSLog(@"%@", error);
            }
        }];
    }
    
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
            self.infoButton.enabled = YES;
        }
    }];
}

- (void)updateView {
    self.firstNameLabel.text = self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kPhotoUserKey][kUserTagLineKey];
}

- (void)setupNextPhoto {
    if (self.currentPhotoIndex + 1 < [self.photos count]) {
        self.currentPhotoIndex ++;
        if ([self allowPhoto] == NO) {
            [self setupNextPhoto];
        } else [self queryForCurrentPhotoIndex];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No more users" message:@"Check later to see more users" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)allowPhoto {
    int maxAge = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kMaxAgeKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kSingleEnabledKey];
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kPhotoUserKey];
    
    int userAge = (int)[user[kUserProfileKey][kUserProfileAgeKey] integerValue];
    NSString *gender = user[kUserProfileKey][kUserProfileGenderKey];
    NSString *relationshipStatus = user[kUserProfileKey][kUserProfileRelationshipStatusKey];
    
    if (userAge > maxAge) return NO;
    else if ( men == NO && [gender isEqualToString:@"male"] ) return NO;
    else if ( women == NO && [gender isEqualToString:@"female"] ) return NO;
    else if ( single == NO && ([relationshipStatus isEqualToString:@"single"]
                            || relationshipStatus == nil)) return NO;
    
    return YES;
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
            [self checkForPhotoUserLikes];
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

- (void)checkForPhotoUserLikes {
    PFQuery *query = [PFQuery queryWithClassName:kActivityClassKey];
    [query whereKey:kActivityFromUserKey equalTo:self.photo[kPhotoUserKey]];
    [query whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            // creating the chatroom
            [self createChatRoom];
        }
    }];
}

- (void)createChatRoom {
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kChatRoomClassKey];
    [queryForChatRoom whereKey:kChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kChatRoomUser2Key equalTo:self.photo[kPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kChatRoomUser1Key equalTo:self.photo[kPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            PFObject *chatRoom = [PFObject objectWithClassName:kChatRoomClassKey];
            [chatRoom setObject:[PFUser currentUser] forKey:kChatRoomUser1Key];
            [chatRoom setObject:self.photo[kPhotoUserKey] forKey:kChatRoomUser2Key];
            [chatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) [self performSegueWithIdentifier:@"homeToMatchViewControllerSegue" sender:nil];
            }];
        }
    }];
}

#pragma mark - MathcesViewControllerDelegate

- (void)presentMathcesViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesViewControllerSegue" sender:nil];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toProfileViewControllerSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *targetVC = segue.destinationViewController;
            targetVC.photo = self.photo;
        }
    }
    else if ([segue.identifier isEqualToString:@"homeToMatchViewControllerSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[MatchViewController class]]) {
            MatchViewController *targetVC = segue.destinationViewController;
            targetVC.matchedUserImage = self.photoImageView.image;
            targetVC.delegate = self;
        }
    }
}

@end
