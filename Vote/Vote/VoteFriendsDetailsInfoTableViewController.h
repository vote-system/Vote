//
//  VoteFriendsDetailsInfoTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-7-20.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteFriendsDetailsInfoTableViewController : UITableViewController

@property (strong, nonatomic) NSString *originalHeadImageURL;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *screenname;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *signature;
@property (assign, nonatomic) BOOL isFriend;

@end

#define ADD_FRIEND_REQUEST      2
#define DELETE_FRIEND_REQUEST   3
#define AGREE_FRIEND_REQUEST    4