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

- (void)setupFetchedResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *playerEntity = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:playerEntity];
    
    NSSortDescriptor *sortDescriptorSections = [NSSortDescriptor sortDescriptorWithKey:@"group" ascending:YES];
    NSSortDescriptor *sortDescriptorRows = [NSSortDescriptor sortDescriptorWithKey:@"screennamePinyin" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorSections, sortDescriptorRows, nil]];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@", self.team];
    //[fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:0];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"group" cacheName:@"Players"];
    _fetchedResultsController.delegate = self;
    
    NSError *error = NULL;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)fetchDataIntoDocument:(UIManagedDocument *)document
{
    
}

- (void)insertDataIntoDocument:(NSArray *)data
{
    if (!self.managedObjectContext) {
        NSLog(@"database is not ready!");
        return;
    }
    NSManagedObjectContext *context = self.managedObjectContext;
    for (NSDictionary *element in data) {
        
    }
}

- (void)fetchDataFromServer
{
    NSString *friendsListURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/228/login.php"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:friendsListURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *data = (NSArray *)responseObject;
        [self insertDataIntoDocument:data];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure!");
    }];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.document) {
        self.document = [CoreDataHelper sharedDatabase];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            self.managedObjectContext = self.document.managedObjectContext;
            [self setupFetchedResultsController];
            [self fetchDataFromServer];
            [self fetchDataIntoDocument:self.document];
        }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = self.document.managedObjectContext;
            [self setupFetchedResultsController];
            [self fetchDataIntoDocument:self.document];
        }];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        self.managedObjectContext = self.document.managedObjectContext;
        [self setupFetchedResultsController];
        [self fetchDataIntoDocument:self.document];
    }
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
