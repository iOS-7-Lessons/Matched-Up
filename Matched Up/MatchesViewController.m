//
//  MatchesViewController.m
//  Matched Up
//
//  Created by Eray on 14/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "MatchesViewController.h"
#import "ChatViewController.h"

#define TAG @"MatchesViewController"

@interface MatchesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableChatRooms;

@end

@implementation MatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Matches!";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self updateAvailableChatRooms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)availableChatRooms {
    if (!_availableChatRooms) _availableChatRooms = [[NSMutableArray alloc] init];
    return _availableChatRooms;
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableChatRooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Matches Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PFObject *chatRoom = self.availableChatRooms[indexPath.row];
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *tmpUser = chatRoom[@"user1"];
    if ([tmpUser.objectId isEqualToString:currentUser.objectId]) {
        likedUser = chatRoom[@"user2"];
    } else {
        likedUser = chatRoom[@"user1"];
    }
    cell.textLabel.text = likedUser[@"profile"][@"firstName"];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForUserPhoto = [PFQuery queryWithClassName:kPhotoClassKey];
    [queryForUserPhoto whereKey:@"user" equalTo:likedUser];
    [queryForUserPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *imageFile = photo[kPhotoPictureKey];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }];
    
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"matchesToChatViewControllerSegue" sender:indexPath];
}

#pragma mark - Helper Methods

- (void)updateAvailableChatRooms {
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [combinedQuery includeKey:@"chat"];
    [combinedQuery includeKey:@"user1"];
    [combinedQuery includeKey:@"user2"];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.availableChatRooms removeAllObjects];
            self.availableChatRooms = [objects mutableCopy];
            [self.tableView reloadData];
        } else NSLog(@"%@ : %@", TAG, error);
    }];    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"matchesToChatViewControllerSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ChatViewController class]]) {
            ChatViewController *chatVC = segue.destinationViewController;
            NSIndexPath *indexPath = sender;
            chatVC.chatRoom = self.availableChatRooms[indexPath.row];
        }
    }
}


@end
