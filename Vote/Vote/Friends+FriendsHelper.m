//
//  Friends+FriendsHelper.m
//  Vote
//
//  Created by 丁 一 on 14-3-16.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "Friends+FriendsHelper.h"
#import "CoreDataHelper.h"
#import "Users+UsersHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImage+UIImageHelper.h"
#import "FailedDeletedFriends+Helper.h"

@implementation Friends (FriendsHelper)

+ (Friends *)fetchFriendsWithName:(NSString *)friendName withContext:(NSManagedObjectContext *)context
{
    Friends *aFriend = nil;
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    if ([friendName length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whoseFriends.username == %@) AND (username == %@)", username, friendName];
        NSArray *results = [CoreDataHelper searchObjectsForEntity:FRIENDS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
        if ([results count] == 1) {
            aFriend = [results firstObject];
        } else {
            NSLog(@"friends fetch user error!");
        }
    }
    
    return aFriend;
}

+ (void)updateDatabaseWithData:(NSArray *)data withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    //get login username
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    for (NSDictionary *element in data) {
        //get the name of a friend
        NSString *friendName = [element objectForKey:SERVER_USERNAME];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(whoseFriends.username == %@) AND (username == %@)", username, friendName];
        NSArray *friends = [CoreDataHelper searchObjectsForEntity:FRIENDS withPredicate:predicate andSortKey:nil andSortAscending:YES andContext:context];
        if ([friends count] == 1) {
            Friends *aFriend = [friends firstObject];
            //modify the specific item in the database
            [Friends modifyFriends:aFriend withData:element withManagedObjectContext:context withQueue:queue];
            
        } else if ([friends count] == 0) {
            FailedDeletedFriends *aDeletedFriend = [FailedDeletedFriends fetchDeletedFriends:friendName withContext:context];
            if (aDeletedFriend == nil) {
                //create a new friends item
                [Friends insertFriendsToDatabaseWithData:element withManagedObjectContext:context withQueue:queue];
            }
        } else {
            NSLog(@"fetch friends from database error in second table view!");
        }
    }
}

+ (void)insertFriendsToDatabaseWithData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    Friends *aFriend = [NSEntityDescription insertNewObjectForEntityForName:FRIENDS inManagedObjectContext:context];
    aFriend.username = [data objectForKey:SERVER_USERNAME];
    //get login username, then hook the current user
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    aFriend.whoseFriends = [Users fetchUsersWithUsername:username withContext:context];
    NSLog(@"whose friends: %@", aFriend.whoseFriends);

    aFriend.basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
    
    if (!((NSNull *)[data objectForKey:SERVER_GENDER] == [NSNull null])) {
        aFriend.gender = [data objectForKey:SERVER_GENDER];
    }
    if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME] == [NSNull null])) {
        aFriend.screenname = [data objectForKey:SERVER_SCREENNAME];
    }
    if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME_PINYIN] == [NSNull null])) {
        aFriend.screennamePinyin = [data objectForKey:SERVER_SCREENNAME_PINYIN];
        //get first letter of pin yin
        NSString *firstLetter = [aFriend.screennamePinyin substringToIndex:1];
        aFriend.group = [firstLetter uppercaseString];
    }
    if (!((NSNull *)[data objectForKey:SERVER_USER_SIGNATURE] == [NSNull null])) {
        aFriend.signature = [data objectForKey:SERVER_USER_SIGNATURE];
    }
    if (!((NSNull *)[data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL] == [NSNull null])) {
        aFriend.thumbnailsHeadImageUrl = [data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL];
    }
    if (!((NSNull *)[data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL] == [NSNull null])) {
        aFriend.mediumHeadImageUrl = [data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL];
    }
    if (!((NSNull *)[data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL] == [NSNull null])) {
        aFriend.originalHeadImageUrl = [data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL];
    }

    aFriend.headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
    
    [Friends downloadHeadImageOfFriend:aFriend withUrl:aFriend.originalHeadImageUrl withQueue:queue];
    [Friends downloadHeadImageOfFriend:aFriend withUrl:aFriend.mediumHeadImageUrl withQueue:queue];

    
}

+ (void)modifyFriends:(Friends *)aFriend withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue
{
    NSNumber *basicInfoLastUpdateTag = [[NSNumber alloc] init];
    NSNumber *headImageLastUpdateTag = [[NSNumber alloc] init];
    basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
    headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
    //first modify the basic info
    if (![basicInfoLastUpdateTag isEqualToNumber:aFriend.basicInfoLastUpdateTag]) {
        aFriend.basicInfoLastUpdateTag = [data objectForKey:SERVER_BASIC_INFO_LAST_UPDATE_TAG];
        aFriend.username = [data objectForKey:SERVER_USERNAME];
        if (!((NSNull *)[data objectForKey:SERVER_GENDER] == [NSNull null])) {
            aFriend.gender = [data objectForKey:SERVER_GENDER];
        }
        if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME] == [NSNull null])) {
            aFriend.screenname = [data objectForKey:SERVER_SCREENNAME];
        }
        if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME_PINYIN] == [NSNull null])) {
            aFriend.screennamePinyin = [data objectForKey:SERVER_SCREENNAME_PINYIN];
            //get first letter of pin yin
            NSString *firstLetter = [aFriend.screennamePinyin substringToIndex:1];
            aFriend.group = [firstLetter uppercaseString];
        }
        if (!((NSNull *)[data objectForKey:SERVER_USER_SIGNATURE] == [NSNull null])) {
            aFriend.signature = [data objectForKey:SERVER_USER_SIGNATURE];
        }
    }
    
    // then modify the head image info
    if (![headImageLastUpdateTag isEqualToNumber:aFriend.headImageLastUpdateTag]) {
        aFriend.headImageLastUpdateTag = [data objectForKey:SERVER_HEAD_IMAGE_LAST_UPDATE_TAG];
        if (!((NSNull *)[data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL] == [NSNull null])) {
            aFriend.thumbnailsHeadImageUrl = [data objectForKey:SERVER_THUMBNAILS_HEAD_IMAGE_URL];
        }
        if (!((NSNull *)[data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL] == [NSNull null])) {
            aFriend.mediumHeadImageUrl = [data objectForKey:SERVER_MEDIUM_HEAD_IMAGE_URL];
        }
        if (!((NSNull *)[data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL] == [NSNull null])) {
            aFriend.originalHeadImageUrl = [data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL];
        }
        
        [Friends downloadHeadImageOfFriend:aFriend withUrl:aFriend.originalHeadImageUrl withQueue:queue];
        [Friends downloadHeadImageOfFriend:aFriend withUrl:aFriend.mediumHeadImageUrl withQueue:queue];
    }
}

+ (void)downloadHeadImageOfFriend:(Friends *)aFriend withUrl:(NSString *)url withQueue:(NSOperationQueue *)queue
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: image url is %@", url);
        //检查存储路径
        UIImage *tmpImage = (UIImage *)responseObject;
        if ([url isEqualToString:aFriend.originalHeadImageUrl]) {
            if ([Friends checkStoreDirectoryforFriend:aFriend ofDir:DOCUMENTS]) {
                aFriend.originalHeadImagePath = [Friends saveImage:tmpImage ofFriend:aFriend withName:ORGINAL_HEAD_IMAGE_NAME andType:IMAGE_TYPE inDir:DOCUMENTS];
            }
        } else if ([url isEqualToString:aFriend.mediumHeadImageUrl]) {
            if ([Friends checkStoreDirectoryforFriend:aFriend ofDir:DOCUMENTS]) {
                aFriend.mediumHeadImagePath = [Friends saveImage:tmpImage ofFriend:aFriend withName:MEDIUM_HEAD_IMAGE_NAME andType:IMAGE_TYPE inDir:DOCUMENTS];
            }
        } else {
            if ([Friends checkStoreDirectoryforFriend:aFriend ofDir:TEMPORARY]) {
                aFriend.originalHeadImagePath = [Friends saveImage:tmpImage ofFriend:aFriend withName:THUMBNAILS_HEAD_IMAGE_NAME andType:IMAGE_TYPE inDir:TEMPORARY];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: image url is %@", url);
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

+ (BOOL)checkStoreDirectoryforFriend:(Friends *)aFriend ofDir:(NSString *)dir
{
    BOOL success = YES;
    NSString *path;
    //create directory like .../Documents(or temp)/user/Friends/someone/
    if ([dir isEqualToString:DOCUMENTS]) {
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    } else {
        path = NSTemporaryDirectory();
    }
    NSString *userPath = [path stringByAppendingPathComponent:aFriend.whoseFriends.username];
    NSString *friendDocsPath = [userPath stringByAppendingPathComponent:FRIENDS];
    NSString *friendFilesPath = [friendDocsPath stringByAppendingPathComponent:aFriend.username];
    BOOL isDir;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:friendFilesPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:friendFilesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (success == NO) {
        NSLog(@"create Directory failed in Friends");
    }
    return success;
}

+ (NSString *)saveImage:(UIImage *)image ofFriend:(Friends *)aFriend withName:(NSString *)name andType:(NSString *)type inDir:(NSString *)dir
{
    //store image to the directory .../Documents(or temp)/user/Friends/someone/
    NSString *path;
    if ([dir isEqualToString:DOCUMENTS]) {
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    } else {
        path = NSTemporaryDirectory();
    }
    NSString *userPath = [path stringByAppendingPathComponent:aFriend.whoseFriends.username];
    NSString *friendDocsPath = [userPath stringByAppendingPathComponent:FRIENDS];
    NSString *friendFilesPath = [friendDocsPath stringByAppendingPathComponent:aFriend.username];
    [UIImage saveImage:image withFileName:name ofType:type inDirectory:friendFilesPath];
    NSString *imagePath = [friendFilesPath stringByAppendingFormat:@"/%@.%@", name, type];
    
    return imagePath;
}

+ (void)batchDownloadHeadImageOfFriend:(Friends *)aFriend withQueue:(NSOperationQueue *)queue
{
    if (aFriend.originalHeadImageUrl == nil || aFriend.mediumHeadImageUrl == nil || aFriend.thumbnailsHeadImageUrl == nil) {
        NSLog(@"friend head image download url error!");
        return;
    }
    NSArray *filesToDownload = @[aFriend.originalHeadImageUrl, aFriend.mediumHeadImageUrl, aFriend.thumbnailsHeadImageUrl];
    NSMutableArray *mutableOperations = [NSMutableArray array];
    
    for (NSString *fileURL in filesToDownload) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: image url is %@", fileURL);

            
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


+ (void)deleteFriends:(Friends *)aFriend withManagedObjectContext:(NSManagedObjectContext *)context
{
    [Friends deleteAllFilesOfFriend:aFriend];
    [context deleteObject:aFriend];
}

+ (void)deleteFriendsOnServer:(NSString *)friendName withManagedObjectContext:(NSManagedObjectContext *)context
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/delete_friends.php"];
    NSDictionary *parameters = @{SERVER_USERNAME:username, SERVER_FRIEND_NAME:friendName};
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        //如果失败，将要删除信息存入待删除列表中
        [FailedDeletedFriends insertDeletedFriends:friendName withContext:context];
    }];
}

+ (BOOL)deleteAllFilesOfFriend:(Friends *)aFriend
{
    BOOL success;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *userPath = [path stringByAppendingPathComponent:aFriend.whoseFriends.username];
    NSString *friendDocsPath = [userPath stringByAppendingPathComponent:FRIENDS];
    NSString *friendFilesPath = [friendDocsPath stringByAppendingPathComponent:aFriend.username];
    NSError *error = nil;
    success = [[NSFileManager defaultManager] removeItemAtPath:friendFilesPath error:&error];
    
    if (error) {
        NSLog(@"delete images error in Friend: %@", error);
    }
    
    return success;
}


@end
