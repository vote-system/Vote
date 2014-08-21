//
//  VoteBarResultsView.h
//  Vote
//
//  Created by 丁 一 on 14-7-4.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteBarResultsView : UIView

@property (strong, nonatomic) NSString *order;
@property (strong, nonatomic) NSDictionary *colorMap;
@property (strong, nonatomic) NSNumber *percent;

@end
