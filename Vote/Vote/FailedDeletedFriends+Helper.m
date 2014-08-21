//
//  FailedDeletedFriends+Helper.m
//  Vote
//
//  Created by 丁 一 on 14-8-19.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "FailedDeletedFriends+Helper.h"
#import "Users+UsersHelper.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"

@implementation FailedDeletedFriends (Helper)

+ (void)insertDeletedFriends:(NSString *)friendName withContext:(NSManagedObjectContext *)context
{
    FailedDeletedFriends *aDeletedFriend = [NSEntityDescription insertNewObjectForEntityForName:FAILED_DELETED_FRIENDS inManagedObjectContext:context];
    aDeletedFriend.username = friendName;
    //get login username, then hook the current user
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    aDeletedFriend.whoseDeletedFriends = [Users fetchUsersWithUsername:username withContext:context];
}

+ (FailedDeletedFriends *)fetchDeletedFriends:(NSString *)friendName withContext:(NSManagedObjectContext *)context
{
    FailedDeletedFriends *aDeletedFriend = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", friendName];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:FAILED_DELETED_FRIENDS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([results count] > 0) {
        aDeletedFriend = [results firstObject];
    }
    
    return aDeletedFriend;
    
}

+ (void)removeDeletedFriends:(NSString *)friendName withContext:(NSManagedObjectContext *)context
{
    FailedDeletedFriends *aDeletedFriend = [FailedDeletedFriends fetchDeletedFriends:friendName withContext:context];
    if (aDeletedFriend != nil) {
        [context deleteObject:aDeletedFriend];
    }
}

+ (void)batchRemoveDeletedFriendsWithContext:(NSManagedObjectContext *)context
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whoseDeletedFriends.username == %@",username];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:FAILED_DELETED_FRIENDS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([results count] > 0) {
        NSMutableArray *mutableOperations = [NSMutableArray array];
        for (FailedDeletedFriends *aDeletedFriend in results) {
            NSDictionary *parameters = @{SERVER_USERNAME:username, SERVER_FRIEND_NAME:aDeletedFriend.username};
            NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/delete_friends.php"];
            NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"operation: %@", operation);
                NSLog(@"responseObject: %@", responseObject);
                //删除指定friend
                NSString *friendName = [responseObject objectForKey:SERVER_FRIEND_NAME];
                [FailedDeletedFriends removeDeletedFriends:friendName withContext:context];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"operation: %@", operation);
                NSLog(@"operation: %@", operation.responseString);
                NSLog(@"Error: %@", error);
            }];
            [mutableOperations addObject:operation];
        }
        
        NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"%lu of %lu complete", numberOfFinishedOperations, totalNumberOfOperations);
        } completionBlock:^(NSArray *operations) {
            NSLog(@"All operations in batch complete");
        }];
        [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    }
}

@end
