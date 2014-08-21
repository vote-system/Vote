//
//  VotesInfo+VotesInfoHelper.m
//  Vote
//
//  Created by 丁 一 on 14-6-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VotesInfo+VotesInfoHelper.h"
#import "CoreDataHelper.h"
#import "Users+UsersHelper.h"
#import "Options+OptionsHelper.h"
#import "FailedDeletedVotes+Helper.h"
#import "AFHTTPRequestOperationManager.h"

@implementation VotesInfo (VotesInfoHelper)

+ (VotesInfo *)fetchVotesWithVoteID:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    VotesInfo *aVote = nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"voteID == %@", voteId];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_INFO withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([results count] == 1) {
        aVote = [results firstObject];
        NSLog(@"Find a vote in the database!");
    } else if ([results count] == 0){
        NSLog(@"No vote find in the database!");
    } else {
        NSLog(@"Fetch vote error in the database!");
    }
    
    return aVote;
}

+ (void)updateDatabaseWithList:(NSArray *)data withContext:(NSManagedObjectContext *)context
{
    VotesInfo *aVote = nil;
    for (NSDictionary *element in data) {
        NSNumber *voteId = [element objectForKey:SERVER_VOTE_ID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"voteID == %@", voteId];
        NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_INFO withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
        if ([results count] == 1) {
            aVote = [results firstObject];
            [VotesInfo modifyVotesInfo:aVote withData:element withManagedObjectContext:context];
            NSLog(@"Find a vote in the database!");
        } else if ([results count] == 0){
            FailedDeletedVotes *aDeletedVote = [FailedDeletedVotes fetchDeletedVotes:voteId withContext:context];
            if (aDeletedVote == nil) {
                NSLog(@"No vote find in the database, insert a new one!");
                [VotesInfo insertVotesInfoToDatabaseWithData:element withManagedObjectContext:context];
            } 
        } else {
            NSLog(@"Fetch vote error in the database!");
        }

    }
}

+ (void)insertVotesInfoToDatabaseWithData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context
{
    NSLog(@"data: %@",data);
    VotesInfo *aVote = [NSEntityDescription insertNewObjectForEntityForName:VOTES_INFO inManagedObjectContext:context];
    
    //get login username, then hook the current user
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    aVote.whoseVote = [Users fetchUsersWithUsername:username withContext:context];
    
    if ( [data objectForKey:SERVER_VOTE_ID] != nil  && (NSNull *)[data objectForKey:SERVER_VOTE_ID] != [NSNull null] ) {
        aVote.voteID = [data objectForKey:SERVER_VOTE_ID];
    }
    if ( [data objectForKey:SERVER_VOTE_TITLE] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_TITLE] != [NSNull null] ) {
        aVote.title = [data objectForKey:SERVER_VOTE_TITLE];
    }
    if ( [data objectForKey:SERVER_VOTE_IMAGE_URL] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_IMAGE_URL] != [NSNull null] ) {
        aVote.imageUrl = [data objectForKey:SERVER_VOTE_IMAGE_URL];
    }
    if ( [data objectForKey:SERVER_VOTE_ORGANIZER] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ORGANIZER] != [NSNull null] ) {
        aVote.organizer = [data objectForKey:SERVER_VOTE_ORGANIZER];
    }
    if ( [data objectForKey:SERVER_VOTE_END_TIME] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_END_TIME] != [NSNull null] ) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:SERVER_VOTE_END_TIME] doubleValue]];
        aVote.endTime = date;
        NSDate *now = [NSDate date];
        if ([aVote.endTime earlierDate:now] == aVote.endTime) {
            aVote.isEnd = [NSNumber numberWithBool:YES];
        } else {
            aVote.isEnd = [NSNumber numberWithBool:NO];
        }
    }
    if ( [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != [NSNull null] ) {
        aVote.basicUpdateTag = [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP];
    }
    if ( [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != [NSNull null] ) {
        aVote.voteUpdateTag = [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP];
    }
    if ( [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != [NSNull null] ) {
        aVote.anonymous = [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG];
    }
    if ( [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != [NSNull null] ) {
        aVote.thePublic = [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG];
    }
    if ( [data objectForKey:SERVER_VOTE_NOTIFICATION] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_NOTIFICATION] != [NSNull null] ) {
        aVote.notification = [data objectForKey:SERVER_VOTE_NOTIFICATION];
    }
    aVote.basicUpdateFlag = [NSNumber numberWithBool:YES];
    aVote.voteUpdateFlag = [NSNumber numberWithBool:NO];
    aVote.draft = [NSNumber numberWithBool:NO];
    aVote.deleteForever = [NSNumber numberWithBool:NO];
}

+ (void)modifyVotesInfo:(VotesInfo *)aVote withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context
{
    NSNumber *basicUpdateTag;
    NSNumber *voteUpdateTag;
    
    if ( [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != [NSNull null] ) {
        basicUpdateTag = [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP];
    } else {
        NSLog(@"timestamp error!");
        return;
    }
    if ( [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != [NSNull null] ) {
        voteUpdateTag = [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP];
    } else {
        NSLog(@"timestamp error!");
        return;
    }
    if (![aVote.basicUpdateTag isEqualToNumber:basicUpdateTag]) {
        //当有更新发生，设置updateFlag
        aVote.basicUpdateFlag = [NSNumber numberWithBool:YES];
        //简单更新vote数据
        aVote.basicUpdateTag = basicUpdateTag;
        if ( [data objectForKey:SERVER_VOTE_ID] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ID] != [NSNull null] ) {
            aVote.voteID = [data objectForKey:SERVER_VOTE_ID];
        }
        if ( [data objectForKey:SERVER_VOTE_TITLE] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_TITLE] != [NSNull null] ) {
            aVote.title = [data objectForKey:SERVER_VOTE_TITLE];
        }
        if ( [data objectForKey:SERVER_VOTE_ORGANIZER] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ORGANIZER] != [NSNull null] ) {
            aVote.organizer = [data objectForKey:SERVER_VOTE_ORGANIZER];
        }
        if ( [data objectForKey:SERVER_VOTE_IMAGE_URL] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_IMAGE_URL] != [NSNull null] ) {
            aVote.imageUrl = [data objectForKey:SERVER_VOTE_IMAGE_URL];
        }
        if ( [data objectForKey:SERVER_VOTE_START_TIME] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_START_TIME] != [NSNull null] ) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:SERVER_VOTE_START_TIME] doubleValue]];
            aVote.startTime = date;
        }
        if ( [data objectForKey:SERVER_VOTE_END_TIME] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_END_TIME] != [NSNull null] ) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:SERVER_VOTE_END_TIME] doubleValue]];
            aVote.endTime = date;
            NSDate *now = [NSDate date];
            if ([aVote.endTime earlierDate:now] == aVote.endTime) {
                aVote.isEnd = [NSNumber numberWithBool:YES];
            } else {
                aVote.isEnd = [NSNumber numberWithBool:NO];
            }
        }
        if ([data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != [NSNull null] ) {
            aVote.basicUpdateTag = [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP];
        }
        if ( [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != [NSNull null] ) {
            aVote.anonymous = [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG];
        }
        if ( [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != [NSNull null] ) {
            aVote.thePublic = [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG];
        }
        if ( [data objectForKey:SERVER_VOTE_NOTIFICATION] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_NOTIFICATION] != [NSNull null] ) {
            aVote.notification = [data objectForKey:SERVER_VOTE_NOTIFICATION];
        }
    }
    
    if (![aVote.voteUpdateTag isEqualToNumber:voteUpdateTag]) {
        //当有更新发生，设置updateFlag
        aVote.voteUpdateTag = voteUpdateTag;
        aVote.voteUpdateFlag = [NSNumber numberWithBool:YES];
    }

}

+ (void)updateDatabaseWithDetails:(NSDictionary *)data withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    VotesInfo *aVote = nil;
    NSNumber *voteId = [data objectForKey:SERVER_VOTE_ID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"voteID == %@", voteId];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_INFO withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([results count] == 1) {
        aVote = [results firstObject];
        [VotesInfo modifyVotesInfo:aVote withDetails:data withManagedObjectContext:context withQueue:queue];
    } else {
        NSLog(@"update database with details error!");
    }
}

//当创建新的投票时使用
+ (void)insertVotesInfoToDatabaseWithDetails:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    VotesInfo *aVote = [NSEntityDescription insertNewObjectForEntityForName:VOTES_INFO inManagedObjectContext:context];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    aVote.whoseVote = [Users fetchUsersWithUsername:username withContext:context];
    
    if ( [data objectForKey:SERVER_VOTE_ID] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ID] != [NSNull null] ) {
        aVote.voteID = [data objectForKey:SERVER_VOTE_ID];
    }
    if ( [data objectForKey:SERVER_VOTE_TITLE] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_TITLE] != [NSNull null] ) {
        aVote.title = [data objectForKey:SERVER_VOTE_TITLE];
    }
    if ( [data objectForKey:SERVER_VOTE_ORGANIZER] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ORGANIZER] != [NSNull null] ) {
        aVote.organizer = [data objectForKey:SERVER_VOTE_ORGANIZER];
    }
    if ( [data objectForKey:SERVER_VOTE_DESCRIPTION] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_DESCRIPTION] != [NSNull null] ) {
        aVote.voteDescription = [data objectForKey:SERVER_VOTE_DESCRIPTION];
    }
    if ( [data objectForKey:SERVER_VOTE_IMAGE_URL] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_IMAGE_URL] != [NSNull null] ) {
        aVote.imageUrl = [data objectForKey:SERVER_VOTE_IMAGE_URL];
    }
    if ( [data objectForKey:SERVER_VOTE_START_TIME] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_START_TIME] != [NSNull null] ) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:SERVER_VOTE_START_TIME] doubleValue]];
        aVote.startTime = date;
    }
    if ( [data objectForKey:SERVER_VOTE_END_TIME] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_END_TIME] != [NSNull null] ) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:SERVER_VOTE_END_TIME] doubleValue]];
        aVote.endTime = date;
        NSDate *now = [NSDate date];
        if ([aVote.endTime earlierDate:now] == aVote.endTime) {
            aVote.isEnd = [NSNumber numberWithBool:YES];
        } else {
            aVote.isEnd = [NSNumber numberWithBool:NO];
        }
    }
    if ( [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != [NSNull null] ) {
        aVote.basicUpdateTag = [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP];
    }
    if ( [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != [NSNull null] ) {
        aVote.voteUpdateTag = [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP];
    }
    if ( [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != [NSNull null] ) {
        aVote.anonymous = [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG];
    }
    if ( [data objectForKey:SERVER_VOTE_MAX_CHOICE] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_MAX_CHOICE] != [NSNull null] ) {
        aVote.maxChoice = [data objectForKey:SERVER_VOTE_MAX_CHOICE];
    }
    if ( [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != [NSNull null] ) {
        aVote.thePublic = [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG];
    }
    if ( [data objectForKey:SERVER_VOTE_PARTICIPANTS] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_PARTICIPANTS] != [NSNull null] ) {
        aVote.participants = [NSMutableArray arrayWithArray:[data objectForKey:SERVER_VOTE_PARTICIPANTS]];
        NSLog(@"paticipants:%@", aVote.participants);
    }
    if ( [data objectForKey:SERVER_VOTE_NOTIFICATION] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_NOTIFICATION] != [NSNull null] ) {
        aVote.notification = [data objectForKey:SERVER_VOTE_NOTIFICATION];
    }
    aVote.basicUpdateFlag = [NSNumber numberWithBool:YES];
    aVote.voteUpdateFlag = [NSNumber numberWithBool:NO];
    aVote.deleteForever = [NSNumber numberWithBool:NO];
    aVote.draft = [NSNumber numberWithBool:NO];
    //插入options
    if ( [data objectForKey:SERVER_VOTE_OPTIONS] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_OPTIONS] != [NSNull null] ) {
        NSArray *options = [NSArray arrayWithArray:(NSArray *)[data objectForKey:SERVER_VOTE_OPTIONS]];
        [Options updateDatabaseWithBasic:options ofVote:aVote withContext:context withQueue:queue];
    }
}

+ (void)modifyVotesInfo:(VotesInfo *)aVote withDetails:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    //当投票完成后，先检测时间戳是否更新
    NSNumber *basicUpdateTag;
    NSNumber *voteUpdateTag;
    if ( [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != [NSNull null] ) {
        basicUpdateTag = [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP];
    } else {
        NSLog(@"timestamp error!");
        return;
    }
    if ( [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != [NSNull null] ) {
        voteUpdateTag = [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP];
    } else {
        NSLog(@"timestamp error!");
        return;
    }
    
    if (![aVote.basicUpdateTag isEqualToNumber:basicUpdateTag]) {
        //当有更新发生，设置updateFlag
        aVote.basicUpdateTag = basicUpdateTag;
        aVote.basicUpdateFlag = [NSNumber numberWithBool:YES];
    }
    if (![aVote.voteUpdateTag isEqualToNumber:voteUpdateTag]) {
        //当有更新发生，设置updateFlag
        aVote.voteUpdateTag = voteUpdateTag;
        aVote.voteUpdateFlag = [NSNumber numberWithBool:YES];
    }
    
    if ([aVote.basicUpdateFlag boolValue] == YES) {
        
        aVote.basicUpdateFlag = [NSNumber numberWithBool:NO];
        
        if ( [data objectForKey:SERVER_VOTE_ID] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ID] != [NSNull null] ) {
            aVote.voteID = [data objectForKey:SERVER_VOTE_ID];
        }
        if ( [data objectForKey:SERVER_VOTE_TITLE] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_TITLE] != [NSNull null] ) {
            aVote.title = [data objectForKey:SERVER_VOTE_TITLE];
        }
        if ( [data objectForKey:SERVER_VOTE_ORGANIZER] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ORGANIZER] != [NSNull null] ) {
            aVote.organizer = [data objectForKey:SERVER_VOTE_ORGANIZER];
        }
        if ( [data objectForKey:SERVER_VOTE_DESCRIPTION] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_DESCRIPTION] != [NSNull null] ) {
            aVote.voteDescription = [data objectForKey:SERVER_VOTE_DESCRIPTION];
        }
        if ( [data objectForKey:SERVER_VOTE_IMAGE_URL] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_IMAGE_URL] != [NSNull null] ) {
            aVote.imageUrl = [data objectForKey:SERVER_VOTE_IMAGE_URL];
        }
        if ( [data objectForKey:SERVER_VOTE_START_TIME] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_START_TIME] != [NSNull null] ) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:SERVER_VOTE_START_TIME] doubleValue]];
            aVote.startTime = date;
        }
        if ( [data objectForKey:SERVER_VOTE_END_TIME] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_END_TIME] != [NSNull null] ) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:SERVER_VOTE_END_TIME] doubleValue]];
            aVote.endTime = date;
            NSDate *now = [NSDate date];
            if ([aVote.endTime earlierDate:now] == aVote.endTime) {
                aVote.isEnd = [NSNumber numberWithBool:YES];
            } else {
                aVote.isEnd = [NSNumber numberWithBool:NO];
            }
        }
        if ( [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP] != [NSNull null] ) {
            aVote.basicUpdateTag = [data objectForKey:SERVER_VOTE_BASIC_TIMESTAMP];
        }
        if ( [data objectForKey:SERVER_VOTE_PARTICIPANTS] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_PARTICIPANTS] != [NSNull null] ) {
            aVote.participants = [NSMutableArray arrayWithArray:(NSArray *)[data objectForKey:SERVER_VOTE_PARTICIPANTS]];
            NSLog(@"participants:%@",aVote.participants);
        }
        if ( [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG] != [NSNull null] ) {
            aVote.anonymous = [data objectForKey:SERVER_VOTE_ANONYMOUS_FLAG];
        }
        if ( [data objectForKey:SERVER_VOTE_MAX_CHOICE] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_MAX_CHOICE] != [NSNull null] ) {
            aVote.maxChoice = [data objectForKey:SERVER_VOTE_MAX_CHOICE];
        }
        if ( [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG] != [NSNull null] ) {
            aVote.thePublic = [data objectForKey:SERVER_VOTE_THE_PUBLIC_FLAG];
        }
        if ( [data objectForKey:SERVER_VOTE_NOTIFICATION] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_NOTIFICATION] != [NSNull null] ) {
            aVote.notification = [data objectForKey:SERVER_VOTE_NOTIFICATION];
        }
        
        //更新options
        if ( [data objectForKey:SERVER_VOTE_OPTIONS] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_OPTIONS] != [NSNull null] ) {
            NSArray *options = [NSArray arrayWithArray:(NSArray *)[data objectForKey:SERVER_VOTE_OPTIONS]];
            [Options updateDatabaseWithBasic:options ofVote:aVote withContext:context withQueue:queue];
        }
    }
    if ([aVote.voteUpdateFlag boolValue] == YES) {
        aVote.voteUpdateFlag = [NSNumber numberWithBool:NO];
        if ( [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP] != [NSNull null] ) {
            aVote.voteUpdateTag = [data objectForKey:SERVER_VOTE_VOTE_TIMESTAMP];
        }
        //更新选项的投票人
        if ( [data objectForKey:SERVER_VOTE_DETAIL] != nil && (NSNull *)[data objectForKey:SERVER_VOTE_DETAIL] != [NSNull null] ) {
            NSDictionary *options = (NSDictionary *)[data objectForKey:SERVER_VOTE_DETAIL];
            [Options updateVotersWithOptions:options ofVote:aVote withContext:context];
        }
        
    }
}

+ (void)modifyVotesInfo:(VotesInfo *)aVote withAnonymousFlag:(BOOL)anonymousFlag withManagedObjectContext:(NSManagedObjectContext *)context
{
    aVote.anonymous = [NSNumber numberWithBool:anonymousFlag];
}

+ (void)modifyVotesInfo:(VotesInfo *)aVote withNotificationFlag:(BOOL)notificationFlag withManagedObjectContext:(NSManagedObjectContext *)context
{
    aVote.notification = [NSNumber numberWithBool:notificationFlag];
}

+ (void)modifyVotesInfo:(VotesInfo *)aVote withDeleteForeverFlag:(BOOL)deleteForeverFlag withManagedObjectContext:(NSManagedObjectContext *)context
{
    aVote.deleteForever = [NSNumber numberWithBool:deleteForeverFlag];
}

+ (void)deleteVotesInfo:(VotesInfo *)aVote withManagedObjectContext:(NSManagedObjectContext *)context
{
    //删除选项
    [Options deleteOptionsWithVoteId:aVote.voteID withManagedObjectContext:context];
    [context deleteObject:aVote];
    
}

+ (void)deleteVotesInfoOnServer:(NSNumber *)voteId withManagedObjectContext:(NSManagedObjectContext *)context forever:(BOOL)forever
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/delete_votes.php"];
    NSDictionary *parameters = @{SERVER_USERNAME:username, SERVER_VOTE_ID:voteId};
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        //如果失败，将要删除信息存入待删除列表中
        [context performBlock:^{
            [FailedDeletedVotes insertDeletedVotes:voteId withContext:context forever:forever];
        }];
    }];
}

@end
