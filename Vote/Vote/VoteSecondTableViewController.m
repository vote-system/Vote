//
//  VoteSecondTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteSecondTableViewController.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "Friends.h"
#import "Friends+FriendsHelper.h"
#import "Users+UsersHelper.h"
#import "VoteFriendsDetailsInfoTableViewController.h"

@interface VoteSecondTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation VoteSecondTableViewController

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

- (IBAction)addFriends:(id)sender {
    
}


-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    if (self.managedObjectContext) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *friendsEntity = [NSEntityDescription entityForName:FRIENDS inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:friendsEntity];
        
        NSSortDescriptor *sortDescriptorSections = [NSSortDescriptor sortDescriptorWithKey:GROUP ascending:YES];
        NSSortDescriptor *sortDescriptorRows = [NSSortDescriptor sortDescriptorWithKey:SCREENNAME_PINYIN ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorSections, sortDescriptorRows, nil]];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptorRows]];
        
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud stringForKey:USERNAME];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whoseFriends.username == %@", username];
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setFetchBatchSize:0];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:GROUP cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = NULL;
        if (![_fetchedResultsController performFetch:&error]) {
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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        //create nsfetchresultcontroller...
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        [self.tableView reloadData];
    }];
    self.headImagesDownloadQueue = [[NSOperationQueue alloc] init];
    self.headImagesDownloadQueue.name = @"download friends head image";
    self.headImagesDownloadQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //建立fetchcontroller
    if (self.managedObjectContext) {
        //1. 读取数据库 并显示 2.联网获取数据，检查是否有新的数据，然后reload data
        [self fetchDataFromServer];
    } else {
        //do nothing
    }
}

- (void)fetchDataFromServer
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *friendsListURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_friend.php"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [[NSString alloc] initWithString:[ud objectForKey:USERNAME]];
    NSDictionary *parameters = @{SERVER_USERNAME: username};
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak NSOperationQueue *queue = self.headImagesDownloadQueue;
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:friendsListURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ((NSNull *)[responseObject objectForKey:SERVER_FRIENDS_ARRAY] == [NSNull null]) {
            return;
        }
        //1. 和数据库比对，如果存在并需要修改，则修改，不存在则创建，如果不存在创建新的
        [Friends updateDatabaseWithData:[responseObject objectForKey:SERVER_FRIENDS_ARRAY] withContext:context withQueue:queue];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in second table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        NSInteger actualSection = section - SECOND_SECTION_ABOVE_FRIENDS;
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:actualSection];
        NSLog(@"section name = %@", [sectionInfo name]);
        
        return [sectionInfo name];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0;
    } else {
        return 22.0;
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger numberOfSections = [[self.fetchedResultsController sections] count];
    NSLog(@"section = %ld", (long)numberOfSections);
    return numberOfSections + SECOND_SECTION_ABOVE_FRIENDS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        NSInteger actualSection = section - SECOND_SECTION_ABOVE_FRIENDS;
        NSInteger numberOfRows;
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:actualSection];
        numberOfRows = [sectionInfo numberOfObjects];
        
        NSLog(@"section num = %ld, row num = %ld", (long)section, (long)numberOfRows);
        
        return numberOfRows;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellIdentifier = @"New Friends";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        cell.textLabel.text = @"新的朋友";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.imageView.image = [UIImage imageNamed:@"addNewFriends.png"];
        //添加cell间的分割线
        CGFloat sepratorHeight = cell.frame.size.height - 0.5;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, sepratorHeight, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
    } else {
        cellIdentifier = @"Friends";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row) inSection:(indexPath.section - SECOND_SECTION_ABOVE_FRIENDS)];
        Friends *friend = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        cell.textLabel.text = friend.screenname;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:friend.mediumHeadImagePath];
        if (image != nil) {
            CGSize itemSize = CGSizeMake(40.0, 40.0);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [image drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        } else {
            image = [UIImage imageNamed:@"friendHeadImage.png"];
            cell.imageView.image = image;
        }
        //添加cell间的分割线
        if ([cell.contentView viewWithTag:SECOND_SEPARATOR_TAG] == nil) {
            CGFloat sepratorHeight = cell.frame.size.height - 0.5;
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, sepratorHeight, 320.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:v];
        }
    }

    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

/*
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray
                                                    arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
*/

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
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row) inSection:(indexPath.section - SECOND_SECTION_ABOVE_FRIENDS)];
        Friends *aFriend = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        //向服务器发送删除数据
        [Friends deleteFriendsOnServer:aFriend.username withManagedObjectContext:self.managedObjectContext];
        //从本地删除
        [Friends deleteFriends:aFriend withManagedObjectContext:self.managedObjectContext];
        // Delete the row from the table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"Friend Info"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        NSIndexPath *actualIndexPath = [NSIndexPath indexPathForRow:(indexPath.row) inSection:(indexPath.section - SECOND_SECTION_ABOVE_FRIENDS)];
        VoteFriendsDetailsInfoTableViewController *friendsDetailsVC = [segue destinationViewController];
        Friends *friend = [self.fetchedResultsController objectAtIndexPath:actualIndexPath];
        friendsDetailsVC.username = friend.username;
        friendsDetailsVC.originalHeadImageURL = friend.originalHeadImageUrl;
        friendsDetailsVC.screenname = friend.screenname;
        friendsDetailsVC.gender = friend.gender;
        friendsDetailsVC.signature = friend.signature;
        friendsDetailsVC.isFriend = YES;
    } else if ([segue.identifier isEqualToString: @"Friend Request List"]) {

    } else {
    
    }
}



@end
