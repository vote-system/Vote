//
//  Options+OptionsHelper.h
//  Vote
//
//  Created by 丁 一 on 14-6-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Options.h"

@interface Options (OptionsHelper)

+ (NSArray *)fetchOptionsWithVoteID:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context;

+ (void)updateDatabaseWithBasic:(NSArray *)data ofVote:(VotesInfo *)aVote withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)insertOptionsToDatabaseWithData:(NSDictionary *)data ofVote:(VotesInfo *)aVote withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)modifyOptions:(Options *)aOption withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)updateVotersWithOptions:(NSDictionary *)options ofVote:(VotesInfo *)aVote withContext:(NSManagedObjectContext *)context;

+ (void)deleteOptionsWithVoteId:(NSNumber *)voteId withManagedObjectContext:(NSManagedObjectContext *)context;
//+ (void)batchDownloadImageOfOptions:(Options *)aOption withQueue:(NSOperationQueue *)queue;

//+ (BOOL)checkStoreDirectoryforOption:(Options *)aOption;

//+ (NSString *)saveImage:(UIImage *)image ofOption:(Options *)aOption withName:(NSString *)name andType:(NSString *)type;

@end
