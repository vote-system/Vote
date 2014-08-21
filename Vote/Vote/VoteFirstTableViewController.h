//
//  VoteFirstTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-3-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface VoteFirstTableViewController : UITableViewController
{
    BOOL authenticated;
}

@property (nonatomic, strong) NSOperationQueue *imagesDownloadQueue;

@end

#define FIRST_CELL_ANONYMOUS_FONT          @"ChalkboardSE-Light"
#define FIRST_CELL_ANONYMOUS_FONT_SIZE     15.0

#define FIRST_CELL_TITLE_FONT              @"ChalkboardSE-Light"
#define FIRST_CELL_TITLE_FONT_SIZE         15.0

#define FIRST_CELL_TIMER_FONT              @"ChalkboardSE-Regular"
#define FIRST_CELL_TIMER_FONT_SIZE         13.0

#define FIRST_CELL_ORGANIZER_FONT          @"ChalkboardSE-Light"
#define FIRST_CELL_ORGANIZER_FONT_SIZE     13.0

#define FIRST_CELL_CTGRY_FONT              @"ChalkboardSE-Light"
#define FIRST_CELL_CTGRY_FONT_SIZE         15.0
