//
//  Users+UsersHelper.m
//  Vote
//
//  Created by 丁 一 on 14-3-28.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "Users+UsersHelper.h"
#import "CoreDataHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImage+UIImageHelper.h"

@implementation Users (UsersHelper)

+ (Users *)fetchUsersWithUsername:(NSString *)name withContext:(NSManagedObjectContext *)context
{
    Users *user = nil;
    if ([name length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", name];
        NSArray *results = [CoreDataHelper searchObjectsForEntity:USERS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
        if ([results count] == 1) {
            user = [results firstObject];
        } else {
            NSLog(@"cannot find a user with name %@!", name);
        }
    }
    
    return user;
}

+ (void)updateDatabaseWithData:(NSDictionary *)data withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    //get login username
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    
    //get the name of a friend
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
    NSArray *users = [CoreDataHelper searchObjectsForEntity:USERS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
    if ([users count] == 1) {
        Users *aUser = [users firstObject];
        //modify the specific item in the database
        NSNumber *basicInfoLastUpdateTag = [[NSNumber alloc] init];
        NSNumber *headImageLastUpdateTag = [[NSNumber alloc] init];
        basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
        headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
        //if one of the info has been modified, modify the database
        if ([basicInfoLastUpdateTag intValue] != INITIAL_STATE || [headImageLastUpdateTag intValue] != INITIAL_STATE) {
            [Users modifyUsers:aUser withData:data withManagedObjectContext:context withQueue:queue];
        }
    } else if ([users count] == 0) {
        //create a new users item
        [Users insertUsersToDatabaseWithData:data withManagedObjectContext:context withQueue:queue];
    } else {
        NSLog(@"fetch users from database error in home tabbar!");
    }
    
}

+ (void)insertUsersToDatabaseWithData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    //if get the data from server failure after login, create a simple item
    if (data == nil) {
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud stringForKey:USERNAME];
        Users *aUser = [NSEntityDescription insertNewObjectForEntityForName:USERS inManagedObjectContext:context];
        aUser.username = username;
        return;
    }
    NSNumber *basicInfoLastUpdateTag = [[NSNumber alloc] init];
    NSNumber *headImageLastUpdateTag = [[NSNumber alloc] init];
    basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
    headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
    
    Users *aUser = [NSEntityDescription insertNewObjectForEntityForName:USERS inManagedObjectContext:context];
    
    if (!((NSNull *)[data objectForKey:SERVER_USERNAME] == [NSNull null])) {
        aUser.username = [data objectForKey:SERVER_USERNAME];
    }
    //NSLog(@"%@, %@",aUser.username, [data objectForKey:SERVER_USERNAME]);
    if (!((NSNull *)[data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG] == [NSNull null])) {
        aUser.basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
    }
    if (!((NSNull *)[data objectForKey:SERVER_GENDER] == [NSNull null])) {
        aUser.gender = [data objectForKey:SERVER_GENDER];
    }
    if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME] == [NSNull null])) {
        aUser.screenname = [data objectForKey:SERVER_SCREENNAME];
    }
    if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME_PINYIN] == [NSNull null])) {
        aUser.screennamePinyin = [data objectForKey:SERVER_SCREENNAME_PINYIN];
        //get first letter of pin yin
        NSString *firstLetter = [aUser.screennamePinyin substringToIndex:1];
        aUser.group = [firstLetter uppercaseString];
    }
    if (!((NSNull *)[data objectForKey:SERVER_USER_SIGNATURE] == [NSNull null])) {
        aUser.signature = [data objectForKey:SERVER_USER_SIGNATURE];
    }
    if (!((NSNull *)[data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL] == [NSNull null])) {
        aUser.thumbnailsHeadImageUrl = [data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL];
    }
    if (!((NSNull *)[data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL] == [NSNull null])) {
        aUser.mediumHeadImageUrl = [data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL];
    }
    if (!((NSNull *)[data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL] == [NSNull null])) {
        aUser.originalHeadImageUrl = [data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL];
    }
    if (!((NSNull *)[data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG] == [NSNull null])) {
        aUser.headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
        [Users batchDownloadHeadImage:aUser withQueue:queue];
    }
}

+ (void)modifyUsers:(Users *)aUser withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    NSNumber *basicInfoLastUpdateTag = [[NSNumber alloc] init];
    NSNumber *headImageLastUpdateTag = [[NSNumber alloc] init];
    basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
    headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
    //first modify the basic info
    if ([basicInfoLastUpdateTag intValue] != INITIAL_STATE) {
        if (![basicInfoLastUpdateTag isEqualToNumber:aUser.basicInfoLastUpdateTag]) {
            aUser.basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
            aUser.username = [data objectForKey:SERVER_USERNAME];
            if (!((NSNull *)[data objectForKey:SERVER_GENDER] == [NSNull null])) {
                aUser.gender = [data objectForKey:SERVER_GENDER];
            }
            if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME] == [NSNull null])) {
                aUser.screenname = [data objectForKey:SERVER_SCREENNAME];
            }
            if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME_PINYIN] == [NSNull null])) {
                aUser.screennamePinyin = [data objectForKey:SERVER_SCREENNAME_PINYIN];
                //get first letter of pin yin
                NSString *firstLetter = [aUser.screennamePinyin substringToIndex:1];
                aUser.group = [firstLetter uppercaseString];
            }
            if (!((NSNull *)[data objectForKey:SERVER_USER_SIGNATURE] == [NSNull null])) {
                aUser.signature = [data objectForKey:SERVER_USER_SIGNATURE];
            }
        }
    }
    // then modify the head image info
    if ([headImageLastUpdateTag intValue] != INITIAL_STATE) {
        if (![headImageLastUpdateTag isEqualToNumber:aUser.headImageLastUpdateTag]) {
            aUser.headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
            if (!((NSNull *)[data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL] == [NSNull null])) {
                aUser.thumbnailsHeadImageUrl = [data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL];
            }
            if (!((NSNull *)[data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL] == [NSNull null])) {
                aUser.mediumHeadImageUrl = [data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL];
            }
            if (!((NSNull *)[data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL] == [NSNull null])) {
                aUser.originalHeadImageUrl = [data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL];
            }
            [Users batchDownloadHeadImage:aUser withQueue:queue];
        }
    }
}

+ (void)batchDownloadHeadImage:(Users *)aUser withQueue:(NSOperationQueue *)queue
{
    if (aUser.originalHeadImageUrl == nil || aUser.mediumHeadImageUrl == nil || aUser.thumbnailsHeadImageUrl == nil) {
        NSLog(@"user head image download url error!");
        return;
    }
    NSArray *filesToDownload = @[aUser.originalHeadImageUrl, aUser.mediumHeadImageUrl, aUser.thumbnailsHeadImageUrl];
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSString *fileURL in filesToDownload) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: image url is %@", fileURL);
            //设置存储路径
            //UIImage *tmpImage = [UIImage imageWithData:(NSData *)responseObject scale:2.0];
            UIImage *tmpImage = (UIImage *)responseObject;
            if (tmpImage.size.width == ORIGINAL_HEAD_IMAGE_SIZE) {
                if ([Users checkStoreDirectoryforUser:aUser]) {
                    aUser.originalHeadImagePath = [Users saveImage:tmpImage ofUsers:aUser withName:ORGINAL_HEAD_IMAGE_NAME andType:IMAGE_TYPE];
                    NSLog(@"originalHeadImagePath: %@", aUser.originalHeadImagePath);
                }
            } else if (tmpImage.size.width == MEDIUM_HEAD_IMAGE_SIZE) {
                if ([Users checkStoreDirectoryforUser:aUser]) {
                    aUser.mediumHeadImagePath = [Users saveImage:tmpImage ofUsers:aUser withName:MEDIUM_HEAD_IMAGE_NAME andType:IMAGE_TYPE];
                    NSLog(@"mediumHeadImagePath: %@", aUser.mediumHeadImagePath);
                }
            } else {
                if ([Users checkStoreDirectoryforUser:aUser]) {
                    aUser.thumbnailsHeadImagePath = [Users saveImage:tmpImage ofUsers:aUser withName:THUMBNAILS_HEAD_IMAGE_NAME andType:IMAGE_TYPE];
                    NSLog(@"thumbnailsHeadImagePath: %@", aUser.thumbnailsHeadImagePath);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failure: image url is %@", fileURL);
        }];
        [mutableOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%ld of %ld complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All operations in batch complete");
    }];
    [queue addOperations:operations waitUntilFinished:NO];
}

+ (BOOL)checkStoreDirectoryforUser:(Users *)aUser
{
    BOOL success = YES;
    //create directory like .../Documents/user/Personal/
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *userPath = [path stringByAppendingPathComponent:aUser.username];
    NSString *personalPath = [userPath stringByAppendingPathComponent:PERSONAL];
    NSLog(@"personal path: %@", personalPath);
    BOOL isDir;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:personalPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:personalPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (success == NO) {
        NSLog(@"create Directory failed in Users");
    }
    return success;
}

+ (NSString *)saveImage:(UIImage *)image ofUsers:(Users *)aUser withName:(NSString *)name andType:(NSString *)type
{
    //store into directory .../Documents/user/Personal/
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [[path stringByAppendingPathComponent:aUser.username] stringByAppendingPathComponent:PERSONAL];
    [UIImage saveImage:image withFileName:name ofType:type inDirectory:filePath];
    NSString *imagePath = [filePath stringByAppendingFormat:@"/%@.%@", name, type];
    NSLog(@"image path: %@", imagePath);
    return imagePath;
}

+ (BOOL)deleteImagesOfUser:(Users *)aUser
{
    BOOL success;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [[path stringByAppendingPathComponent:aUser.username] stringByAppendingPathComponent:PERSONAL];
    NSError *error = nil;
    success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    if (error) {
        NSLog(@"delete images error in Friend: %@", error);
    }
    
    return success;
}

@end
