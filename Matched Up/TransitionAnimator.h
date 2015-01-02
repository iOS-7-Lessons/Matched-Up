//
//  TransitionAnimator.h
//  Matched Up
//
//  Created by Eray on 01/01/15.
//  Copyright (c) 2015 Eray Diler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
