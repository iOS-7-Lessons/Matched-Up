//
//  Constants.h
//  Matched Up
//
//  Created by Eray on 02/12/14.
//  Copyright (c) 2014 Eray Diler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - User Class

extern NSString *const kUserTagLineKey;

extern NSString *const kUserProfileKey;
extern NSString *const kUserProfileNameKey;
extern NSString *const kUserProfileFirstNameKey;
extern NSString *const kUserProfileLocationKey;
extern NSString *const kUserProfileGenderKey;
extern NSString *const kUserProfileBirthdayKey;
extern NSString *const kUserProfileInterestedInKey;
extern NSString *const kUserProfilePictureURLKey;
extern NSString *const kUserProfileAgeKey;
extern NSString *const kUserProfileRelationshipStatusKey;

#pragma mark - Photo Class

extern NSString *const kPhotoClassKey;
extern NSString *const kPhotoUserKey;
extern NSString *const kPhotoPictureKey;

#pragma mark - Activity

extern NSString *const kActivityClassKey;
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityFromUserKey;
extern NSString *const kActivityToUserKey;
extern NSString *const kActivityPhotoKey;
extern NSString *const kActivityTypeLikeKey;
extern NSString *const kActivityTypeDislikeKey;

#pragma mark - Settings

extern NSString *const kMenEnabledKey;
extern NSString *const kWomenEnabledKey;
extern NSString *const kSingleEnabledKey;
extern NSString *const kMaxAgeKey;

#pragma mark - ChatRoom

extern NSString *const kChatRoomClassKey;
extern NSString *const kChatRoomUser1Key;
extern NSString *const kChatRoomUser2Key;

#pragma mark - Chat

extern NSString *const kChatClassKey;
extern NSString *const kChatChatroomKey;
extern NSString *const kChatFromUserKey;
extern NSString *const kChatToUserKey;
extern NSString *const kChatTextKey;

@end
