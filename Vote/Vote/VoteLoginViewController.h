//
//  VoteLoginViewController.h
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>


#define LOGIN_SUCCESS       1
#define LOGIN_ERROR         0
#define DB_ITEM_NOT_FOUND   7

@interface VoteLoginViewController : UIViewController

@property (strong, nonatomic) NSArray *loginData;

@end


#define LVC_LOADING_VIEW_TAG               1001
#define LVC_ACTIVITY_INDICATOR_TAG         1002