//
//  FailedDeletedVotes.h
//  Vote
//
//  Created by 丁 一 on 14-8-20.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Users;

@interface FailedDeletedVotes : NSManagedObject

@property (nonatomic, retain) NSNumber * voteID;
@property (nonatomic, retain) NSNumber * deleteForever;
@property (nonatomic, retain) Users *whoseDeletedVotes;

@end
