//
//  ChatViewController.h
//  Matched Up
//
//  Created by Eray on 15/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface ChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>
@property (strong, nonatomic) PFObject *chatRoom;
@end
