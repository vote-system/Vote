//
//  VoteChooseOptionsTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-7-7.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface VoteChooseOptionsTableViewController : UITableViewController

@property (strong, nonatomic) NSNumber *voteId;

@end

#define COTVC_ALERTVIEW_PUBLISH_SUCCESS_TAG  1000


#define COTVC_SWITCH_NOTIFICATION_TAG        1001
#define COTVC_SWITCH_DELETE_FOREVER_TAG      1002