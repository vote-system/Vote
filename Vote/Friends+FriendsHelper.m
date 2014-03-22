//
//  Friends+FriendsHelper.m
//  Vote
//
//  Created by 丁 一 on 14-3-16.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "Friends+FriendsHelper.h"
#import "CoreDataHelper.h"

@implementation Friends (FriendsHelper)

+ (void)setFriendsData:(NSDictionary *)data withManagedObjectContext:(NSManagedObjectContext *)context
{
   
    
    Friends *friends = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    friends.username = [data objectForKey:@"username"];
    friends.gender = [data objectForKey:@"gender"];
    friends.screenname = [data objectForKey:@"screenname"];
    friends.screennamePinyin = [data objectForKey:@"screenname"];
    friends.signature = [data objectForKey:@"screenname"];
    friends.thumbnailHeadImageUrl = [data objectForKey:@"thumbnailHeadImageUrl"];
    friends.originalHeadImageUrl = [data objectForKey:@"originalHeadImageUrl"];
    friends.group = [data objectForKey:@"group"];
    [friends setValue:[data objectForKey:@"username"] forKey:@"username"];
    
    NSError *error;
    if(![context save:&error]) {
        NSLog(@"不能保存：%@",[error localizedDescription]);
    }
}


@end
