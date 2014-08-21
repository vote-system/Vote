//
//  VoteAddActivityImageTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-8-11.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActivityImgName)(NSDictionary *imageAttr);

@interface VoteAddActivityImageTableViewController : UITableViewController

@property (copy, nonatomic) ActivityImgName activityImgName;

@end
