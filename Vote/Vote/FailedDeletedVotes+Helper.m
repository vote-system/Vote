//
//  FailedDeletedVotes+Helper.m
//  Vote
//
//  Created by 丁 一 on 14-8-19.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "FailedDeletedVotes+Helper.h"
#import "CoreDataHelper.h"
#import "Users+UsersHelper.h"
#import "AFHTTPRequestOperationManager.h"

@implementation FailedDeletedVotes (Helper)

+ (void)insertDeletedVotes:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context forever:(BOOL)forever
{
    FailedDeletedVotes *aDeletedVote = [NSEntityDescription insertNewObjectForEntityForName:FAILED_DELETED_VOTES inManagedObjectContext:context];
    aDeletedVote.voteID = voteId;
    aDeletedVote.deleteForever = [NSNumber numberWithBool:forever];
    //get login username, then hook the current user
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    aDeletedVote.whoseDeletedVotes = [Users fetchUsersWithUsername:username withContext:context];
}

+ (FailedDeletedVotes *)fetchDeletedVotes:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    FailedDeletedVotes *aDeletedVote = nil;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(voteID == %@) AND (whoseDeletedVotes.username == %@)", voteId, username];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:FAILED_DELETED_VOTES withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([results count] > 0) {
        aDeletedVote = [results firstObject];
    }
    
    return aDeletedVote;
}

+ (void)removeDeletedVotes:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    FailedDeletedVotes *aDeletedVote = [FailedDeletedVotes fetchDeletedVotes:voteId withContext:context];
    if (aDeletedVote != nil) {
        [context deleteObject:aDeletedVote];
    }
}

+ (void)batchRemoveDeletedVotesWithContext:(NSManagedObjectContext *)context
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whoseDeletedVotes.username == %@",username];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:FAILED_DELETED_VOTES withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([results count] > 0) {
        NSMutableArray *mutableOperations = [NSMutableArray array];
        for (FailedDeletedVotes *aDeletedVote in results) {
            NSDictionary *parameters = @{SERVER_USERNAME:username, SERVER_VOTE_ID:aDeletedVote.voteID};
            NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/delete_vote.php"];
            NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"operation: %@", operation);
                NSLog(@"responseObject: %@", responseObject);
                //删除指定voteID
                NSNumber *voteID = [responseObject objectForKey:SERVER_VOTE_ID];
                [FailedDeletedVotes removeDeletedVotes:voteID withContext:context];
                
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
