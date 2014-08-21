//
//  FailedDeletedFriends.h
//  Vote
//
//  Created by 丁 一 on 14-8-19.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Users;

@interface FailedDeletedFriends : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) Users *whoseDeletedFriends;

@end
