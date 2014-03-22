//
//  Friends+FriendsHelper.h
//  Vote
//
//  Created by 丁 一 on 14-3-16.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "Friends.h"

@interface Friends (FriendsHelper)

+ (void)setFriendsData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context;

@end
