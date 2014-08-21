//
//  VoteActivityDetailsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-6-27.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteActivityDetailsTableViewController.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "VotesInfo+VotesInfoHelper.h"
#import "Options+OptionsHelper.h"
#import "VoteBarResultsView.h"
#import "VoteChooseOptionsTableViewController.h"
#import "VoteOptionDetailsTableViewController.h"
#import "VoteLookUpParticipantsViewController.h"
#import "NSString+NSStringHelper.h"

@interface VoteActivityDetailsTableViewController () <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
{
    
}

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) VotesInfo *aVote;

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *percent;

@end

@implementation VoteActivityDetailsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.document = nil;
        self.managedObjectContext = nil;
        self.fetchedResultsController = nil;

    }
    
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return  _fetchedResultsController;
    }
    
    if (self.managedObjectContext) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *votesEntity = [NSEntityDescription entityForName:VOTES_OPTIONS inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:votesEntity];
        
        NSSortDescriptor *sortDescriptorRows = [NSSortDescriptor sortDescriptorWithKey:VOTE_OPTIONS_ORDER ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorRows, nil]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whichVote.voteID == %@", self.voteId];
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setFetchBatchSize:0];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = NULL;
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        return _fetchedResultsController;
    }
    
    return nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        self.aVote = [VotesInfo fetchVotesWithVoteID:self.voteId withContext:self.managedObjectContext];
        [self.tableView reloadData];
        [self startTimer];

    }];
    self.imagesDownloadQueue = [[NSOperationQueue alloc] init];
    self.imagesDownloadQueue.name = @"download options image";
    self.imagesDownloadQueue.maxConcurrentOperationCount = 3;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.managedObjectContext) {
        [self fetchVotesInfoFromServer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)fetchVotesInfoFromServer
{
    NSString *votesInfoURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_vote_detail.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSDictionary *parameters = @{SERVER_USERNAME: username, SERVER_VOTE_ID:self.voteId};
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:votesInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        NSManagedObjectContext *context = self.managedObjectContext;
        if (context) {
            [context performBlock:^{
                [VotesInfo updateDatabaseWithDetails:(NSDictionary *)responseObject withContext:self.managedObjectContext withQueue:self.imagesDownloadQueue];
                [context save:NULL];
                [self.tableView reloadData];
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
    
    return numberOfRows + ADTVC_CELL_ABOVE_OPTIONS_LIST;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //主题
        UIFont *font = [UIFont boldSystemFontOfSize:20.0];
        CGFloat width = 290.0;
        CGFloat height = [NSString calculateTextHeight:self.aVote.title font:font width:width];
        return height + 20;
        
    } else if (indexPath.row == 1) {
        //描述
        UIFont *font = [UIFont systemFontOfSize:15.0];
        CGFloat width = 290.0;
        CGFloat height = [NSString calculateTextHeight:self.aVote.voteDescription font:font width:width];
        
        return height + 20;

    } else if (indexPath.row == 2) {
        //参加人
        return 40.0;
    } else if (indexPath.row == 3) {
        //多选公开匿名
        return 40.0;
    } else if (indexPath.row == 4) {
        //截止时间
        return 40.0;
    } else {
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - ADTVC_CELL_ABOVE_OPTIONS_LIST) inSection:indexPath.section];
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        UIFont *font = [UIFont fontWithName:ADTVC_OPTIONS_TITLE_FONT size:ADTVC_OPTIONS_TITLE_FONT_SIZE];
        NSString *text1 = [NSString stringWithFormat:@"A. %@", aOption.name];
        CGFloat width = 300;
        CGFloat height1 = [NSString calculateTextHeight:text1 font:font width:width];
        if ([aOption.businessID integerValue] == BUSINESS_ID_OF_NO_ADDR) {
            
            return 10.0 + height1 + 10.0 + 20.0 + 10.0;
            
        } else {
            NSString *text2 = aOption.address;
            CGFloat height2 = [NSString calculateTextHeight:text2 font:font width:width];
            
            return 10.0 + height1 + 10.0 + height2 + 10.0 + 20.0 + 10.0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    // Configure the cell...
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Subject" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([cell.contentView viewWithTag:ADTVC_SUBJECT_TAG] == nil) {
            UILabel *subject = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 290.0, cell.frame.size.height - 20.0)];
            subject.tag = ADTVC_SUBJECT_TAG;
            subject.numberOfLines = 0;
            subject.lineBreakMode = NSLineBreakByWordWrapping;
            subject.text = self.aVote.title;
            subject.font = [UIFont boldSystemFontOfSize:20.0];
            [cell.contentView addSubview:subject];
        }

    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([cell.contentView viewWithTag:ADTVC_DESCRIPTION_TAG] == nil) {
            UILabel *decription = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 290.0, cell.frame.size.height - 20.0)];
            decription.tag = ADTVC_DESCRIPTION_TAG;
            decription.numberOfLines = 0;
            decription.lineBreakMode = NSLineBreakByWordWrapping;
            decription.text = self.aVote.voteDescription;
            decription.font = [UIFont systemFontOfSize:15.0];
            [cell.contentView addSubview:decription];
        }
        
    }else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Participants" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSUInteger count = [self.aVote.participants count];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        if ([self.aVote.anonymous boolValue] == NO) {
            cell.textLabel.text = [NSString stringWithFormat:@"共有%lu人参与投票,", (unsigned long)count];
            CGFloat width = [NSString calculateTextWidth:cell.textLabel.text font:cell.textLabel.font];
            if ([cell.contentView viewWithTag:ADTVC_PARTICIPANTS_BTN_TAG] == nil) {
                UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                checkButton.frame = CGRectMake(15 + width, ADTVC_PARTICIPANTS_BTN_Y, ADTVC_PARTICIPANTS_BTN_WIDTH, ADTVC_PARTICIPANTS_BTN_HEIGHT);
                checkButton.tag = ADTVC_PARTICIPANTS_BTN_TAG;
                [checkButton setTitle:@"点击查看" forState:UIControlStateNormal];
                checkButton.tintColor = [UIColor blueColor];
                checkButton.backgroundColor = [UIColor whiteColor];
                //[checkButton.layer setMasksToBounds:YES];
                //[checkButton.layer setCornerRadius:8.0];
                [checkButton addTarget:self action:@selector(lookUpParticipants:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:checkButton];
            }
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"共有%lu人参与投票", (unsigned long)count];
        }

        
    } else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Multi-Choice" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *anonymous;
        if ([self.aVote.anonymous boolValue]== YES) {
            anonymous = @"匿名投票";
        } else {
            anonymous = @"公开投票";
        }
        NSString *choice;
        if ([self.aVote.maxChoice intValue] > 1) {
            choice = [[NSString alloc] initWithFormat:@"多选:(最多可选%@项)", self.aVote.maxChoice];
        } else {
            choice = @"单选";
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", anonymous, choice];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        
    } else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Deadline" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([self.aVote.isEnd boolValue] == YES) {
            cell.textLabel.text = @"活动已结束";
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"距结束还有:%@", self.endTime];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Options" forIndexPath:indexPath];
        while ([cell.contentView.subviews lastObject] != nil) {
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - ADTVC_CELL_ABOVE_OPTIONS_LIST) inSection:indexPath.section];
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        UIFont *font = [UIFont fontWithName:ADTVC_OPTIONS_TITLE_FONT size:ADTVC_OPTIONS_TITLE_FONT_SIZE];
        NSString *text1 = [NSString stringWithFormat:@"A. %@", aOption.name];
        CGFloat width = 300;
        CGFloat height1 = [NSString calculateTextHeight:text1 font:font width:width];
        //投票选项标题
        UILabel *titleLabel;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_TITLE_X, ADTVC_OPTIONS_TITLE_Y, width, height1)];
        //titleLabel.tag = ADTVC_OPTIONS_TITLE_TAG;
        titleLabel.font = font;
        NSLog(@"options=%@", aOption);
        NSLog(@"options.order=%@", aOption.order);
        titleLabel.text = [[NSString alloc] initWithFormat:@"%@. %@", aOption.order, aOption.name];
        [cell.contentView addSubview:titleLabel];
        CGFloat barView_Y = 0.0;
         //投票选项地址
        UILabel *addrLabel;
        if ([aOption.businessID integerValue] == BUSINESS_ID_OF_NO_ADDR) {
            barView_Y = titleLabel.frame.origin.y + height1 + 10.0;

        } else {
            NSString *text2 = aOption.address;
            CGFloat height2 = [NSString calculateTextHeight:text2 font:font width:width];
            addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_ADDR_X, ADTVC_OPTIONS_TITLE_Y+height1+10.0, width, height2)];
            addrLabel.font = font;
            addrLabel.text = aOption.address;
            [cell.contentView addSubview:addrLabel];
            barView_Y = addrLabel.frame.origin.y + height2 + 10.0;
        }
        //投票选项横向柱状图
        NSArray *percent = [NSArray arrayWithObjects:@(0.852), @(0.017), @(0.397), @(0.782), @(0.638), @(0.293), @(0.192), @(0.406),nil];
        VoteBarResultsView *barView;
        barView = [[VoteBarResultsView alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_VOTE_BAR_X, barView_Y, ADTVC_OPTIONS_VOTE_BAR_WIDTH, ADTVC_OPTIONS_VOTE_BAR_HEIGHT)];
        //barView.tag = ADTVC_OPTIONS_VOTE_BAR_TAG;
        [cell.contentView addSubview:barView];
        
        barView.order = aOption.order;
        barView.percent = [percent objectAtIndex:indexPath.row - ADTVC_CELL_ABOVE_OPTIONS_LIST];
        //投票选项百分比显示
        UILabel *percentLabel;
        percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(ADTVC_OPTIONS_VOTE_BAR_X, barView_Y, ADTVC_OPTIONS_VOTE_BAR_WIDTH, ADTVC_OPTIONS_VOTE_BAR_HEIGHT)];
        percentLabel.font = [UIFont fontWithName:ADTVC_OPTIONS_VOTE_PERCENT_FONT size:ADTVC_OPTIONS_VOTE_PERCENT_FONT_SIZE];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        //percentLabel.layer.borderWidth = 1.0;
        //percentLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [cell.contentView addSubview:percentLabel];

        float fPercent = [[percent objectAtIndex:indexPath.row - ADTVC_CELL_ABOVE_OPTIONS_LIST] floatValue];
        percentLabel.text = [NSString stringWithFormat:@"%.1f%%(13)", fPercent*100];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= ADTVC_CELL_ABOVE_OPTIONS_LIST) {
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - ADTVC_CELL_ABOVE_OPTIONS_LIST) inSection:indexPath.section];
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        if ([aOption.businessID integerValue] == BUSINESS_ID_OF_NO_ADDR) {
            //do nothing
        } else {
            UIActionSheet *myActionSheet;
            if ([self.aVote.anonymous boolValue] == YES) {
                myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看选项信息", nil];
            } else {
                myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看选项信息", @"查看选项投票人", nil];
            }
            [myActionSheet showInView:self.view];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSLog(@"取消");
    } else {
        switch (buttonIndex) {
            case 0:
                [self performSegueWithIdentifier:@"Option Details" sender:self];
                break;
            case 1:
                //查看投票人信息
                
                break;
            default:
                break;
        }
    }
}


- (void)startTimer
{
    // invalidate a previous timer in case of reuse
    if (self.timer)
        [self.timer invalidate];
    
    // create a new timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.timer fire];
}


- (void)updateCounter
{
    NSDate *now = [NSDate date];
    //NSLog(@"now = %@, endDate = %@", now, self.endTime);
    // has the target time passed?
    if ([self.aVote.endTime earlierDate:now] == self.aVote.endTime) {
        [self.timer invalidate];
    } else {
        NSUInteger flags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:flags fromDate:now toDate:self.aVote.endTime options:0];
        
        //NSLog(@"there are %ld days, %ld hours, %ld minutes and %ld seconds remaining", (long)[components day], (long)[components hour], (long)[components minute], (long)[components second]);
        if (components.day > 0) {
            self.endTime = [NSString stringWithFormat:@"%ld天%02ld小时%02ld分钟", (long)[components day], (long)[components hour], (long)[components minute]];
        } else {
            NSString *timerString = [NSString stringWithFormat:@"%02ld小时%02ld分钟", (long)[components hour], (long)[components minute]];
            
            self.endTime = [NSString stringWithFormat:@"%@", timerString];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

- (void)lookUpParticipants:(UIButton *)button
{
    [self performSegueWithIdentifier:@"Look Up Participants" sender:self];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Choose Options"]) {
        VoteChooseOptionsTableViewController *vc = (VoteChooseOptionsTableViewController *)[segue destinationViewController];
        vc.voteId = self.voteId;
    } else if ([segue.identifier isEqualToString:@"Option Details"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSLog(@"%lu, %ld", (unsigned long)indexPath.section, (long)indexPath.row);
        if (indexPath.row >= ADTVC_CELL_ABOVE_OPTIONS_LIST) {
            NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - ADTVC_CELL_ABOVE_OPTIONS_LIST) inSection:indexPath.section];
            Options *aOption = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
            VoteOptionDetailsTableViewController *vc = [segue destinationViewController];
            vc.businessID = aOption.businessID;
        }
    } else if ([segue.identifier isEqualToString:@"Look Up Participants"]) {
        VoteLookUpParticipantsViewController *vc = [segue destinationViewController];
        vc.participants = [NSMutableArray arrayWithArray:self.aVote.participants];
    }
}


@end
