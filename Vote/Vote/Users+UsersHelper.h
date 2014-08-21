//
//  Users+UsersHelper.h
//  Vote
//
//  Created by 丁 一 on 14-3-28.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Users.h"

@interface Users (UsersHelper)

+ (Users *)fetchUsersWithUsername:(NSString *)name withContext:(NSManagedObjectContext *)context;

+ (void)updateDatabaseWithData:(NSDictionary *)data withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;
+ (void)modifyUsers:(Users *)aUser withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;
+ (void)insertUsersToDatabaseWithData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;
+ (void)batchDownloadHeadImage:(Users *)aUser withQueue:(NSOperationQueue *)queue;
+ (BOOL)checkStoreDirectoryforUser:(Users *)aUser;
+ (NSString *)saveImage:(UIImage *)image ofUsers:(Users *)aUser withName:(NSString *)name andType:(NSString *)type;
+ (BOOL)deleteImagesOfUser:(Users *)aUser;

@end
