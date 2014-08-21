//
//  VoteLookUpParticipantsCell.m
//  Vote
//
//  Created by 丁 一 on 14-8-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteLookUpParticipantsCell.h"

@implementation VoteLookUpParticipantsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60.0, 60.0)];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.layer.cornerRadius = 10.0f;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 60, 12)];
        self.nameLabel.font = [UIFont systemFontOfSize:12.0];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.nameLabel];
        
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
