//
//  VoteCustomAddressViewController.h
//  Vote
//
//  Created by 丁 一 on 14-8-18.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCustomAddressDelegate;

@interface VoteCustomAddressViewController : UIViewController

@property (nonatomic, weak) id<AddCustomAddressDelegate> addCustomAddrDelegate;

@end

@protocol AddCustomAddressDelegate <NSObject>

@required
- (void)addCustomAddress:(NSString *)address;

@end