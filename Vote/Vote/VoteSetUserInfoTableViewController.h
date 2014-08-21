//
//  VoteSetUserInfoTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-7-17.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface VoteSetUserInfoTableViewController : UITableViewController

@property (nonatomic, strong) NSOperationQueue *headImagesDownloadQueue;

@end

#define SUITVC_HEAD_IMG_TAG            1001
#define SUITVC_SCREEN_NAME_TAG         1002
#define SUITVC_GENDER_TAG              1003
#define SUITVC_SIGNATURE_TAG           1004