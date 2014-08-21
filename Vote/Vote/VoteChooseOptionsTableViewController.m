//
//  VoteChooseOptionsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-7-7.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteChooseOptionsTableViewController.h"
#import "CoreDataHelper.h"
#import "VotesInfo+VotesInfoHelper.h"
#import "Options+OptionsHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "VoteActivityDetailsTableViewController.h"

@interface VoteChooseOptionsTableViewController () <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
{
    int maxChoice;
    BOOL isNotification;
    BOOL isDeleteForever;
}
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableSet *checkMarkSet;
@property (strong, nonatomic) VotesInfo *aVote;

@end

@implementation VoteChooseOptionsTableViewController

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
        self.checkMarkSet = [[NSMutableSet alloc] init];
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        self.aVote = [VotesInfo fetchVotesWithVoteID:self.voteId withContext:self.managedObjectContext];
        maxChoice = [self.aVote.maxChoice intValue];
        isNotification = [self.aVote.notification boolValue];
        isDeleteForever = [self.aVote.deleteForever boolValue];
        [self.tableView reloadData];
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
    return [[self.fetchedResultsController sections] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows;
    
    if (section == 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    } else {
        numberOfRows = 2;
    }

    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Options" forIndexPath:indexPath];
        Options *aOption = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([self.checkMarkSet containsObject:indexPath]) {
            if (maxChoice > 1) {
                cell.imageView.image = [UIImage imageNamed:@"multiCheckmark.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"singleCheckmark.png"];
            }
            
        } else {
            if (maxChoice > 1) {
                cell.imageView.image = [UIImage imageNamed:@"multiCheck.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"singleCheck.png"];
            }
            
        }
        
        cell.textLabel.text = aOption.name;
        cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15.0];
        cell.detailTextLabel.text = aOption.address;
        cell.detailTextLabel.font = [UIFont fontWithName:@"ChalkboardSE-Regular" size:10.0];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Settings" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            while ([cell.contentView.subviews lastObject] != nil) {
                [[cell.contentView.subviews lastObject] removeFromSuperview];
            }
            cell.textLabel.text = @"消息通知";
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            //uiswitch default size 51*31
            CGFloat x = BOUNDS_WIDTH([UIScreen mainScreen]) - 20.0 - 51;
            UISwitch *switchCtrl = [[UISwitch alloc] initWithFrame:CGRectMake(x, cell.frame.size.height/2.0-31/2.0, 0, 0)];
            switchCtrl.tag = COTVC_SWITCH_NOTIFICATION_TAG;
            switchCtrl.on = isNotification;
            [switchCtrl addTarget:self action:@selector(handleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchCtrl];
            
            CGRect rect = CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5);
            UIView *separator = [[UIView alloc] initWithFrame:rect];
            separator.backgroundColor = [UIColor lightGrayColor];
            separator.tag = 1000;
            [cell.contentView addSubview:separator];

        } else {
            while ([cell.contentView.subviews lastObject] != nil) {
                [[cell.contentView.subviews lastObject] removeFromSuperview];
            }
            CGFloat x = BOUNDS_WIDTH([UIScreen mainScreen]) - 20.0 - 51;
            UISwitch *switchCtrl = [[UISwitch alloc] initWithFrame:CGRectMake(x, cell.frame.size.height/2.0-31/2.0, 0, 0)];
            switchCtrl.on = isDeleteForever;
            switchCtrl.tag = COTVC_SWITCH_DELETE_FOREVER_TAG;
                        [switchCtrl addTarget:self action:@selector(handleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchCtrl];
            
            cell.textLabel.text = @"永久删除";
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        }

    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.checkMarkSet containsObject:indexPath] == NO) {
        if (maxChoice > 1) {
            if ([self.checkMarkSet count] < maxChoice) {
                [self.checkMarkSet addObject:indexPath];
            } else {
                NSString *title = [[NSString alloc] initWithFormat:@"最多只能选择%d项", maxChoice];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [av show];
            }
        } else {
            if ([self.checkMarkSet count] > 0) {
                //因为单选，所以集合只会有一个元素，所以直接返回任意一个
                NSIndexPath *preIndex = [self.checkMarkSet anyObject];
                NSArray *indexArray = [NSArray arrayWithObjects:preIndex, nil];
                [self.checkMarkSet removeObject:preIndex];
                [tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
                [self.checkMarkSet addObject:indexPath];

            } else {
                [self.checkMarkSet addObject:indexPath];
            }
        }

    } else {
        if (maxChoice > 1) {
            [self.checkMarkSet removeObject:indexPath];
        }
    }
    NSArray *indexArray = [NSArray arrayWithObjects:indexPath, nil];
    [tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)send:(id)sender {
    if ([self.checkMarkSet count] >= 1) {
        NSArray *sortArray = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
        //对用户投票排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES];
        NSArray *sortCheckMarkSetArray = [self.checkMarkSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        NSMutableArray *curChoose = [[NSMutableArray alloc] initWithCapacity:[sortCheckMarkSetArray count]];
        for (NSIndexPath *indexPath in sortCheckMarkSetArray) {
            [curChoose addObject:[sortArray objectAtIndex:indexPath.row]];
        }
        NSLog(@"results = %@", curChoose);
        
        NSString *votesURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/submit_vote.php"];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *username = [ud objectForKey:USERNAME];
        NSDictionary *parameters;
        VotesInfo *aVote = [VotesInfo fetchVotesWithVoteID:self.voteId withContext:self.managedObjectContext];
        if (aVote.preChoose == nil) {
            parameters = @{SERVER_USERNAME: username, SERVER_VOTE_ID:self.voteId, SERVER_VOTE_PRE_CHOOSE:[NSNull null], SERVER_VOTE_CUR_CHOOSE:curChoose};
        } else {
            parameters = @{SERVER_USERNAME: username, SERVER_VOTE_ID:self.voteId, SERVER_VOTE_PRE_CHOOSE:aVote.preChoose, SERVER_VOTE_CUR_CHOOSE:curChoose};
        }
        NSLog(@"parameters:%@", parameters);
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        //manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:votesURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation: %@", operation);
            NSLog(@"responseObject: %@", responseObject);
            aVote.preChoose = [NSMutableArray arrayWithArray:curChoose];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提交成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            av.tag = COTVC_ALERTVIEW_PUBLISH_SUCCESS_TAG;
            [av show];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"connect network failure in first table view!");
            NSLog(@"operation: %@", operation);
            NSLog(@"operation: %@", operation.responseString);
            NSLog(@"Error: %@", error);
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提交失败" message:@"网络错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [av show];
        }];
        
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提交失败" message:@"未选择任何选项" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
    }
    
}

#pragma mark - Switch value changed method

- (void)handleSwitchValueChanged:(id)sender
{
    UISwitch *switchCtrl = (UISwitch *)sender;
    if (switchCtrl.tag == COTVC_SWITCH_NOTIFICATION_TAG) {
        [VotesInfo modifyVotesInfo:self.aVote withNotificationFlag:switchCtrl.on withManagedObjectContext:self.managedObjectContext];
        //向服务器发送设置消息通知
        
    } else {
        [VotesInfo modifyVotesInfo:self.aVote withDeleteForeverFlag:switchCtrl.on withManagedObjectContext:self.managedObjectContext];
        //向服务器发送设置永久删除
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == COTVC_ALERTVIEW_PUBLISH_SUCCESS_TAG)
    {
        NSArray *navArr = self.navigationController.viewControllers;
        for (UIViewController *nav in navArr)
        {
            if ([nav isKindOfClass:[VoteActivityDetailsTableViewController class]])
            {
                [self.navigationController popToViewController:nav animated:YES];
            }
        }
    }
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
