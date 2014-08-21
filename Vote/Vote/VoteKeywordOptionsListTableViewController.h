//
//  VoteKeywordOptionsListTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-8-18.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface VoteKeywordOptionsListTableViewController : UITableViewController 

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *keyword;

@end

#define KOLTVC_LOADING_VIEW_TAG             1003
#define KOLTVC_ACTIVITY_INDICATOR_TAG       1004