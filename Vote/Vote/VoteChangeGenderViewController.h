//
//  VoteChangeGenderViewController.h
//  Vote
//
//  Created by 丁 一 on 14-3-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Gender)(NSString *gender);

@interface VoteChangeGenderViewController : UIViewController

@property (copy, nonatomic) Gender genderCallBack;

@end

#define CGVC_ALERTVIEW_UPDATE_SUCCESS_TAG      1001