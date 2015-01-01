//
//  ProfileViewController.h
//  Matched Up
//
//  Created by Eray on 06/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileViewControllerDelegate <NSObject>

- (void)didLikePressed;
- (void)didDislikePressed;

@end

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;
@property (weak, nonatomic) id <ProfileViewControllerDelegate> delegate;

@end
