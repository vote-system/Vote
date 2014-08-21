//
//  VoteFriendsReqListTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-4-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface VoteFriendsReqListTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *friendReqInfo;

@end


#define FRTVC_CELL_SEPARATOR_TAG     1001