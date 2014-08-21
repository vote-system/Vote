//
//  VoteCreateActivityTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-6-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteCreateActivityTableViewController.h"
#include "VoteDefaultOptionsListViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "DianPingAPI.h"
#import "VotesInfo+VotesInfoHelper.h"
#import "CoreDataHelper.h"
#import "VoteFirstTableViewController.h"
#import "Users+UsersHelper.h"
#import "Friends+FriendsHelper.h"
#import "UIImage+UIImageHelper.h"
#import "NSString+NSStringHelper.h"
#import "VoteAddActivityImageTableViewController.h"


@interface VoteCreateActivityTableViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITextViewDelegate>
{
    NSArray *pickerArray;
    NSMutableArray *sectionTitles;
    NSString *viewIdentifier;
    NSArray *sortArray;
}
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *activityImgName;

@end

@implementation VoteCreateActivityTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    viewIdentifier = CATVC_VIEW_ID_CUSTOM;
    sectionTitles = [[NSMutableArray alloc] initWithObjects:@"活动主题", @"活动描述", @"活动配图", @"截止时间", @"添加好友", @"公众，匿名，多选设置", @"候选列表", nil];
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        //create nsfetchresultcontroller...
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
    }];
    self.optionsList = [[NSMutableArray alloc] initWithCapacity:6];
    self.participants = [[NSMutableArray alloc] initWithCapacity:10];
    self.imageAttr = [[NSMutableDictionary alloc] initWithCapacity:2];
    self.startDate = [NSDate date];
    //默认公开
    self.anonymous = [NSNumber numberWithBool:NO];
    pickerArray = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", nil];
    sortArray = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] init];
    [longPressGR addTarget:self action:@selector(handleLongPress:)];
    [longPressGR setMinimumPressDuration:1.0f];
    [longPressGR setAllowableMovement:20.0];
    [self.tableView addGestureRecognizer:longPressGR];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

- (IBAction)publish:(id)sender {
    
    if ([NSString checkWhitespaceAndNewlineCharacter:self.subject.text] == YES) {
        NSString *title = @"活动创建失败";
        NSString *msg = @"标题不可为空";
        NSString *btnTitle = @"确定";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:btnTitle otherButtonTitles:nil];
        [av show];
        return;
    }
    if ([NSString checkWhitespaceAndNewlineCharacter:self.description.text] == YES) {
        NSString *title = @"活动创建失败";
        NSString *msg = @"描述不可为空";
        NSString *btnTitle = @"确定";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:btnTitle otherButtonTitles:nil];
        [av show];
        return;
    }
    if ([NSString checkWhitespaceAndNewlineCharacter:self.deadline.text] == YES) {
        NSString *title = @"活动创建失败";
        NSString *msg = @"截止时间不可为空";
        NSString *btnTitle = @"确定";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:btnTitle otherButtonTitles:nil];
        [av show];
        return;
    }
    if ([self.participants  count] < 1) {
        NSString *title = @"活动创建失败";
        NSString *msg = @"参与者不可为空";
        NSString *btnTitle = @"确定";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:btnTitle otherButtonTitles:nil];
        [av show];
        return;
    }
    if ([self.optionsList  count] < 1) {
        NSString *title = @"活动创建失败";
        NSString *msg = @"候选项目不可为空";
        NSString *btnTitle = @"确定";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:btnTitle otherButtonTitles:nil];
        [av show];
        return;
    }
    [self publishTheVote];
}

- (void)publishTheVote
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *organizer = username;
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/setup_vote.php"];
    NSLog(@"start date: %@", self.startDate);
    NSLog(@"end date: %@", self.endDate);
    //开始结束时间
    NSTimeInterval dStartTime = [self.startDate timeIntervalSince1970];
    NSTimeInterval dEndTime = [self.endDate timeIntervalSince1970];
    NSNumber *startTime = [NSNumber numberWithDouble:dStartTime];
    NSNumber *endTime = [NSNumber numberWithDouble:dEndTime];
    //long long lStartTime = [[NSNumber numberWithDouble:dStartTime] longLongValue];
    //添加投票人
    /*
    NSMutableArray *participants = [[NSMutableArray alloc] init];
    for (NSDictionary *elem in self.participants) {
        [participants addObject:[elem objectForKey:USERNAME]];
    }
     */
    //将choice的NSString转化为NSNumber
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *choice = [format numberFromString:self.maxChoice.text];
    //创建选项列表
    NSMutableArray *options = [self createOptions];
    NSDictionary *voteInfo = @{SERVER_VOTE_ORGANIZER:organizer, SERVER_VOTE_TITLE:self.subject.text, SERVER_VOTE_DESCRIPTION:self.description.text, SERVER_VOTE_START_TIME:startTime, SERVER_VOTE_END_TIME:endTime, VOTE_PARTICIPANTS:self.participants, SERVER_VOTE_ANONYMOUS_FLAG:self.anonymous,SERVER_VOTE_MAX_CHOICE:choice, SERVER_VOTE_OPTIONS:options};
    
    NSDictionary *para = @{SERVER_USERNAME: username, SERVER_VOTE_INFO:voteInfo};
    NSLog(@"URL para = %@", para);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"operation: %@", operation);
        NSLog(@"responseString: %@", operation.responseString);
        NSLog(@"responseObject: %@", responseObject);
        if ([[responseObject objectForKey:CATVC_CREATE_RESP_STATUS] intValue] == CATVC_CREATE_RESP_SUCCESS) {
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:voteInfo];
            if ( (NSNull *)[responseObject objectForKey:SERVER_VOTE_ID] != [NSNull null]) {
                [data setObject:[responseObject objectForKey:SERVER_VOTE_ID] forKey:SERVER_VOTE_ID];
            } else {
                return;
            }
            if ( (NSNull *)[responseObject objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != [NSNull null]) {
                [data setObject:[responseObject objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] forKey:SERVER_VOTE_BASIC_TIMESTAMP];
            }
            if ( (NSNull *)[responseObject objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != [NSNull null]) {
                [data setObject:[responseObject objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] forKey:SERVER_VOTE_VOTE_TIMESTAMP];
            }
            NSLog(@"DATA:%@", data);
            [VotesInfo insertVotesInfoToDatabaseWithDetails:data withManagedObjectContext:self.managedObjectContext withQueue:self.imagesDownloadQueue];
            UIAlertView *alert = nil;
            alert = [[UIAlertView alloc] initWithTitle:@"发布成功"
                                               message:nil
                                              delegate:self
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil];
            alert.tag = CATVC_ALERTVIEW_PUBLISH_SUCCESS_TAG;
            [alert show];
            } else {
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"发布失败"
                                           message:@"网络连接失败或服务器错误，请稍后再试"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }];
}

- (NSMutableArray *)createOptions
{
    NSMutableArray *options = [[NSMutableArray alloc] initWithCapacity:6];
    for (NSUInteger i = 0; i < [self.optionsList count]; i++) {
        NSDictionary *element = [self.optionsList objectAtIndex:i];
        NSMutableDictionary *aOption = [[NSMutableDictionary alloc] initWithCapacity:[self.optionsList count]];
        NSLog(@"elements:%@", element);
        if ((NSNull *)[element objectForKey:SERVER_OPTIONS_NAME] != [NSNull null]) {
            NSNumber *businessID = [element objectForKey:SERVER_OPTIONS_NAME];
            [aOption setObject:businessID forKey:SERVER_OPTIONS_NAME];
        } else {
            [aOption setObject:[NSNull null] forKey:SERVER_OPTIONS_NAME];
        }
        if ((NSNull *)[element objectForKey:SERVER_OPTIONS_ADDRESS] != [NSNull null]) {
            NSString *address = [element objectForKey:SERVER_OPTIONS_ADDRESS];
            [aOption setObject:address forKey:SERVER_OPTIONS_ADDRESS];
        } else {
            [aOption setObject:[NSNull null] forKey:SERVER_OPTIONS_ADDRESS];
        }
        if ((NSNull *)[element objectForKey:SERVER_OPTIONS_BUSINESS_ID] != [NSNull null]) {
            NSString *ratingImgURL = [element objectForKey:SERVER_OPTIONS_BUSINESS_ID];
            [aOption setObject:ratingImgURL forKey:SERVER_OPTIONS_BUSINESS_ID];
        } else {
            [aOption setObject:[NSNull null] forKey:SERVER_OPTIONS_BUSINESS_ID];
        }
        if ((NSNull *)[element objectForKey:SERVER_OPTIONS_CATEGORY] != [NSNull null]) {
            NSString *avgPrice = [element objectForKey:SERVER_OPTIONS_CATEGORY];
            [aOption setObject:avgPrice forKey:SERVER_OPTIONS_CATEGORY];
        } else {
            [aOption setObject:[NSNull null] forKey:SERVER_OPTIONS_CATEGORY];
        }
        NSString *order = [sortArray objectAtIndex:i];
        [aOption setObject:order forKey:SERVER_OPTIONS_ORDER];

        [options addObject:aOption];
    }
    
    return options;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section < 5) {
        return 1;
    } else if (section == 5) {
        return 3;
    } else {
        if ([self.optionsList count] == 0) {
            return 1;
        } else {
            return [self.optionsList count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0;
    }
    return 25.0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [sectionTitles objectAtIndex:section];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 25.0)];
    //uv.layer.borderWidth = 1.0;
    //uv.layer.borderColor = [[UIColor blackColor] CGColor];
    uv.backgroundColor = UIColorFromRGB(0xEFEFF4);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 270, 15.0)];
    if (section == 0) {
        title.frame = CGRectMake(15.0, 10, 270, 15.0);
    }
    title.backgroundColor = [UIColor clearColor];
    title.text = [sectionTitles objectAtIndex:section];
    title.textColor = UIColorFromRGB(0x4C566C);
    title.font = [UIFont systemFontOfSize:14.0];
    //title.layer.borderWidth = 1.0;
    //title.layer.borderColor = [[UIColor blackColor] CGColor];
    [uv addSubview:title];
    if (section == 4) {
        UIButton *addParticipantsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addParticipantsButton.frame = CGRectMake(280.0, -2.5, 20.0, 20.0);
        addParticipantsButton.tag = CATVC_ADD_PARTICIPANTS_BUTTON_TAG;
        UIImage *image = [UIImage imageNamed:@"voteAddParticipants@2x.png"];
        CGSize size = CGSizeMake(20, 20);
        //[addParticipantsButton setBackgroundImage:[UIImage imageWithImage:image scaledToSize:size] forState:UIControlStateNormal];
        [addParticipantsButton setImage:[UIImage imageWithImage:image scaledToSize:size] forState:UIControlStateNormal];
        //addParticipantsButton.tintColor = [UIColor orangeColor];
        addParticipantsButton.backgroundColor = UIColorFromRGB(0xEFEFF4);
        //[addButton.layer setMasksToBounds:YES];
        //[addButton.layer setCornerRadius:4.0];
        [addParticipantsButton addTarget:self action:@selector(addParticipantsOnButton:) forControlEvents:UIControlEventTouchUpInside];
        //[uv addSubview:addParticipantsButton];
    }
    if (section == 6) {
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addButton.frame = CGRectMake(270.0, -5.0, 30.0, 25.0);
        addButton.tag = CATVC_OPTIONS_BUTTON_TAG;
        //[addButton setTitle:@"添加" forState:UIControlStateNormal];
        addButton.tintColor = [UIColor orangeColor];
        addButton.backgroundColor = UIColorFromRGB(0xEFEFF4);
        [addButton.layer setMasksToBounds:YES];
        [addButton.layer setCornerRadius:4.0];
        [addButton addTarget:self action:@selector(addOptions:) forControlEvents:UIControlEventTouchUpInside];
        [uv addSubview:addButton];
    }
    return uv;
}

- (CGFloat)calculateCellHeightWithRow:(NSInteger)row
{
    //设置文字宽度
    CGFloat nameHeight = 0.0;
    CGFloat addressHeight = 0.0;
    
    CGFloat width = 260.0;
    NSDictionary *data = [self.optionsList objectAtIndex:row];
    NSString *name = [data objectForKey:SERVER_OPTIONS_NAME];
    UIFont *nameFont = [UIFont boldSystemFontOfSize:17.0];
    nameHeight = [NSString calculateTextHeight:name font:nameFont width:width];
    if ( (NSNull *)[data objectForKey:SERVER_OPTIONS_ADDRESS] != [NSNull null]) {
        NSString *address = [data objectForKey:SERVER_OPTIONS_ADDRESS];
        UIFont *addrFont = [UIFont systemFontOfSize:15.0];
        addressHeight = [NSString calculateTextHeight:address font:addrFont width:width];
    }

    CGFloat height = 10.0 + nameHeight + 10.0 + addressHeight + 10.0;
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //活动主题
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 50.0;
    }
    //活动描述
    else if (indexPath.section == 1 && indexPath.row == 0) {
        return 140.0;
    }
    //活动配图
    else if (indexPath.section == 2 && indexPath.row == 0) {
        return 50.0;
    }
    //截止时间
    else if (indexPath.section == 3 && indexPath.row == 0) {
        return 50.0;
    }
    //添加好友
    else if (indexPath.section == 4 && indexPath.row == 0) {
        CGFloat height = 50.0;
        if ([self.participants count] == 0) {
            return height;
        }
        //一行最多图片放置个数为6
        CGFloat maxNum = 6.0f;
        NSInteger count = [self.participants count];
        float num = ceilf((float)count/maxNum);
        NSLog(@"%f", num);
        //多行图片的情况
        CGFloat offset = height - 10.0;
        return (height + (num - 1)*offset);
    }
    //匿名，多选
    else if (indexPath.section == 5 && indexPath.row == 0) {
        return 50.0;
    } else if (indexPath.section == 5 && indexPath.row == 1) {
        return 50.0;
    }
    //候选列表
    else {
        if ([self.optionsList count] == 0) {
            return 50.0;
        } else {
            CGFloat height = [self calculateCellHeightWithRow:indexPath.row];
            return height;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Subject" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundColor = UIColorFromRGB(0xEFEFF4);
        if ([cell.contentView viewWithTag:CATVC_SUBJECT_TAG] == nil) {
            self.subject.tag = CATVC_SUBJECT_TAG;
            [cell.contentView addSubview:self.subject];
        }

    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];
        if ([cell.contentView viewWithTag:CATVC_DESCRIPTION_TEXTVIEW_TAG] == nil) {
            [cell.contentView addSubview:self.description];
        }
        if ([cell.contentView viewWithTag:CATVC_DESCRIPTION_LABEL_TAG] == nil) {
            [cell.contentView addSubview:self.wordsPrompt];
        }
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Activity Image" forIndexPath:indexPath];
        if ([self.imageAttr count] == 0) {
            cell.textLabel.text = @"点击添加活动配图";
            cell.textLabel.textColor = UIColorFromRGB(0xC7C7CD);
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = [self.imageAttr objectForKey:@"text"];
            cell.imageView.image = [UIImage imageNamed:[self.imageAttr objectForKey:@"name"]];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];

        
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Dead Line" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([cell.contentView viewWithTag:CATVC_DEADLINE_TAG] == nil) {
            self.deadline.tag = CATVC_DEADLINE_TAG;
            [cell.contentView addSubview:self.deadline];
        }
    } else if (indexPath.section == 4 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Participants" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 删除cell中的子对象,刷新覆盖问题。
        while ([cell.contentView.subviews lastObject])
        {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        if ([self.participants count] == 0) {
            CGFloat x = 15.0;
            CGFloat y = 10.0;
            CGFloat width = 30.0;
            CGFloat height = 30.0;
            UIImageView *imageView;
            UIImage *image = [UIImage imageNamed:@"voteAddParticipants.png"];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            imageView.image = image;
            [cell.contentView addSubview:imageView];
        } else {
            //好友列表
            NSInteger count = 1;
            CGFloat x = 15.0;
            CGFloat y = 10.0;
            CGFloat width = 30.0;
            CGFloat height = 30.0;
            UIImageView *imageView;
            for (NSDictionary *name in self.participants) {
                NSString *usrname = [name objectForKey:USERNAME];
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                NSLog(@"x=%f, y=%f", x, y);
                Friends *aFriend = [Friends fetchFriendsWithName:usrname withContext:self.managedObjectContext];
                UIImage *image = [UIImage imageWithContentsOfFile:aFriend.mediumHeadImagePath];
                CGSize size = CGSizeMake(30.0, 30.0);
                imageView.image = [UIImage imageWithImage:image scaledToSize:size];
                [cell.contentView addSubview:imageView];
                x = x + width + 22.0;
                if (count%6 == 0) {
                    y = y + 40.0;
                }
                count++;
            }
            UIImage *image = [UIImage imageNamed:@"voteAddParticipants.png"];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            imageView.image = image;
            [cell.contentView addSubview:imageView];
        }
    } else if (indexPath.section == 5 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Setting" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        while ([cell.contentView.subviews lastObject] != nil) {
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 60.0, 30.0)];
        title.tag = CATVC_PUBLIC_TITLE_TAG;
        title.text = @"是否是公众投票";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:15.0];
        [cell.contentView addSubview:title];
        
        NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"公众", @"私人", nil];
        UISegmentedControl *segmentCtrl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
        segmentCtrl.tag = CATVC_PUBLIC_SEGMENT_TAG;
        segmentCtrl.frame = CGRectMake(210.0, 10.0, 90.0, 30.0);
        segmentCtrl.tintColor = [UIColor orangeColor];
        [segmentCtrl addTarget:self action:@selector(segmentCtrlSelectedOnPulic:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:segmentCtrl];
        
        if ([cell.contentView viewWithTag:CATVC_SEPARATOR_TAG] == nil) {
            //添加cell间的分割线
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(15.0, 49.5, 305.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            v.tag = CATVC_SEPARATOR_TAG;
            [cell.contentView addSubview:v];
        }
    } else if (indexPath.section == 5 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Setting" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        while ([cell.contentView.subviews lastObject] != nil) {
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 60.0, 30.0)];
        title.text = @"是否匿名";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:15.0];
        title.tag = CATVC_ANONYMOUS_TITLE_TAG;
        [cell.contentView addSubview:title];
        
        NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"公开", @"匿名", nil];
        UISegmentedControl *segmentCtrl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
        segmentCtrl.tag = CATVC_ANONYMOUS_SEGMENT_TAG;
        segmentCtrl.frame = CGRectMake(210.0, 10.0, 90.0, 30.0);
        segmentCtrl.tintColor = [UIColor orangeColor];
        [segmentCtrl addTarget:self action:@selector(segmentCtrlSelectedOnAnonymous:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:segmentCtrl];

        if ([cell.contentView viewWithTag:CATVC_SEPARATOR_TAG] == nil) {
            //添加cell间的分割线
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(15.0, 49.5, 305.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            v.tag = CATVC_SEPARATOR_TAG;
            [cell.contentView addSubview:v];
        }
    } else if (indexPath.section == 5 && indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Setting" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        while ([cell.contentView.subviews lastObject] != nil) {
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 60.0, 30.0)];
        title.text = @"最多可选";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:15.0];
        title.tag = CATVC_MAX_CHOICE_TITLE_TAG;
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:self.maxChoice];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Details" forIndexPath:indexPath];
        if ([self.optionsList count] == 0) {
            cell.textLabel.text = @"添加候选选项";
            cell.textLabel.textColor = UIColorFromRGB(0xC7C7CD);
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            return cell;
        } else {
            cell.textLabel.text = @"";
        }
        // 删除cell中的子对象,刷新覆盖问题。
        while ([cell.contentView.subviews lastObject] != nil)
        {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        NSInteger i = indexPath.row;
        UILabel *sortNum;
        UILabel *nameLabel, *addrLabel;
        //UIImageView *photoView, *ratingImgView;
        CGRect rect;
        //候选序号
        rect = CGRectMake(CATVC_SORT_NUMBER_COORDINATE_X, CATVC_SORT_NUMBER_COORDINATE_Y, CATVC_SORT_NUMBER_WIDTH, CATVC_SORT_NUMBER_HEIGHT);
        sortNum = [[UILabel alloc] initWithFrame:rect];
        sortNum.font = [UIFont fontWithName:CATVC_SORT_NUMBER_FONT size:CATVC_SORT_NUMBER_FONT_SIZE];
        sortNum.text = [sortArray objectAtIndex:i];
        [cell.contentView addSubview:sortNum];
        //选项名称
        CGFloat width = 260.0;
        NSDictionary *data = [self.optionsList objectAtIndex:indexPath.row];
        NSString *name = [data objectForKey:SERVER_OPTIONS_NAME];
        UIFont *nameFont = [UIFont boldSystemFontOfSize:17.0];
        CGFloat nameHeight = [NSString calculateTextHeight:name font:nameFont width:width];
        rect = CGRectMake(CATVC_OPTION_NAME_COORDINATE_X, CATVC_OPTION_NAME_COORDINATE_Y, CATVC_OPTION_NAME_WIDTH, nameHeight);
        nameLabel = [[UILabel alloc] initWithFrame:rect];
        nameLabel.font = nameFont;
        nameLabel.text = name;
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.contentView addSubview:nameLabel];
        //选项地点
        if ( (NSNull *)[data objectForKey:SERVER_OPTIONS_ADDRESS] != [NSNull null]) {
            NSString *address = [data objectForKey:SERVER_OPTIONS_ADDRESS];
            UIFont *addrFont = [UIFont systemFontOfSize:15.0];
            CGFloat addressHeight = [NSString calculateTextHeight:address font:addrFont width:width];
            rect = CGRectMake(CATVC_OPTION_NAME_COORDINATE_X, nameLabel.frame.origin.y + nameLabel.frame.size.height + 10, CATVC_OPTION_NAME_WIDTH, addressHeight);
            addrLabel = [[UILabel alloc] initWithFrame:rect];
            addrLabel.font = addrFont;
            addrLabel.text = address;
            addrLabel.numberOfLines = 0;
            addrLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.contentView addSubview:addrLabel];
        }

        /*
        //商户图片
        if ([cell.contentView viewWithTag:CATVC_PHOTO_TAG] == nil) {
            rect = CGRectMake(CATVC_PHOTO_COORDINATE_X, CATVC_PHOTO_COORDINATE_Y, CATVC_PHOTO_WIDTH, CATVC_PHOTO_HEIGHT);
            photoView = [[UIImageView alloc] initWithFrame:rect];
            photoView.tag = CATVC_PHOTO_TAG;
            [cell.contentView addSubview:photoView];
        } else {
            photoView = (UIImageView *)[cell.contentView viewWithTag:CATVC_PHOTO_TAG];
        }
        NSString *url = [[self.optionsList objectAtIndex:i] objectForKey:DIANPING_S_PHOTO_URL];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        __weak UIImageView *tmpView = photoView;
        [photoView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            tmpView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        //商户名称
        if ([cell.contentView viewWithTag:CATVC_BUSINESS_NAME_TAG] == nil) {
            rect = CGRectMake(CATVC_BUSINESS_NAME_COORDINATE_X, CATVC_BUSINESS_NAME_COORDINATE_Y, CATVC_BUSINESS_NAME_WIDTH, CATVC_BUSINESS_NAME_HEIGHT);
            businessName = [[UILabel alloc] initWithFrame:rect];
            businessName.tag = CATVC_BUSINESS_NAME_TAG;
            businessName.numberOfLines = 0;
            businessName.lineBreakMode = NSLineBreakByWordWrapping;
            businessName.font = [UIFont fontWithName:CATVC_BUSINESS_NAME_FONT size:CATVC_BUSINESS_NAME_FONT_SIZE];
            [cell.contentView addSubview:businessName];
        } else {
            businessName = (UILabel *)[cell.contentView viewWithTag:CATVC_BUSINESS_NAME_TAG];
        }
        NSString *business = [[self.optionsList objectAtIndex:i] objectForKey:DIANPING_NAME];
        NSString *branchName = [[self.optionsList objectAtIndex:i] objectForKey:DIANPING_BRANCH_NAME];
        businessName.text = [business stringByAppendingFormat:@"(%@)", branchName];
        //商户评级图片
        if ([cell.contentView viewWithTag:CATVC_RATING_IMAGE_TAG] == nil) {
            rect = CGRectMake(CATVC_RATING_IMAGE_COORDINATE_X, CATVC_RATING_IMAGE_COORDINATE_Y, CATVC_RATING_IMAGE_WIDTH, CATVC_RATING_IMAGE_HEIGHT);
            ratingImgView = [[UIImageView alloc] initWithFrame:rect];
            ratingImgView.tag = CATVC_RATING_IMAGE_TAG;
            [cell.contentView addSubview:ratingImgView];
        } else {
            ratingImgView = (UIImageView *)[cell.contentView viewWithTag:CATVC_RATING_IMAGE_TAG];
        }
        NSString *ratingURL = [[self.optionsList objectAtIndex:i] objectForKey:DIANPING_RATING_IMAGE_URL];
        NSURLRequest *ratingRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:ratingURL]];
        __weak UIImageView *tmpRatingView = ratingImgView;
        [ratingImgView setImageWithURLRequest:ratingRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            tmpRatingView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        //商户平均消费
        if ([cell.contentView viewWithTag:CATVC_AVG_PRICE_TAG] == nil) {
            rect = CGRectMake(CATVC_AVG_PRICE_COORDINATE_X, CATVC_AVG_PRICE_COORDINATE_Y, CATVC_AVG_PRICE_WIDTH, CATVC_AVG_PRICE_HEIGHT);
            avgPrice = [[UILabel alloc] initWithFrame:rect];
            avgPrice.tag = CATVC_AVG_PRICE_TAG;
            avgPrice.font = [UIFont fontWithName:CATVC_AVG_PRICE_FONT size:CATVC_AVG_PRICE_FONT_SIZE];
            [cell.contentView addSubview:avgPrice];
        } else {
            avgPrice = (UILabel *)[cell.contentView viewWithTag:CATVC_AVG_PRICE_TAG];
        }
        avgPrice.text = [NSString stringWithFormat:@"人均: ￥%@", [[[self.optionsList objectAtIndex:i] objectForKey:DIANPING_AVG_PRICE] stringValue]];
        //商户地区及分类
        if ([cell.contentView viewWithTag:CATVC_RGN_CTGRY_TAG] == nil) {
            rect = CGRectMake(CATVC_RGN_CTGRY_COORDINATE_X, CATVC_RGN_CTGRY_COORDINATE_Y, CATVC_RGN_CTGRY_WIDTH, CATVC_RGN_CTGRY_HEIGHT);
            rgnCtgry = [[UILabel alloc] initWithFrame:rect];
            rgnCtgry.tag = CATVC_RGN_CTGRY_TAG;
            rgnCtgry.font = [UIFont fontWithName:CATVC_RGN_CTGRY_FONT size:CATVC_RGN_CTGRY_FONT_SIZE];
            [cell.contentView addSubview:rgnCtgry];
        } else {
            rgnCtgry = (UILabel *)[cell.contentView viewWithTag:CATVC_RGN_CTGRY_TAG];
        }
        NSArray *rgn = [[self.optionsList objectAtIndex:i] objectForKey:DIANPING_REGION_REP];
        NSArray *ctgry = [[self.optionsList objectAtIndex:i] objectForKey:DIANPING_CATEGORY_REP];
        rgnCtgry.text = [NSString stringWithFormat:@"%@  %@",[rgn firstObject], [ctgry firstObject]];
         */
        if ([cell.contentView viewWithTag:CATVC_SEPARATOR_TAG] == nil) {
            //添加cell间的分割线
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            v.tag = CATVC_SEPARATOR_TAG;
            [cell.contentView addSubview:v];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"Add Activity Image" sender:indexPath];
    }
    if (indexPath.section == 4 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"Add Participants" sender:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 6) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.optionsList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 6) {
        return YES;
    } else {
        return NO;
    }
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath != destinationIndexPath) {
        NSDictionary *data = [self.optionsList objectAtIndex:sourceIndexPath.row];
        [self.optionsList removeObjectAtIndex:sourceIndexPath.row];
        [self.optionsList insertObject:data atIndex:destinationIndexPath.row];
        [self.tableView reloadData];
    }
    
}

- (void)addOptions:(UIButton *)button
{
    [self performSegueWithIdentifier:@"Add Options" sender:button];
}

- (void)addParticipantsOnButton:(UIButton *)button
{
    [self performSegueWithIdentifier:@"Add Participants" sender:button];
}

#pragma mark - UITextField delegate

- (UITextField *)subject
{
    if (_subject == nil) {
        CGRect frame = CGRectMake(15, 0, 290, 50.0);
        _subject = [[UITextField alloc] initWithFrame:frame];
        _subject.tag = CATVC_SUBJECT_TAG;
        _subject.font = [UIFont systemFontOfSize:15];
        //_subject.textColor = [UIColor grayColor];
        _subject.placeholder = @"输入活动主题";
        _subject.autocorrectionType = UITextAutocorrectionTypeNo;
        _subject.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _subject.textAlignment = NSTextAlignmentLeft;
        _subject.keyboardType = UIKeyboardTypeDefault;
        _subject.returnKeyType = UIReturnKeyDone;
        _subject.clearButtonMode = UITextFieldViewModeWhileEditing;
        _subject.delegate = self;
        //[_subject becomeFirstResponder];
    }
    
    return _subject;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextView delegate

- (UILabel *)wordsPrompt
{
    if (_wordsPrompt == nil) {
        CGRect rect = CGRectMake(155, 110, 150, 20);
        _wordsPrompt = [[UILabel alloc] initWithFrame:rect];
        _wordsPrompt.tag = CATVC_DESCRIPTION_LABEL_TAG;
        _wordsPrompt.text = @"还可输入70个字";
        _wordsPrompt.font = [UIFont systemFontOfSize:15.0];
        _wordsPrompt.textColor = UIColorFromRGB(0xC7C7CD);
        _wordsPrompt.textAlignment = NSTextAlignmentRight;
    }
    
    return _wordsPrompt;
}

- (UITextView *)description
{
    if (_description == nil) {
        CGRect rect = CGRectMake(15, 0, 290, 110);
        _description = [[UITextView alloc] initWithFrame:rect];
        _description.tag = CATVC_DESCRIPTION_TEXTVIEW_TAG;
        _description.font = [UIFont systemFontOfSize:15.0];
        _description.autocorrectionType = UITextAutocorrectionTypeNo;
        _description.textAlignment = NSTextAlignmentLeft;
        _description.keyboardType = UIKeyboardTypeDefault;
        _description.returnKeyType = UIReturnKeyDone;
        _description.scrollEnabled = NO;
        //_description.layer.borderColor = [[UIColor blackColor] CGColor];
        //_description.layer.borderWidth = 1.0;
        _description.delegate = self;
    }
    
    return _description;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //设置换行符为退出键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    //删除字符打的时候
    if([text length] == 0)
    {
        if([textView.text length] != 0)
        {
            return YES;
        }
    }
    //输入字符的时候
    else if([[textView text] length] > 69)
    {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    int len = (int)textView.text.length;
    self.wordsPrompt.text = [NSString stringWithFormat:@"还可输入%i个字",70-len];
    if (70-len < 0) {
        self.wordsPrompt.textColor = [UIColor redColor];
    } else {
        self.wordsPrompt.textColor = UIColorFromRGB(0xC7C7CD);
    }
}

- (UIDatePicker *)datePicker
{
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _datePicker.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    }
    return _datePicker;
}

- (UITextField *)deadline
{
    if (_deadline == nil) {
        CGRect frame = CGRectMake(15, 0, 290, 50.0);
        _deadline = [[UITextField alloc] initWithFrame:frame];
        _deadline.tag = CATVC_DEADLINE_TAG;
        _deadline.font = [UIFont systemFontOfSize:15.0];
        _deadline.placeholder = @"投票截止时间";
        _deadline.inputView = self.datePicker;
        _deadline.delegate = self;
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
        UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        //定义取消按钮
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone  target:self action:@selector(cancelDatePicker:)];
        cancelButton.tintColor = [UIColor blackColor];
        //定义完成按钮
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(selectDatePicker:)];
        doneButton.tintColor = [UIColor blackColor];
        //在toolBar上加上这些按钮
        //NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
        NSArray * buttonsArray = [NSArray arrayWithObjects:cancelButton, button1, doneButton,nil];
        toolBar.items = buttonsArray;
        _deadline.inputAccessoryView = toolBar;
    }
    return _deadline;
}

- (void)cancelDatePicker:(id)sender
{
    [self.tableView reloadData];
}

- (void)selectDatePicker:(id)sender
{
    self.endDate = [self.datePicker date];
    //NSTimeInterval timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
    //date = [date dateByAddingTimeInterval:timeZoneOffset];
    //格式化日期时间
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    self.deadline.text = [dateformatter stringFromDate:self.endDate];
    [self.tableView reloadData];
}

//设置公开或者匿名投票
- (void)segmentCtrlSelectedOnPulic:(id)sender
{
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    switch (segmentCtrl.selectedSegmentIndex) {
        case 0:
            self.thePublic = [NSNumber numberWithBool:YES];
            break;
        case 1:
            self.thePublic = [NSNumber numberWithBool:NO];
            break;
        default:
            break;
    }
}

//设置公开或者匿名投票
- (void)segmentCtrlSelectedOnAnonymous:(id)sender
{
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    switch (segmentCtrl.selectedSegmentIndex) {
        case 0:
            self.anonymous = [NSNumber numberWithBool:NO];
            break;
        case 1:
            self.anonymous = [NSNumber numberWithBool:YES];
            break;
        default:
            break;
    }
}

//设置可选个数的pickerview
- (UITextField *)maxChoice
{
    if (_maxChoice == nil) {
        //CGRect frame = CGRectMake(80, 10, 40, 30.0);
        CGRect frame = CGRectMake(260, 10, 40, 30.0);
        _maxChoice = [[UITextField alloc] initWithFrame:frame];
        _maxChoice.tag = CATVC_MAX_CHOICE_TAG;
        _maxChoice.font = [UIFont systemFontOfSize:15.0];
        _maxChoice.text = @"1";
        _maxChoice.textAlignment = NSTextAlignmentCenter;
        //_maxChoice.placeholder = @"";
        _maxChoice.inputView = self.maxChoicePicker;
        _maxChoice.delegate = self;
        _maxChoice.borderStyle = UITextBorderStyleRoundedRect;
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
        UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        //定义取消按钮
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone  target:self action:@selector(cancelMaxChoicePicker:)];
        cancelButton.tintColor = [UIColor blackColor];
        //定义完成按钮
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(selectMaxChoicePicker:)];
        doneButton.tintColor = [UIColor blackColor];
        //在toolBar上加上这些按钮
        //NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
        NSArray * buttonsArray = [NSArray arrayWithObjects:cancelButton, button1, doneButton,nil];
        toolBar.items = buttonsArray;
        _maxChoice.inputAccessoryView = toolBar;
    }
    
    return _maxChoice;
}

- (UIPickerView *)maxChoicePicker
{
    if (_maxChoicePicker == nil) {
        _maxChoicePicker = [[UIPickerView alloc] init];
        _maxChoicePicker.dataSource = self;
        _maxChoicePicker.delegate = self;
    }
    
    return _maxChoicePicker;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)componen
{
    return [pickerArray count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerArray objectAtIndex:row];
}

- (void)cancelMaxChoicePicker:(id)sender
{
    [self.tableView reloadData];
}

- (void)selectMaxChoicePicker:(id)sender
{
    NSInteger row = [self.maxChoicePicker selectedRowInComponent:0];
    self.maxChoice.text = [pickerArray objectAtIndex:row];
    [self.tableView reloadData];
}

#pragma mark - Add options delegate

- (void)addOptionWithData:(NSDictionary *)data
{
    NSLog(@"%@", data);
    [self.optionsList addObject:data];
    NSLog(@"%lu", (unsigned long)[self.optionsList count]);
}

#pragma mark - Add participants delegate

- (void)addParticipants:(NSMutableArray *)participants
{
    [self.participants removeAllObjects];
    self.participants = [NSMutableArray arrayWithArray:participants];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    Users *aUser = [Users fetchUsersWithUsername:username withContext:self.managedObjectContext];
    NSString *screenname = aUser.screenname;
    NSDictionary *name = @{USERNAME:username, SCREENNAME:screenname};
    [self.participants addObject:name];
}

#pragma mark - UILongPressGestureRecognizer method

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    UILongPressGestureRecognizer *longPressGR = sender;
    if(UIGestureRecognizerStateBegan == longPressGR.state) {
        // Called on start of gesture, do work here
        CGPoint point = [longPressGR locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath != nil && indexPath.section == 6) {
            if (self.tableView.editing == YES) {
                [self.tableView setEditing:NO animated:YES];
            } else {
                [self.tableView setEditing:YES animated:YES];
            }
            
        }
    }
    if(UIGestureRecognizerStateChanged == longPressGR.state) {
        // Do repeated work here (repeats continuously) while finger is down
    }
    
    if(UIGestureRecognizerStateEnded == longPressGR.state) {
        // Do end work here when finger is lifted
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CATVC_ALERTVIEW_PUBLISH_SUCCESS_TAG)
    {
        if (buttonIndex == 0)
        {
            NSArray *navArr = self.navigationController.viewControllers;
            for (UIViewController *nav in navArr)
            {
                if ([nav isKindOfClass:[VoteFirstTableViewController class]])
                {
                    [self.navigationController popToViewController:nav animated:YES];
                }
            }
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Add Options"]) {
        VoteAddOptionsTableViewController *vc = segue.destinationViewController;
        vc.addOptionsDelegate = self;
        //设置返回键的标题
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
        backItem.title = @"";
        self.navigationItem.backBarButtonItem = backItem;
        
    } else if ([segue.identifier isEqualToString:@"Add Participants"]) {
        VoteAddParticipantsTableViewController *vc = segue.destinationViewController;
        vc.addParticipantsDelegate = self;
        if ([self.participants count] > 0) {
            vc.paticipants = [NSMutableArray arrayWithArray:self.participants];
        }
    } else if ([segue.identifier isEqualToString:@"Add Activity Image"]) {
        VoteAddActivityImageTableViewController *tvc = segue.destinationViewController;
        tvc.activityImgName = ^(NSDictionary *imageAttr){
            self.imageAttr = [[NSMutableDictionary alloc] initWithDictionary:imageAttr];
        };
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
