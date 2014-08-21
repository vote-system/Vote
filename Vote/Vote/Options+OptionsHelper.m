//
//  Options+OptionsHelper.m
//  Vote
//
//  Created by 丁 一 on 14-6-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "Options+OptionsHelper.h"
#import "CoreDataHelper.h"
#import "VotesInfo+VotesInfoHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "Users+UsersHelper.h"
#import "UIImage+UIImageHelper.h"

@implementation Options (OptionsHelper)

+ (NSArray *)fetchOptionsWithVoteID:(NSNumber *)voteId withContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whichVote.voteID == %@", voteId];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_OPTIONS withPredicate:predicate andSortKey:VOTE_OPTIONS_ORDER andSortAscending:YES andContext:context];
    
    return results;
}

+ (void)updateDatabaseWithBasic:(NSArray *)data ofVote:(VotesInfo *)aVote withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    Options *aOption = nil;
    for (NSDictionary *element in data) {
        NSString *order = [element objectForKey:SERVER_OPTIONS_ORDER];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whichVote.voteID == %@) AND (order == %@)", aVote.voteID, order];
        NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_OPTIONS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
        if ([results count] == 1) {
            aOption = [results firstObject];
            //modify the option
            [Options modifyOptions:aOption withData:element withManagedObjectContext:context withQueue:queue];
        } else if ([results count] == 0) {
            //insert a new option
            [Options insertOptionsToDatabaseWithData:element ofVote:aVote withManagedObjectContext:context withQueue:queue];
        } else {
            NSLog(@"update database with options error!");
        }
    }

}

+ (void)insertOptionsToDatabaseWithData:(NSDictionary *)data ofVote:(VotesInfo *)aVote withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    Options *aOption = [NSEntityDescription insertNewObjectForEntityForName:VOTES_OPTIONS inManagedObjectContext:context];
    aOption.whichVote = aVote;
    
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_NAME] == [NSNull null]) ) {
        aOption.name = [data objectForKey:SERVER_OPTIONS_NAME];
    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_BUSINESS_ID] == [NSNull null]) ) {
        if ([[data objectForKey:SERVER_OPTIONS_BUSINESS_ID] isKindOfClass:[NSString class]]) {
            NSString *businessId = [data objectForKey:SERVER_OPTIONS_BUSINESS_ID];
            //将NSString转化为NSNumber
            NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
            [format setNumberStyle:NSNumberFormatterDecimalStyle];
            aOption.businessID = [format numberFromString:businessId];
        } else {
            aOption.businessID = [data objectForKey:SERVER_OPTIONS_BUSINESS_ID];
        }

    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_ADDRESS] == [NSNull null]) ) {
        aOption.address = [data objectForKey:SERVER_OPTIONS_ADDRESS];
    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_CATEGORY] == [NSNull null]) ) {
        aOption.categories = [data objectForKey:SERVER_OPTIONS_CATEGORY];
    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_ORDER] == [NSNull null]) ) {
        aOption.order = [data objectForKey:SERVER_OPTIONS_ORDER];
    }
}

+ (void)modifyOptions:(Options *)aOption withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_NAME] == [NSNull null]) ) {
        aOption.name = [data objectForKey:SERVER_OPTIONS_NAME];
    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_BUSINESS_ID] == [NSNull null]) ) {
        if ([[data objectForKey:SERVER_OPTIONS_BUSINESS_ID] isKindOfClass:[NSString class]]) {
            NSString *businessId = [data objectForKey:SERVER_OPTIONS_BUSINESS_ID];
            //将NSString转化为NSNumber
            NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
            [format setNumberStyle:NSNumberFormatterDecimalStyle];
            aOption.businessID = [format numberFromString:businessId];
        } else {
            aOption.businessID = [data objectForKey:SERVER_OPTIONS_BUSINESS_ID];
        }
    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_ADDRESS] == [NSNull null]) ) {
        aOption.address = [data objectForKey:SERVER_OPTIONS_ADDRESS];
    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_CATEGORY] == [NSNull null]) ) {
        aOption.categories = [data objectForKey:SERVER_OPTIONS_CATEGORY];
    }
    if (!((NSNull *)[data objectForKey:SERVER_OPTIONS_ORDER] == [NSNull null]) ) {
        aOption.order = [data objectForKey:SERVER_OPTIONS_ORDER];
    }

}

+ (void)updateVotersWithOptions:(NSDictionary *)options ofVote:(VotesInfo *)aVote withContext:(NSManagedObjectContext *)context
{
    Options *aOption = nil;
    for (id key in options) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whichVote.voteID == %@) AND (order == %@)", aVote.voteID, key];
        NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_OPTIONS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
        if ([results count] == 1) {
            aOption = [results firstObject];
            //modify the voters
            NSMutableDictionary *updatedDict = [aOption.voters mutableCopy];
            [updatedDict removeAllObjects];
            if ((NSNull *) [options objectForKey:key] != [NSNull null]) {
                updatedDict = (NSMutableDictionary *)[options objectForKey:key];
            }
            aOption.voters = [updatedDict copy];
            NSLog(@"voters:%@", aOption.voters);
        } else {
            NSLog(@"update database with voters error!");
        }
    }
    
}

+ (void)deleteOptionsWithVoteId:(NSNumber *)voteId withManagedObjectContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whichVote.voteID == %@", voteId];
    NSArray *results = [CoreDataHelper searchObjectsForEntity:VOTES_OPTIONS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    for (Options *aOption in results) {
        [context deleteObject:aOption];
    }
    
}


/*
+ (void)batchDownloadImageOfOptions:(Options *)aOption withQueue:(NSOperationQueue *)queue
{
    //store image to the directory .../Documents/user/Votes/##VoteId##/A/...
    if ( aOption.photoURL == nil && aOption.ratingImgURL == nil) {
        return;
    }
    
    NSArray *filesToDownload = @[aOption.photoURL, aOption.ratingImgURL];
    NSMutableArray *mutableOperations = [NSMutableArray array];
    
    for (NSString *fileURL in filesToDownload) {
        if (fileURL == nil) {
            continue;
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: image url is %@", fileURL);
            NSLog(@"Success: request.URL is %@", operation.request.URL);
            NSLog(@"Success: response.URL is %@", operation.response.URL);
            UIImage *tmpImage = (UIImage *)responseObject;
            if ([[operation.response.URL absoluteString] isEqualToString:aOption.photoURL]) {
                if ([Options checkStoreDirectoryforOption:aOption]) {
                    aOption.photoPath = [Options saveImage:tmpImage ofOption:aOption withName:VOTE_OPTIONS_PHOTO_NAME andType:IMAGE_TYPE];
                    NSLog(@"photoPath: %@", aOption.photoPath);
                }
            }
            if ([[operation.response.URL absoluteString] isEqualToString:aOption.ratingImgURL]) {
                if ([Options checkStoreDirectoryforOption:aOption]) {
                    aOption.photoPath = [Options saveImage:tmpImage ofOption:aOption withName:VOTE_OPTIONS_RATING_IMG_NAME andType:IMAGE_TYPE];
                    NSLog(@"photoPath: %@", aOption.photoPath);
                }
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failure: image url is %@", fileURL);
        }];
        [mutableOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All operations in batch complete");
    }];
    [queue addOperations:operations waitUntilFinished:NO];
}

+ (BOOL)checkStoreDirectoryforOption:(Options *)aOption
{
    BOOL success = YES;
    //create directory like... .../Documents/user/Votes/##VoteId##/A/...
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *userPath = [path stringByAppendingPathComponent:aOption.whichVote.whoseVote.username];
    NSString *votesPath = [[userPath stringByAppendingPathComponent:VOTES] stringByAppendingPathComponent:[aOption.whichVote.voteID stringValue]];
    NSString *optionsPath = [votesPath stringByAppendingPathComponent:aOption.order];
    NSLog(@"options path: %@", optionsPath);
    BOOL isDir;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:optionsPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:optionsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (success == NO) {
        NSLog(@"create Directory failed in Users");
    }
    return success;
}

+ (NSString *)saveImage:(UIImage *)image ofOption:(Options *)aOption withName:(NSString *)name andType:(NSString *)type
{
    //store into directory .../Documents/user/Personal/
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *userPath = [path stringByAppendingPathComponent:aOption.whichVote.whoseVote.username];
    NSString *votesPath = [[userPath stringByAppendingPathComponent:VOTES] stringByAppendingPathComponent:[aOption.whichVote.voteID stringValue]];
    NSString *optionsPath = [votesPath stringByAppendingPathComponent:aOption.order];
    
    [UIImage saveImage:image withFileName:name ofType:type inDirectory:optionsPath];
    NSString *imagePath = [optionsPath stringByAppendingFormat:@"/%@.%@", name, type];
    NSLog(@"image path: %@", imagePath);
    return imagePath;
}
*/
@end
