//
//  TestUser.m
//  Matched Up
//
//  Created by Eray on 08/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

+ (void)saveTestUserToParse
{
    PFUser *testUser = [PFUser user];
    testUser.username = @"user1";
    testUser.password = @"password1";
    
    [testUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"sign up %@", error);
        if (!error) {
            NSDictionary *profile = @{@"age": @28, @"birthday": @"23/04/1983", @"firstName": @"Julie", @"gender": @"female", @"location": @"Istanbul, Turkey", @"name": @"Julie Adams"};
            [testUser setObject:profile forKey:kUserProfileKey];
            [testUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    UIImage *userImage = [UIImage imageNamed:@"user1.jpg"];
                    NSData *userImageData = UIImageJPEGRepresentation(userImage, 0.8);
                    PFFile *userImageFile = [PFFile fileWithData:userImageData];
                    PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
                    [photo setObject:userImageFile forKey:kPhotoPictureKey];
                    [photo setObject:testUser forKey:kPhotoUserKey];
                    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            NSLog(@"Photo saved successfully");
                        } else NSLog(@"asd %@", error);
                    }];
                } //else NSLog(@"%@", error);
            }];
        } //else NSLog(@"%@", error);
    }];
}

@end
