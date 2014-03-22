//
//  VoteAppDelegate.h
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface VoteAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIManagedDocument *document;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
