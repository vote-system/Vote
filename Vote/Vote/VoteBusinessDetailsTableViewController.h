//
//  VoteBusinessDetailsTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-6-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddBusinessOptionDelegate;

@interface VoteBusinessDetailsTableViewController : UITableViewController

@property (strong, nonatomic) NSNumber *businessID;
@property (weak, nonatomic) id<AddBusinessOptionDelegate> addBusiOptDelegate;

@end

@protocol AddBusinessOptionDelegate <NSObject>

@required
- (void)addBusinessWithData:(NSDictionary *)data;

@end


