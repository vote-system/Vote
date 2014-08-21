//
//  Friends.h
//  Vote
//
//  Created by 丁 一 on 14-8-11.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Users;

@interface Friends : NSManagedObject

@property (nonatomic, retain) NSNumber * basicInfoLastUpdateTag;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * headImageLastUpdateTag;
@property (nonatomic, retain) NSString * mediumHeadImagePath;
@property (nonatomic, retain) NSString * mediumHeadImageUrl;
@property (nonatomic, retain) NSString * originalHeadImagePath;
@property (nonatomic, retain) NSString * originalHeadImageUrl;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * screennamePinyin;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * thumbnailsHeadImagePath;
@property (nonatomic, retain) NSString * thumbnailsHeadImageUrl;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) Users *whoseFriends;

@end
