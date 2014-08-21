//
//  VotePopoverTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-6-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetPopOverTableViewCellTextDelegate;

@interface VotePopoverTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *image;
@property (strong, nonatomic) NSMutableArray *text;
@property (strong, nonatomic) NSString *cellIdentifier;

@property (weak, nonatomic) id<GetPopOverTableViewCellTextDelegate> getTVCTextDelegate;

@end


@protocol GetPopOverTableViewCellTextDelegate <NSObject>

@required
- (void)getTableViewCellText:(NSString *)text withIdentifier:(NSString *)identifier;

@end