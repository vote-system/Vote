//
//  VoteBarResultsView.m
//  Vote
//
//  Created by 丁 一 on 14-7-4.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteBarResultsView.h"

@implementation VoteBarResultsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        //赤橙黄绿青蓝紫
        self.colorMap = @{@"A":UIColorFromRGB(0xFF0000), @"B":UIColorFromRGB(0xFF8000), @"C":UIColorFromRGB(0xFFFF00), @"D":UIColorFromRGB(0x00FF00), @"E":UIColorFromRGB(0x00FFFF), @"F":UIColorFromRGB(0x0000FF), @"G":UIColorFromRGB(0x8000FF), @"H":UIColorFromRGB(0xFF8000), @"I":UIColorFromRGB(0xFF8000), @"J":UIColorFromRGB(0xFF8000), @"K":UIColorFromRGB(0xFF8000), @"L":UIColorFromRGB(0xFF8000)};
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *aPath = [UIBezierPath bezierPathWithRect:rect];
    UIColor *color = UIColorFromRGB(0xCCCCCC);
    //[aPath setLineWidth:1.0];
    [color set];
    [aPath stroke];
    [aPath fill];
    CGFloat dPercent = [self.percent doubleValue];
    CGRect voteRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width*dPercent, rect.size.height);
    aPath = [UIBezierPath bezierPathWithRect:voteRect];
    color = [self.colorMap objectForKey:self.order];
    [color set];
    [aPath stroke];
    [aPath fill];
    
}


@end
