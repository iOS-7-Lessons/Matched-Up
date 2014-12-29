//
//  ChatViewController.m
//  Matched Up
//
//  Created by Eray on 15/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "ChatViewController.h"

#define TAG @"ChatViewController"

@interface ChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;
@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser = self.chatRoom[@"user1"];
    if ([testUser.objectId isEqualToString:self.currentUser.objectId]) {
        self.withUser = self.chatRoom[@"user2"];
    }
    else self.withUser = self.chatRoom[@"user1"];
    
    self.title = self.withUser[@"profile"][@"firstName"];
    self.initialLoadComplete = NO;

    [self checkForNewChats];
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.chatsTimer invalidate];
    self.chatsTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)chats {
    if (!_chats) _chats = [[NSMutableArray alloc] init];
    return _chats;
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chats count];
}

#pragma mark - TableViewDelegate

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    if (text.length != 0) {
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        [chat setObject:self.chatRoom forKey:@"chatroom"];
        [chat setObject:self.currentUser forKey:@"fromUser"];
        [chat setObject:self.withUser forKey:@"toUser"];
        [chat setObject:text forKey:@"text"];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.chats addObject:chat];
                [JSMessageSoundEffect playMessageSentSound];
                [self.tableView reloadData];
                [self finishSend];
                [self scrollToBottomAnimated:YES];
            } else NSLog(@"%@ : %@", TAG, error);
        }];
    }
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testUser = chat[@"fromUser"];
    
    if ([testUser.objectId isEqualToString:self.currentUser.objectId]) {
        return JSBubbleMessageTypeOutgoing;
    } else return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testUser = chat[@"fromUser"];
    
    if ([testUser.objectId isEqualToString:self.currentUser.objectId]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    } else return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
}

- (JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}
- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    return nil;
}

- (id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    JSMessage *message = [[JSMessage alloc] init];
    message.text = chat[@"text"];
    return message;
}

//- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    PFObject *chat = self.chats[indexPath.row];
//    NSString *message = chat[@"text"];
//    return message;
//}

#pragma mark - Messages View Delegate OPTIONAL

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

#pragma mark - Helper Methods

- (void)checkForNewChats {
    int oldChatsCount = [self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:@"Chat"];
    [queryForChats whereKey:@"chatroom" equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.initialLoadComplete == NO || oldChatsCount != [objects count]) {
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                
                if (self.initialLoadComplete == YES) [JSMessageSoundEffect playMessageReceivedAlert];
                
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
    }];
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
