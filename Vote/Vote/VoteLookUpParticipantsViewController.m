//
//  VoteLookUpParticipantsViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteLookUpParticipantsViewController.h"
#import "VoteLookUpParticipantsCell.h"
#import "VoteLookUpParticipantsFlowLayout.h"
#import "CoreDataHelper.h"
#import "Users+UsersHelper.h"
#import "Friends+FriendsHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"

@interface VoteLookUpParticipantsViewController ()

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation VoteLookUpParticipantsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    VoteLookUpParticipantsFlowLayout *layout = [[VoteLookUpParticipantsFlowLayout alloc] init];
    [self.collectionView setCollectionViewLayout:layout];
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        [self.collectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [self.participants count];
    if (self.managedObjectContext) {
        return count + 1;
    } else {
        return 0;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VoteLookUpParticipantsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Participants" forIndexPath:indexPath];
    if (indexPath.row == [self.participants count]) {
        cell.nameLabel.text = @"添加";
    } else {
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud objectForKey:USERNAME];
        NSDictionary *name = [self.participants objectAtIndex:indexPath.row];
        NSString *participantName = [name objectForKey:USERNAME];
        NSString *screenname = [name objectForKey:SCREENNAME];
        if ([participantName isEqualToString:username]) {
            Users *aUser = [Users fetchUsersWithUsername:participantName withContext:self.managedObjectContext];
            cell.imageView.image = [UIImage imageWithContentsOfFile:aUser.originalHeadImagePath];
        } else {
            Friends *aFriend = nil;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whoseFriends.username == %@) AND (username == %@)", username, participantName];
            NSArray *results = [CoreDataHelper searchObjectsForEntity:FRIENDS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:self.managedObjectContext];
            if ([results count] == 1) {
                aFriend = [results firstObject];
                cell.imageView.image = [UIImage imageWithContentsOfFile:aFriend.originalHeadImagePath];
            } else {
                //不是好友，下载图片
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                NSString *url = [NSString stringWithFormat:@"http://115.28.228.41/vote/upload/%@/%@.png", participantName, participantName];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
                UIImage *headImage = [UIImage imageNamed:@"friendHeadImage.png"];
                __weak UIImageView *imageView = cell.imageView;
                [cell.imageView setImageWithURLRequest:request placeholderImage:headImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    imageView.image = image;
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"operation: %@", request);
                    NSLog(@"operation: %@", response);
                    NSLog(@"Error: %@", error);
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }];
            }
        }
        cell.nameLabel.text = screenname;
    }
    
    return cell;

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
