//
//  FailedDeletedFriends+Helper.h
//  Vote
//
//  Created by 丁 一 on 14-8-19.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FailedDeletedFriends.h"
#import "Friends+FriendsHelper.h"

@interface FailedDeletedFriends (Helper)

+ (void)insertDeletedFriends:(NSString *)friendName withContext:(NSManagedObjectContext *)context;
+ (FailedDeletedFriends *)fetchDeletedFriends:(NSString *)friendName withContext:(NSManagedObjectContext *)context;
+ (void)removeDeletedFriends:(NSString *)friendName withContext:(NSManagedObjectContext *)context;
+ (void)batchRemoveDeletedFriendsWithContext:(NSManagedObjectContext *)context;

@end
