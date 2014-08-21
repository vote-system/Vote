//
//  VoteAddOptionsTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-8-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddOptionsDelegate;

@interface VoteAddOptionsTableViewController : UITableViewController

@property (weak, nonatomic) id<AddOptionsDelegate> addOptionsDelegate;

@end

@protocol AddOptionsDelegate <NSObject>

@required
- (void)addOptionWithData:(NSDictionary *)data;

@end
