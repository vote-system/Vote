//
//  VoteOptionsAddrListTableViewCell.m
//  Vote
//
//  Created by 丁 一 on 14-8-18.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteOptionsAddrListTableViewCell.h"

@implementation VoteOptionsAddrListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    if (self.photoView == nil) {
        CGRect rect = CGRectMake(OALTVC_PHOTO_COORDINATE_X, OALTVC_PHOTO_COORDINATE_Y, OALTVC_PHOTO_WIDTH, OALTVC_PHOTO_HEIGHT);
        self.photoView = [[UIImageView alloc] initWithFrame:rect];
        [self.contentView addSubview:self.photoView];
    }
    
    if (self.businessName == nil) {
        CGRect rect = CGRectMake(OALTVC_BUSINESS_NAME_COORDINATE_X, OALTVC_BUSINESS_NAME_COORDINATE_Y, OALTVC_BUSINESS_NAME_WIDTH, OALTVC_BUSINESS_NAME_HEIGHT);
        self.businessName = [[UILabel alloc] initWithFrame:rect];
        self.businessName.font = [UIFont fontWithName:OALTVC_BUSINESS_NAME_FONT size:OALTVC_BUSINESS_NAME_FONT_SIZE];
        [self.contentView addSubview:self.businessName];
    }
    
    if (self.ratingView == nil) {
        CGRect rect = CGRectMake(OALTVC_RATING_IMAGE_COORDINATE_X, OALTVC_RATING_IMAGE_COORDINATE_Y, OALTVC_RATING_IMAGE_WIDTH, OALTVC_RATING_IMAGE_HEIGHT);
        self.ratingView = [[UIImageView alloc] initWithFrame:rect];
        [self.contentView addSubview:self.ratingView];
    }
    
    if (self.avgPrice == nil) {
        CGRect rect = CGRectMake(OALTVC_AVG_PRICE_COORDINATE_X, OALTVC_AVG_PRICE_COORDINATE_Y, OALTVC_AVG_PRICE_WIDTH, OALTVC_AVG_PRICE_HEIGHT);
        self.avgPrice = [[UILabel alloc] initWithFrame:rect];
        self.avgPrice.font = [UIFont fontWithName:OALTVC_AVG_PRICE_FONT size:OALTVC_AVG_PRICE_FONT_SIZE];
        [self.contentView addSubview:self.avgPrice];
    }
    
    if (self.rgnCtgry == nil) {
        CGRect rect = CGRectMake(OALTVC_RGN_CTGRY_COORDINATE_X, OALTVC_RGN_CTGRY_COORDINATE_Y, OALTVC_RGN_CTGRY_WIDTH, OALTVC_RGN_CTGRY_HEIGHT);
        self.rgnCtgry = [[UILabel alloc] initWithFrame:rect];
        self.rgnCtgry.font = [UIFont fontWithName:OALTVC_RGN_CTGRY_FONT size:OALTVC_RGN_CTGRY_FONT_SIZE];
        [self.contentView addSubview:self.rgnCtgry];
    }
    
    if (self.distance == nil) {
        CGRect rect = CGRectMake(OALTVC_DISTANCE_COORDINATE_X, OALTVC_DISTANCE_COORDINATE_Y, OALTVC_DISTANCE_WIDTH, OALTVC_DISTANCE_HEIGHT);
        self.distance = [[UILabel alloc] initWithFrame:rect];
        self.distance.font = [UIFont fontWithName:OALTVC_DISTANCE_FONT size:OALTVC_DISTANCE_FONT_SIZE];
        [self.contentView addSubview:self.distance];
    }
    
    if (self.separator == nil) {
        CGRect rect = CGRectMake(0, self.frame.size.height - 0.5, BOUNDS_WIDTH([UIScreen mainScreen]), 0.5);
        self.separator = [[UIView alloc] initWithFrame:rect];
        [self.contentView addSubview:self.separator];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
