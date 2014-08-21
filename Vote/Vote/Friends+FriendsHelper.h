//
//  Friends+FriendsHelper.h
//  Vote
//
//  Created by 丁 一 on 14-3-16.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Friends.h"

@interface Friends (FriendsHelper)

+ (Friends *)fetchFriendsWithName:(NSString *)friendName withContext:(NSManagedObjectContext *)context;

+ (void)updateDatabaseWithData:(NSArray *)data withContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)insertFriendsToDatabaseWithData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)modifyFriends:(Friends *)aFriend withData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context withQueue:(NSOperationQueue *)queue;

+ (void)downloadHeadImageOfFriend:(Friends *)aFriend withUrl:(NSString *)url withQueue:(NSOperationQueue *)queue;

+ (BOOL)checkStoreDirectoryforFriend:(Friends *)aFriend ofDir:(NSString *)dir;

+ (NSString *)saveImage:(UIImage *)image ofFriend:(Friends *)aFriend withName:(NSString *)name andType:(NSString *)type inDir:(NSString *)dir;

+ (void)deleteFriends:(Friends *)aFriend withManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteFriendsOnServer:(NSString *)friendName withManagedObjectContext:(NSManagedObjectContext *)context;

+ (BOOL)deleteAllFilesOfFriend:(Friends *)aFriend;

@end
