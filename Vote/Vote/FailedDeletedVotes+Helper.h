//
//  FailedDeletedVotes+Helper.h
//  Vote
//
//  Created by 丁 一 on 14-8-19.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FailedDeletedVotes.h"
#import "VotesInfo+VotesInfoHelper.h"

@interface FailedDeletedVotes (Helper)

+ (void)insertDeletedVotes:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context forever:(BOOL)forever;
+ (FailedDeletedVotes *)fetchDeletedVotes:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;
+ (void)removeDeletedVotes:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;
+ (void)batchRemoveDeletedVotesWithContext:(NSManagedObjectContext *)context;

@end
