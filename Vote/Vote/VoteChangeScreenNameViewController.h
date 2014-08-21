//
//  VoteChangeScreenNameViewController.h
//  Vote
//
//  Created by 丁 一 on 14-3-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^theNewScreenName)(NSString *screenname);

@interface VoteChangeScreenNameViewController : UIViewController

@property (copy, nonatomic) theNewScreenName theNewScreenNameCallBack;

@end

#define CSNVC_ALERTVIEW_UPDATE_SUCCESS_TAG           1001