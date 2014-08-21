//
//  VotesInfo.h
//  Vote
//
//  Created by 丁 一 on 14-8-19.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Options, Users;

@interface VotesInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * basicUpdateFlag;
@property (nonatomic, retain) NSNumber * basicUpdateTag;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * draft;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isEnd;
@property (nonatomic, retain) NSNumber * maxChoice;
@property (nonatomic, retain) NSString * organizer;
@property (nonatomic, copy)   NSMutableArray * participants;
@property (nonatomic, copy)   NSMutableArray * preChoose;
@property (nonatomic, retain) NSNumber * anonymous;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * voteDescription;
@property (nonatomic, retain) NSNumber * voteID;
@property (nonatomic, retain) NSNumber * voteUpdateFlag;
@property (nonatomic, retain) NSNumber * voteUpdateTag;
@property (nonatomic, retain) NSNumber * thePublic;
@property (nonatomic, retain) NSNumber * notification;
@property (nonatomic, retain) NSNumber * deleteForever;
@property (nonatomic, retain) NSSet *options;
@property (nonatomic, retain) Users *whoseVote;
@end

@interface VotesInfo (CoreDataGeneratedAccessors)

- (void)addOptionsObject:(Options *)value;
- (void)removeOptionsObject:(Options *)value;
- (void)addOptions:(NSSet *)values;
- (void)removeOptions:(NSSet *)values;

@end
