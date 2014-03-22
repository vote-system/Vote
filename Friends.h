//
//  Friends.h
//  Vote
//
//  Created by 丁 一 on 14-3-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Users;

@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * lastUpdateTag;
@property (nonatomic, retain) UIImage * mediumHeadImage;
@property (nonatomic, retain) NSString * mediumHeadImageUrl;
@property (nonatomic, retain) UIImage * originalHeadImage;
@property (nonatomic, retain) NSString * originalHeadImageUrl;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * screennamePinyin;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) UIImage * thumbnailHeadImage;
@property (nonatomic, retain) NSString * thumbnailHeadImageUrl;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) Users *whoseFriends;

@end
