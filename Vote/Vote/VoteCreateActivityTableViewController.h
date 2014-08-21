//
//  VoteCreateActivityTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-6-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "VoteBusinessDetailsTableViewController.h"
#import "VoteAddParticipantsTableViewController.h"
#import "VoteAddOptionsTableViewController.h"

@interface VoteCreateActivityTableViewController : UITableViewController <AddOptionsDelegate, AddParticipantsDelegate>

@property (nonatomic, strong) NSOperationQueue *imagesDownloadQueue;
@property (strong, nonatomic) UITextField *subject;
@property (strong, nonatomic) UITextField *deadline;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSMutableArray *optionsList;
@property (strong, nonatomic) NSMutableArray *participants;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSNumber *anonymous;
@property (strong, nonatomic) NSNumber *thePublic;
@property (strong, nonatomic) UITextField *maxChoice;
@property (strong, nonatomic) UIPickerView *maxChoicePicker;
@property (strong, nonatomic) UITextView *description;
@property (strong, nonatomic) UILabel *wordsPrompt;
@property (strong, nonatomic) NSMutableDictionary *imageAttr;

@end

#define CATVC_CREATE_RESP_STATUS               @"setup_vote"
#define CATVC_CREATE_RESP_SUCCESS              0
#define CATVC_CREATE_RESP_FAILURE              1
#define CATVC_CREATE_RESP_REPEAT               2

//table view identifier
#define CATVC_VIEW_ID_CUSTOM                   @"custom"
#define CATVC_VIEW_ID_SELECT_PLACE             @"select_place"

//section number
#define CATVC_TABLEVIEW_SECTION_NUM            6
#define CATVC_CELL_ABOVE_OPTIONS_LIST          1

//主题cell
#define CATVC_SUBJECT_TAG                      1010
#define CATVC_SUBJECT_TITLE_TAG                1011
//活动描述
#define CATVC_DESCRIPTION_TEXTVIEW_TAG         1020
#define CATVC_DESCRIPTION_LABEL_TAG            1021
//活动配图cell
#define CATVC_IMAGE_TAG                        1030
//截止时间cell
#define CATVC_DEADLINE_TAG                     1040
//添加好友cell
#define CATVC_ADD_PARTICIPANTS_TAG             1040
#define CATVC_ADD_PARTICIPANTS_BUTTON_TAG      1041
//公众私人cell
#define CATVC_PUBLIC_TITLE_TAG                 1050
#define CATVC_PUBLIC_SEGMENT_TAG               1051
//公开匿名cell
#define CATVC_ANONYMOUS_TITLE_TAG              1060
#define CATVC_ANONYMOUS_SEGMENT_TAG            1061
//最大可选cell
#define CATVC_MAX_CHOICE_TAG                   1070
#define CATVC_MAX_CHOICE_TITLE_TAG             1071
#define CATVC_MAX_CHOICE_TAIL_TAG              1072
//选项cell
#define CATVC_OPTIONS_TAG                      1080
#define CATVC_OPTIONS_TITLE_TAG                1081
#define CATVC_OPTIONS_BUTTON_TAG               1082
//分割线
#define CATVC_SEPARATOR_TAG                    1090

//CATVC means Create Activity Table View Controller
#define CATVC_PHOTO_TAG                        2001
#define CATVC_BUSINESS_NAME_TAG                2002
#define CATVC_RATING_IMAGE_TAG                 2003
#define CATVC_AVG_PRICE_TAG                    2004
#define CATVC_RGN_CTGRY_TAG                    2005
#define CATVC_DISTANCE_TAG                     2006
#define CATVC_SORT_NUMBER_TAG                  2007


#define CATVC_SORT_NUMBER_COORDINATE_X         15
#define CATVC_SORT_NUMBER_COORDINATE_Y         10
#define CATVC_SORT_NUMBER_WIDTH                20
#define CATVC_SORT_NUMBER_HEIGHT               (cell.frame.size.height - 20)
#define CATVC_SORT_NUMBER_FONT                 @"Verdana"
#define CATVC_SORT_NUMBER_FONT_SIZE            20

#define CATVC_OPTION_NAME_COORDINATE_X         45  //CATVC_SORT_NUMBER_COORDINATE_X + CATVC_SORT_NUMBER_WIDTH + 10
#define CATVC_OPTION_NAME_COORDINATE_Y         10
#define CATVC_OPTION_NAME_WIDTH                260
#define CATVC_OPTION_NAME_HEIGHT
#define CATVC_OPTION_NAME_FONT
#define CATVC_OPTION_NAME_FONT_SIZE

#define CATVC_OPTION_ADDR_COORDINATE_X         45  //CATVC_SORT_NUMBER_COORDINATE_X + CATVC_SORT_NUMBER_WIDTH + 10
#define CATVC_OPTION_ADDR_COORDINATE_Y         
#define CATVC_OPTION_ADDR_WIDTH                260.0
#define CATVC_OPTION_ADDR_HEIGHT
#define CATVC_OPTION_ADDR_FONT
#define CATVC_OPTION_ADDR_FONT_SIZE

/*
#define CATVC_PHOTO_COORDINATE_X               40   //SORT_NUMBER_COORDINATE_X + SORT_NUMBER_WIDTH + 10
#define CATVC_PHOTO_COORDINATE_Y               10
#define CATVC_PHOTO_WIDTH                      100
#define CATVC_PHOTO_HEIGHT                     87

#define CATVC_BUSINESS_NAME_COORDINATE_X       150  //PHOTO_COORDINATE_X + PHOTO_WIDTH + 10
#define CATVC_BUSINESS_NAME_COORDINATE_Y       10
#define CATVC_BUSINESS_NAME_WIDTH              160  //SCREEN_WIDTH - 10 - BUSINESS_NAME_COORDINATE_X
#define CATVC_BUSINESS_NAME_HEIGHT             40
#define CATVC_BUSINESS_NAME_FONT               @"Verdana"
#define CATVC_BUSINESS_NAME_FONT_SIZE          15

#define CATVC_RATING_IMAGE_COORDINATE_X        150  //PHOTO_COORDINATE_X + PHOTO_WIDTH + 10
#define CATVC_RATING_IMAGE_COORDINATE_Y        60   //BUSINESS_NAME_COORDINATE_Y + BUSINESS_NAME_HEIGHT + 10
#define CATVC_RATING_IMAGE_WIDTH               60
#define CATVC_RATING_IMAGE_HEIGHT              15

#define CATVC_AVG_PRICE_COORDINATE_X           220  //RATING_IMAGE_COORDINATE_X + RATING_IMAGE_WIDTH + 10
#define CATVC_AVG_PRICE_COORDINATE_Y           60   //RATING_IMAGE_COORDINATE_Y
#define CATVC_AVG_PRICE_WIDTH                  90
#define CATVC_AVG_PRICE_HEIGHT                 15
#define CATVC_AVG_PRICE_FONT                   @"Verdana"
#define CATVC_AVG_PRICE_FONT_SIZE              13

//region and category label
#define CATVC_RGN_CTGRY_COORDINATE_X           150
#define CATVC_RGN_CTGRY_COORDINATE_Y           85   //RATING_IMAGE_COORDINATE_Y + RATING_IMAGE_HEIGHT + 10
#define CATVC_RGN_CTGRY_WIDTH                  160
#define CATVC_RGN_CTGRY_HEIGHT                 12
#define CATVC_RGN_CTGRY_FONT                   @"Verdana"
#define CATVC_RGN_CTGRY_FONT_SIZE              12

#define OPTIONS_CELL_HEIGHT                    107.0 //RGN_CTGRY_COORDINATE_Y + RGN_CTGRY_HEIGHT + 10

*/

#define CATVC_ALERTVIEW_PUBLISH_SUCCESS_TAG    3001
