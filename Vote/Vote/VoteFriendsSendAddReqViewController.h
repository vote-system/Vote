//
//  VoteFriendsSendAddReqViewController.h
//  Vote
//
//  Created by 丁 一 on 14-7-23.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteFriendsSendAddReqViewController : UIViewController

@property (strong, nonatomic) NSString *username;

@end

#define ADD_FRIEND_REQUEST      2
#define DELETE_FRIEND_REQUEST   3
#define AGREE_FRIEND_REQUEST    4