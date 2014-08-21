//
//  VoteFirstTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteFirstTableViewController.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "Users+UsersHelper.h"
#import "Friends+FriendsHelper.h"
#import "VoteCountDownTimerTableViewCell.h"
#import "VotesInfo+VotesInfoHelper.h"
#import "VoteCreateActivityTableViewController.h"
#import "VoteActivityDetailsTableViewController.h"
#import "FailedDeletedVotes+Helper.h"

@interface VoteFirstTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) AFHTTPRequestOperationManager *AFManager;

@end

@implementation VoteFirstTableViewController

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
        self.AFManager = [[AFHTTPRequestOperationManager alloc] init];
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
        NSEntityDescription *votesEntity = [NSEntityDescription entityForName:VOTES_INFO inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:votesEntity];
        
        NSSortDescriptor *sortFirstDescriptor = [NSSortDescriptor sortDescriptorWithKey:VOTE_IS_END ascending:YES];
        NSSortDescriptor *sortSecondDescriptor = [NSSortDescriptor sortDescriptorWithKey:VOTE_END_TIME ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortFirstDescriptor, sortSecondDescriptor, nil]];
        
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud stringForKey:USERNAME];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whoseVote.username == %@", username];
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.imagesDownloadQueue = [[NSOperationQueue alloc] init];
    self.imagesDownloadQueue.name = @"download image";
    self.imagesDownloadQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    self.AFManager.operationQueue.maxConcurrentOperationCount = 1;
    self.AFManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    self.AFManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        //create nsfetchresultcontroller...
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
        if (authenticated) {
            [self.tableView reloadData];
            NSString *username = [ud objectForKey:USERNAME];
            if ([Users fetchUsersWithUsername:username withContext:self.managedObjectContext] != nil) {
                self.AFManager.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
            }
            [self fetchUserInfoFromServer];
            [self fetchFriendsFromServer];
            [self fetchVotesInfoListFromServer];
            [FailedDeletedVotes batchRemoveDeletedVotesWithContext:self.managedObjectContext];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    if (authenticated) {
        //收取未读信息
        [self getUnreadMsg];
        if (self.managedObjectContext) {
            //1. 读取数据库 并显示 2.联网获取数据，检查是否有新的数据，然后reload data
            [self fetchUserInfoFromServer];
            [self fetchFriendsFromServer];
            [self fetchVotesInfoListFromServer];
            [FailedDeletedVotes batchRemoveDeletedVotesWithContext:self.managedObjectContext];
        } else {
            
        }

    } else {
        
    }
}

- (void)fetchVotesInfoListFromServer
{
    NSString *votesInfoURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_vote.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSDictionary *parameters = @{SERVER_USERNAME: username};
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    [self.AFManager GET:votesInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        NSArray *votes = (NSArray *)[responseObject objectForKey:SERVER_VOTES];
        if ((NSNull *)votes != [NSNull null]) {
            if ([votes count] > 0) {
                [VotesInfo updateDatabaseWithList:votes withContext:context];
                [context save:NULL];
            }
        }
        [self.tableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];
}


- (void)fetchUserInfoFromServer
{
    NSString *userInfoURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_user_info.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSDictionary *parameters = @{SERVER_USERNAME: username, SERVER_FETCH_NAME: username};
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak NSOperationQueue *queue = self.imagesDownloadQueue;
    [self.AFManager GET:userInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        [Users updateDatabaseWithData:(NSDictionary *)responseObject withContext:context withQueue:queue];
        [self.tableView reloadData];
        [context save:NULL];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        if (context) {
            //get login username
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSString *username = [ud stringForKey:USERNAME];
            //get the name of a friend
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
            NSArray *users = [CoreDataHelper searchObjectsForEntity:USERS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
            if ([users count] == 0) {
                [context performBlock:^{
                    [Users insertUsersToDatabaseWithData:nil withManagedObjectContext:context withQueue:nil];
                    [context save:NULL];
                    [self.tableView reloadData];
                }];
            } else if (users == nil) {
                NSLog(@"fetch data error from database in first table view");
            }

        }
    }];
}

- (void)fetchFriendsFromServer
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    
    NSString *friendsListURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_friend.php"];
    NSDictionary *parameters = @{SERVER_USERNAME: username};
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak NSOperationQueue *queue = self.imagesDownloadQueue;
    [self.AFManager GET:friendsListURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        if ((NSNull *)[responseObject objectForKey:SERVER_FRIENDS_ARRAY] == [NSNull null]) {
            return;
        }
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        NSArray *data = [[NSArray alloc] initWithArray:[responseObject objectForKey:SERVER_FRIENDS_ARRAY]];
        if ([data count]) {
            [Friends updateDatabaseWithData:data withContext:context withQueue:queue];
            [context save:NULL];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return [[self.fetchedResultsController sections] count];
    //return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
    
    NSLog(@"section num = %ld, row num = %ld", (long)section, (long)numberOfRows);
    
    return numberOfRows;
    //return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Count Down Timer";
    VoteCountDownTimerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    VotesInfo *aVote = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.category = aVote.category;
    cell.title = aVote.title;
    if ([aVote.thePublic boolValue] == YES) {
        cell.thePublic = aVote.thePublic;
    } else {
        cell.anonymous = aVote.anonymous;
    }
    cell.endTime = aVote.endTime;
    cell.thePublic = aVote.thePublic;
    NSString *organizer = aVote.organizer;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSString *screenname;
    //自己是发起人...
    if ([organizer isEqualToString:username]) {
        Users *aUser = [Users fetchUsersWithUsername:username withContext:self.managedObjectContext];
        screenname = aUser.screenname;
    }
    //好友是发起人
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whoseFriends.username == %@) AND (username == %@)", username, organizer];
        NSArray *friends = [CoreDataHelper searchObjectsForEntity:FRIENDS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:self.managedObjectContext];
        if ([friends count] == 1) {
            Friends *aFriend = [friends firstObject];
            screenname = aFriend.screenname;
        } else {
            //error
        }
    }
    cell.organizer = [[NSString alloc] initWithFormat:@"发起人: %@", screenname];
    //设置字体
    cell.anonymousLabel.font = [UIFont boldSystemFontOfSize:FIRST_CELL_ANONYMOUS_FONT_SIZE];
    cell.anonymousLabel.textAlignment = NSTextAlignmentCenter;
    cell.anonymousLabel.textColor = [UIColor whiteColor];
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:FIRST_CELL_TITLE_FONT_SIZE];
    cell.timerLabel.font = [UIFont fontWithName:FIRST_CELL_TIMER_FONT size:FIRST_CELL_TIMER_FONT_SIZE];
    cell.timerLabel.textColor = [UIColor redColor];
    cell.timerLabel.textAlignment = NSTextAlignmentRight;
    cell.organizerLabel.font = [UIFont systemFontOfSize:FIRST_CELL_ORGANIZER_FONT_SIZE];
    cell.organizerLabel.textColor = [UIColor lightGrayColor];
    //到期之后的处理
    cell.voteExpireCallBack = ^{
        if ([aVote.isEnd boolValue] == NO) {
            aVote.isEnd = [NSNumber numberWithBool:YES];
        }
    };
    [cell startTimer];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        VotesInfo *aVote = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([aVote.deleteForever boolValue] == YES) {
            //永久删除数据，向服务器发送永久删除信息
            [VotesInfo deleteVotesInfoOnServer:aVote.voteID withManagedObjectContext:self.managedObjectContext forever:YES];
            //从本地数据库删除
            [VotesInfo deleteVotesInfo:aVote withManagedObjectContext:self.managedObjectContext];
        } else {
            //临时删除数据，向服务器发送临时删除信息
            [VotesInfo deleteVotesInfoOnServer:aVote.voteID withManagedObjectContext:self.managedObjectContext forever:NO];
            //从本地数据库删除
            [VotesInfo deleteVotesInfo:aVote withManagedObjectContext:self.managedObjectContext];
        }
        // Delete the row from the table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//收取当前用户的未读信息个数
- (void)getUnreadMsg
{
    //设置提示信息
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_badge.php"];
    NSDictionary *para = @{SERVER_USERNAME:username};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        NSNumber *usrVoteBadgeNum = [[NSNumber alloc] init];
        usrVoteBadgeNum = [responseObject objectForKey:SERVER_USR_VOTE_BADGE_NUM];
        NSNumber *friendsBadgeNum = [[NSNumber alloc] init];
        friendsBadgeNum = [responseObject objectForKey:SERVER_FRIEND_BADGE_NUM];
        if ([[usrVoteBadgeNum stringValue] isEqualToString:@"0"]) {
            [[[[self.tabBarController viewControllers] objectAtIndex:0] tabBarItem] setBadgeValue:nil];
        } else {
            [[[[self.tabBarController viewControllers] objectAtIndex:0] tabBarItem] setBadgeValue:[usrVoteBadgeNum stringValue]];
        }
        if ([[friendsBadgeNum stringValue] isEqualToString:@"0"]) {
            [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:nil];
        } else {
            [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[friendsBadgeNum stringValue]];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];

}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    if ([segue.identifier isEqualToString:@"Create Activity"]) {
        VoteCreateActivityTableViewController *vc = [segue destinationViewController];
        vc.imagesDownloadQueue = self.imagesDownloadQueue;
    }
    if ([segue.identifier isEqualToString:@"Activity Details"]) {
        VoteCountDownTimerTableViewCell *cell = (VoteCountDownTimerTableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        VotesInfo *aVote = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        VoteActivityDetailsTableViewController *vc = [segue destinationViewController];
        vc.voteId = aVote.voteID;
    }
}



@end
