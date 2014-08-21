//
//  VoteOptionDetailsTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-8-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteOptionDetailsTableViewController : UITableViewController

@property (strong, nonatomic) NSNumber *businessID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;

@end

#define ODTVC_NAME_TAG                       1001
#define ODTVC_CUSTOM_ADDR_TAG                1002

#define ODTVC_NAME_COORDINATE_X              10
#define ODTVC_NAME_COORDINATE_Y              10
#define ODTVC_NAME_WIDTH                     ([UIScreen mainScreen].bounds.size.width - 20)
//#define ODTVC_NAME_FONT                      1
#define ODTVC_NAME_FONT_SIZE                 18.0

#define ODTVC_CUSTOM_ADDR_COORDINATE_X       10
#define ODTVC_CUSTOM_ADDR_COORDINATE_Y       10
#define ODTVC_CUSTOM_ADDR_WIDTH              ([UIScreen mainScreen].bounds.size.width - 20)
//#define ODTVC_CUSTOM_ADDR_FONT               10
#define ODTVC_CUSTOM_ADDR_FONT_SIZE          15.0
