//
//  VoteCountDownTimerTableViewCell.m
//  Vote
//
//  Created by 丁 一 on 14-6-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteCountDownTimerTableViewCell.h"

@interface VoteCountDownTimerTableViewCell ()

@property (strong, nonatomic) UIView *separator;

@end

@implementation VoteCountDownTimerTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    CGRect rect;
    if (!self.ctgryImageView) {
        rect = CGRectMake(COUNTDOWN_CELL_IMG_VIEW_X, COUNTDOWN_CELL_IMG_VIEW_Y, COUNTDOWN_CELL_IMG_VIEW_WIDTH, COUNTDOWN_CELL_IMG_VIEW_HEIGHT);
        self.ctgryImageView = [[UIImageView alloc] initWithFrame:rect];
        [self.contentView addSubview:self.ctgryImageView];
    }
    if (!self.anonymousLabel) {
        rect = CGRectMake(COUNTDOWN_CELL_ANONYMOUS_X, COUNTDOWN_CELL_ANONYMOUS_Y, COUNTDOWN_CELL_ANONYMOUS_WIDTH, COUNTDOWN_CELL_ANONYMOUS_HEIGHT);
        self.anonymousLabel = [[UILabel alloc] initWithFrame:rect];
        //self.anonymousLabel.layer.borderWidth = 1.0;
        //self.anonymousLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        self.anonymousLabel.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:self.anonymousLabel];
    }
    if (!self.titleLabel) {
        rect = CGRectMake(COUNTDOWN_CELL_TITLE_X, COUNTDOWN_CELL_TITLE_Y, COUNTDOWN_CELL_TITLE_WIDTH, COUNTDOWN_CELL_TITLE_HEIGHT);
        self.titleLabel = [[UILabel alloc] initWithFrame:rect];
        //self.titleLabel.layer.borderWidth = 1.0;
        //self.titleLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.contentView addSubview:self.titleLabel];
    }
    if (!self.timerLabel) {
        rect = CGRectMake(COUNTDOWN_CELL_TIMER_X, COUNTDOWN_CELL_TIMER_Y, COUNTDOWN_CELL_TIMER_WIDTH, COUNTDOWN_CELL_TIMER_HEIGHT);
        self.timerLabel = [[UILabel alloc] initWithFrame:rect];
        //self.timerLabel.layer.borderWidth = 1.0;
        //self.timerLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.contentView addSubview:self.timerLabel];
    }
    if (!self.organizerLabel) {
        rect = CGRectMake(COUNTDOWN_CELL_ORGANIZER_X, COUNTDOWN_CELL_ORGANIZER_Y, COUNTDOWN_CELL_ORGANIZER_WIDTH, COUNTDOWN_CELL_ORGANIZER_HEIGHT);
        self.organizerLabel = [[UILabel alloc] initWithFrame:rect];
        //self.organizerLabel.layer.borderWidth = 1.0;
        //self.organizerLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.contentView addSubview:self.organizerLabel];
    }
    if (!self.ctgryLabel) {
        //rect = CGRectMake(COUNTDOWN_CELL_CTGRY_X, COUNTDOWN_CELL_CTGRY_Y, COUNTDOWN_CELL_CTGRY_WIDTH, COUNTDOWN_CELL_CTGRY_HEIGHT);
        //self.ctgryLabel = [[UILabel alloc] initWithFrame:rect];
        //self.ctgryLabel.layer.borderWidth = 1.0;
        //self.ctgryLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        //[self.contentView addSubview:self.ctgryLabel];
    }
    if (!self.separator) {
        rect = CGRectMake(0.0, 69.5, 320.0, 0.5);
        self.separator = [[UIView alloc] initWithFrame:rect];
        self.separator.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.separator];
    }

}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setCategory:(NSString *)category
{
    _category = category;
    self.ctgryLabel.text = category;
    self.ctgryImageView.image = [UIImage imageNamed:@"sports.png"];
}

- (void)setAnonymous:(NSNumber *)anonymous
{
    _anonymous = anonymous;
    if ([anonymous boolValue] == YES) {
        self.anonymousLabel.text = @"匿";
    } else {
        self.anonymousLabel.text = @"公";
    }
}

- (void)setThePublic:(NSNumber *)thePublic
{
    _thePublic = thePublic;
    if ([thePublic boolValue] == YES) {
        self.anonymousLabel.text = @"众";
    }
}

- (void)setOrganizer:(NSString *)organizer
{
    _organizer = organizer;
    self.organizerLabel.text = organizer;
}

- (void)startTimer
{
    // invalidate a previous timer in case of reuse
    if (self.timer)
        [self.timer invalidate];
    
    NSDate *now = [NSDate date];
    if ([self.endTime earlierDate:now] == self.endTime) {
        self.timerLabel.text = @"已结束";
        if (self.voteExpireCallBack) {
            self.voteExpireCallBack();
        }
        return;
    }
    
    // create a new timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.timer fire];
}


- (void)updateCounter
{
    //NSString *str =@"12/28/2014";
    //NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //[formatter setDateFormat:@"MM/dd/yyyy"];
    //self.endTime = [formatter dateFromString:str];
    NSDate *now = [NSDate date];
    //NSLog(@"now = %@, endDate = %@", now, self.endTime);
    // has the target time passed?
    if ([self.endTime earlierDate:now] == self.endTime) {
        [self.timer invalidate];
        self.timerLabel.text = @"已结束";
        if (self.voteExpireCallBack) {
            self.voteExpireCallBack();
        }
    } else {
        NSUInteger flags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:flags fromDate:now toDate:self.endTime options:0];
        
        //NSLog(@"there are %ld days, %ld hours, %ld minutes and %ld seconds remaining", (long)[components day], (long)[components hour], (long)[components minute], (long)[components second]);
        if (components.day > 0) {
            self.timerLabel.text = [NSString stringWithFormat:@"还剩%ld天", (long)[components day]];
        } else if (components.hour > 0 || components.minute > 0) {
            NSString *timerString = [NSString stringWithFormat:@"还剩%02ld:%02ld", (long)[components hour], (long)[components minute]];
            
            self.timerLabel.text = [NSString stringWithFormat:@"%@", timerString];
        } else {
            NSString *timerString = [NSString stringWithFormat:@"还剩%02ld秒", (long)[components second]];
            
            self.timerLabel.text = [NSString stringWithFormat:@"%@", timerString];
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
