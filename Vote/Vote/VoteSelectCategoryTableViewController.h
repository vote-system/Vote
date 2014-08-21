//
//  VoteSelectCategoryTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-8-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectOptionCategoryDelegate;

@interface VoteSelectCategoryTableViewController : UITableViewController

@property (weak, nonatomic) id<SelectOptionCategoryDelegate> optionCategoryDelegate;

@end

@protocol SelectOptionCategoryDelegate <NSObject>

@required
- (void)selectOptionCategory:(NSString *)category;

@end