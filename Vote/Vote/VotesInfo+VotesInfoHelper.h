//
//  VotesInfo+VotesInfoHelper.h
//  Vote
//
//  Created by 丁 一 on 14-6-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "VotesInfo.h"

@interface VotesInfo (VotesInfoHelper)

+ (VotesInfo *)fetchVotesWithVoteID:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;

+ (void)updateDatabaseWithList:(NSArray *)data withContext:(NSManagedObjectContext *)context;

+ (void)insertVotesInfoToDatabaseWithData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)modifyVotesInfo:(VotesInfo *)aVote withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)updateDatabaseWithDetails:(NSDictionary *)data withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)insertVotesInfoToDatabaseWithDetails:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)modifyVotesInfo:(VotesInfo *)aVote withDetails:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)modifyVotesInfo:(VotesInfo *)aVote withAnonymousFlag:(BOOL)anonymousFlag withManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)modifyVotesInfo:(VotesInfo *)aVote withNotificationFlag:(BOOL)notificationFlag withManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)modifyVotesInfo:(VotesInfo *)aVote withDeleteForeverFlag:(BOOL)deleteForeverFlag withManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteVotesInfo:(VotesInfo *)aVote withManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteVotesInfoOnServer:(NSNumber *)voteId withManagedObjectContext:(NSManagedObjectContext *)context forever:(BOOL)forever;

@end
