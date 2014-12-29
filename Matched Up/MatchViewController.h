//
//  MatchViewController.h
//  Matched Up
//
//  Created by Eray on 14/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchViewControllerDelegate <NSObject>

- (void)presentMathcesViewController;

@end

@interface MatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak) id <MatchViewControllerDelegate> delegate;

@end
