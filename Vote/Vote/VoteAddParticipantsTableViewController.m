//
//  VoteAddParticipantsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-6-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAddParticipantsTableViewController.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "Friends.h"
#import "Friends+FriendsHelper.h"
#import "Users+UsersHelper.h"
#import "VoteCreateActivityTableViewController.h"

@interface VoteAddParticipantsTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end

@implementation VoteAddParticipantsTableViewController

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
        self.paticipants = [[NSMutableArray alloc] init];
    }
    
    return self;
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
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@", self.team];
        //[fetchRequest setPredicate:predicate];
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
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        //create nsfetchresultcontroller...
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        [self.managedObjectContext performBlock:^{

        }];
        
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"section name = %@", [sectionInfo name]);
    
    return [sectionInfo name];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0;
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

    return numberOfSections;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
    
    NSLog(@"section num = %ld, row num = %ld", (long)section, (long)numberOfRows);
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    UITableViewCell *cell;
    
    cellIdentifier = @"Friends";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    Friends *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    if ([cell.contentView viewWithTag:ADD_PARTICIPANTS_SEPARATOR_TAG] == nil) {
        CGFloat sepratorHeight = cell.frame.size.height - 0.5;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, sepratorHeight, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
    }
    //设置check mark
    cell.accessoryType = UITableViewCellAccessoryNone;
    for (NSDictionary *elem in self.paticipants) {
        if ([friend.username isEqualToString:[elem objectForKey:USERNAME]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friends *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    for (NSDictionary *elem in self.paticipants) {
        if ([friend.username isEqualToString:[elem objectForKey:USERNAME]]) {
            [self.paticipants removeObjectIdenticalTo:elem];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
    }
    NSDictionary *name = @{USERNAME:friend.username, SCREENNAME:friend.screenname};
    [self.paticipants addObject:name];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)confirm:(id)sender {
    
    //NSLog(@"self.addParticipantsDelegate = %@", self.addParticipantsDelegate);
    [self.addParticipantsDelegate addParticipants:self.paticipants];
    NSArray *navArr = self.navigationController.viewControllers;
    for (UIViewController *nav in navArr)
    {
        if ([nav isKindOfClass:[VoteCreateActivityTableViewController class]])
        {
            [self.navigationController popToViewController:nav animated:YES];
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
