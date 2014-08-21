//
//  VoteSecondTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-3-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface VoteSecondTableViewController : UITableViewController

@property (nonatomic, strong) NSOperationQueue *headImagesDownloadQueue;

@end


#define SECOND_SECTION_ABOVE_FRIENDS  1


#define SECOND_SEPARATOR_TAG          1005
