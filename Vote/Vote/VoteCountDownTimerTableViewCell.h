//
//  VoteCountDownTimerTableViewCell.h
//  Vote
//
//  Created by 丁 一 on 14-6-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VoteExpire)(void);

@interface VoteCountDownTimerTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *ctgryImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *ctgryLabel;
@property (strong, nonatomic) UILabel *anonymousLabel;
@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UILabel *organizerLabel;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSNumber *anonymous;
@property (strong, nonatomic) NSNumber *thePublic;
@property (strong, nonatomic) NSString *organizer;

@property (copy, nonatomic) VoteExpire voteExpireCallBack;

- (void)startTimer;
@end

#define COUNTDOWN_CELL_IMG_VIEW_X              10.0
#define COUNTDOWN_CELL_IMG_VIEW_Y              10.0
#define COUNTDOWN_CELL_IMG_VIEW_WIDTH          50.0
#define COUNTDOWN_CELL_IMG_VIEW_HEIGHT         50.0

#define COUNTDOWN_CELL_ANONYMOUS_X             70.0  //COUNTDOWN_CELL_IMG_VIEW_X + COUNTDOWN_CELL_IMG_VIEW_WIDTH + 10
#define COUNTDOWN_CELL_ANONYMOUS_Y             10.0  //COUNTDOWN_CELL_IMG_VIEW_Y
#define COUNTDOWN_CELL_ANONYMOUS_WIDTH         20.0
#define COUNTDOWN_CELL_ANONYMOUS_HEIGHT        20.0

#define COUNTDOWN_CELL_TITLE_X                 95.0  //COUNTDOWN_CELL_ANONYMOUS_X + COUNTDOWN_CELL_ANONYMOUS_WIDTH + 5
#define COUNTDOWN_CELL_TITLE_Y                 10.0
#define COUNTDOWN_CELL_TITLE_WIDTH             140.0
#define COUNTDOWN_CELL_TITLE_HEIGHT            20.0

#define COUNTDOWN_CELL_TIMER_X                 245.0
#define COUNTDOWN_CELL_TIMER_Y                 10.0
#define COUNTDOWN_CELL_TIMER_WIDTH             65.0
#define COUNTDOWN_CELL_TIMER_HEIGHT            20.0

#define COUNTDOWN_CELL_ORGANIZER_X             70.0  //COUNTDOWN_CELL_ANONYMOUS_X
#define COUNTDOWN_CELL_ORGANIZER_Y             40.0  //COUNTDOWN_CELL_TITLE_Y + COUNTDOWN_CELL_ANONYMOUS_HEIGHT + 10
#define COUNTDOWN_CELL_ORGANIZER_WIDTH         240.0
#define COUNTDOWN_CELL_ORGANIZER_HEIGHT        20.0

#define COUNTDOWN_CELL_CTGRY_X                 250.0  //COUNTDOWN_CELL_ANONYMOUS_X
#define COUNTDOWN_CELL_CTGRY_Y                 40.0  //COUNTDOWN_CELL_TITLE_Y + COUNTDOWN_CELL_TITLE_HEIGHT + 10
#define COUNTDOWN_CELL_CTGRY_WIDTH             60.0
#define COUNTDOWN_CELL_CTGRY_HEIGHT            20.0


