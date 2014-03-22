//
//  Users.m
//  Vote
//
//  Created by 丁 一 on 14-3-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "Users.h"
#import "Friends.h"
#import "UIImageToDataTransformer.h"

@implementation Users

@dynamic gender;
@dynamic group;
@dynamic lastUpdateTag;
@dynamic mediumHeadImage;
@dynamic mediumHeadImageUrl;
@dynamic originalHeadImage;
@dynamic originalHeadImageUrl;
@dynamic password;
@dynamic screenname;
@dynamic screennamePinyin;
@dynamic signature;
@dynamic thumbnailHeadImage;
@dynamic thumbnailHeadImageUrl;
@dynamic username;
@dynamic friends;

+ (void)initialize
{
    if (self == [Users class]) {
        UIImageToDataTransformer *transformer = [[UIImageToDataTransformer alloc] init];
        [NSValueTransformer setValueTransformer:transformer forName:@"UIImageToDataTransformer"];
    }
}

@end
