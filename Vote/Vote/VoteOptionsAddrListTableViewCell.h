//
//  VoteOptionsAddrListTableViewCell.h
//  Vote
//
//  Created by 丁 一 on 14-8-18.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteOptionsAddrListTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *photoView;
@property (strong, nonatomic) UILabel *businessName;
@property (strong, nonatomic) UIImageView *ratingView;
@property (strong, nonatomic) UILabel *avgPrice;
@property (strong, nonatomic) UILabel *rgnCtgry;  //region and category
@property (strong, nonatomic) UILabel *distance;

@property (strong, nonatomic) UIView *separator;

@end

//cell macro
#define OALTVC_PHOTO_TAG                        2001
#define OALTVC_BUSINESS_NAME_TAG                2002
#define OALTVC_RATING_IMAGE_TAG                 2003
#define OALTVC_AVG_PRICE_TAG                    2004
#define OALTVC_RGN_CTGRY_TAG                    2005
#define OALTVC_DISTANCE_TAG                     2006
#define OALTVC_SEPARATOR_TAG                    2007

#define OALTVC_PHOTO_COORDINATE_X               10
#define OALTVC_PHOTO_COORDINATE_Y               10
#define OALTVC_PHOTO_WIDTH                      80
#define OALTVC_PHOTO_HEIGHT                     60

#define OALTVC_BUSINESS_NAME_COORDINATE_X       105
#define OALTVC_BUSINESS_NAME_COORDINATE_Y       10
#define OALTVC_BUSINESS_NAME_WIDTH              205
#define OALTVC_BUSINESS_NAME_HEIGHT             15
#define OALTVC_BUSINESS_NAME_FONT               @"Verdana"
#define OALTVC_BUSINESS_NAME_FONT_SIZE          15

#define OALTVC_RATING_IMAGE_COORDINATE_X        105
#define OALTVC_RATING_IMAGE_COORDINATE_Y        35
#define OALTVC_RATING_IMAGE_WIDTH               60
#define OALTVC_RATING_IMAGE_HEIGHT              15

#define OALTVC_AVG_PRICE_COORDINATE_X           185
#define OALTVC_AVG_PRICE_COORDINATE_Y           35
#define OALTVC_AVG_PRICE_WIDTH                  90
#define OALTVC_AVG_PRICE_HEIGHT                 15
#define OALTVC_AVG_PRICE_FONT                   @"Verdana"
#define OALTVC_AVG_PRICE_FONT_SIZE              13

#define OALTVC_RGN_CTGRY_COORDINATE_X           105
#define OALTVC_RGN_CTGRY_COORDINATE_Y           60
#define OALTVC_RGN_CTGRY_WIDTH                  100
#define OALTVC_RGN_CTGRY_HEIGHT                 12
#define OALTVC_RGN_CTGRY_FONT                   @"Verdana"
#define OALTVC_RGN_CTGRY_FONT_SIZE              12

#define OALTVC_DISTANCE_COORDINATE_X            250
#define OALTVC_DISTANCE_COORDINATE_Y            60
#define OALTVC_DISTANCE_WIDTH                   60
#define OALTVC_DISTANCE_HEIGHT                  12
#define OALTVC_DISTANCE_FONT                    @"Verdana"
#define OALTVC_DISTANCE_FONT_SIZE               12

#define OALTVC_CELL_HEIGHT                      82.0 //RGN_CTGRY_COORDINATE_Y + RGN_CTGRY_HEIGHT + 10