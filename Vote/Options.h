//
//  Options.h
//  Vote
//
//  Created by 丁 一 on 14-8-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VotesInfo;

@interface Options : NSManagedObject

@property (nonatomic, retain) NSNumber * businessID;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * categories;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSDictionary * voters;
@property (nonatomic, retain) VotesInfo *whichVote;

@end
