//
//  VoteActivityDetailsTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-6-27.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface VoteActivityDetailsTableViewController : UITableViewController

@property (strong, nonatomic) NSNumber *voteId;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *endTime;
@property (nonatomic, strong) NSOperationQueue *imagesDownloadQueue;

@end

#define ADTVC_CELL_ABOVE_OPTIONS_LIST          5

//主题cell
#define ADTVC_SUBJECT_TAG                      1010
#define ADTVC_SUBJECT_TITLE_TAG                1011
//描述cell
#define ADTVC_DESCRIPTION_TAG                  1020
//参与人cell
#define ADTVC_PARTICIPANTS_TAG                 1030
#define ADTVC_PARTICIPANTS_BTN_TAG             1031
//最大可选cell
#define ADTVC_MAX_CHOICE_TAG                   1040
#define ADTVC_MAX_CHOICE_SEGMENT_TAG           1041
#define ADTVC_MAX_CHOICE_SEGMENT_TITLE_TAG     1042
#define ADTVC_MAX_CHOICE_TITLE_TAG             1043
#define ADTVC_MAX_CHOICE_TAIL_TAG              1044
//截止时间cell
#define ADTVC_DEADLINE_TAG                     1050
//选项cell
#define ADTVC_OPTIONS_TITLE_TAG                1060
#define ADTVC_OPTIONS_VOTE_BAR_TAG             1061
#define ADTVC_OPTIONS_VOTE_PERCENT_TAG         1062
//分割线
#define ADTVC_SEPARATOR_TAG                    1070


#define ADTVC_PARTICIPANTS_BTN_X               140.0
#define ADTVC_PARTICIPANTS_BTN_Y               5.0
#define ADTVC_PARTICIPANTS_BTN_WIDTH           70.0
#define ADTVC_PARTICIPANTS_BTN_HEIGHT          30.0

#define ADTVC_OPTIONS_TITLE_X                  10.0
#define ADTVC_OPTIONS_TITLE_Y                  10.0
//#define ADTVC_OPTIONS_TITLE_WIDTH              310.0
//#define ADTVC_OPTIONS_TITLE_HEIGHT             20.0
#define ADTVC_OPTIONS_TITLE_FONT               @"ChalkboardSE-Regular"
#define ADTVC_OPTIONS_TITLE_FONT_SIZE          13.0

#define ADTVC_OPTIONS_ADDR_X                   10.0
#define ADTVC_OPTIONS_ADDR_FONT               @"ChalkboardSE-Regular"
#define ADTVC_OPTIONS_ADDR_FONT_SIZE          13.0

#define ADTVC_OPTIONS_VOTE_BAR_X               10.0
//#define ADTVC_OPTIONS_VOTE_BAR_Y               40.0  //ADTVC_OPTIONS_TITLE_Y + ADTVC_OPTIONS_TITLE_HEIGHT + 10
#define ADTVC_OPTIONS_VOTE_BAR_WIDTH           290.0
#define ADTVC_OPTIONS_VOTE_BAR_HEIGHT          20.0

#define ADTVC_OPTIONS_VOTE_PERCENT_X           250.0 //ADTVC_OPTIONS_VOTE_BAR_X + ADTVC_OPTIONS_VOTE_BAR_WIDTH + 5
#define ADTVC_OPTIONS_VOTE_PERCENT_Y           40.0  //ADTVC_OPTIONS_TITLE_Y + ADTVC_OPTIONS_TITLE_HEIGHT + 10
#define ADTVC_OPTIONS_VOTE_PERCENT_WIDTH       60.0
#define ADTVC_OPTIONS_VOTE_PERCENT_HEIGHT      20.0
#define ADTVC_OPTIONS_VOTE_PERCENT_FONT        @"ChalkboardSE-Regular"
#define ADTVC_OPTIONS_VOTE_PERCENT_FONT_SIZE   13.0



