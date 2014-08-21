//
//  VoteBusinessDetailsHelper.h
//  Vote
//
//  Created by 丁 一 on 14-8-15.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoteBusinessDetailsHelper : NSObject

+ (void)configureBasicCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withBusinessInfo:(NSDictionary *)businessInfo;

+ (void)configureAddressCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withBusinessInfo:(NSDictionary *)businessInfo;

+ (void)configureTelephoneCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withBusinessInfo:(NSDictionary *)businessInfo;

+ (void)configureCommentsCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath witCommentsInfo:(NSMutableArray *)commentsInfo;

@end

//BDH means Business Details Helper
#define BDH_NAME_TAG                            1001
#define BDH_S_PHOTO_TAG                         1002
#define BDH_RATING_S_IMG_TAG                    1003
#define BDH_DETAILS_AVG_PRICE_TAG               1004
#define BDH_PRODUCT_SCORE_TAG                   1005
#define BDH_DECORATION_SCORE_TAG                1006
#define BDH_SERVICE_SCORE_TAG                   1007
#define BDH_ADDRESS_TAG                         1008
#define BDH_TELEPHONE_TAG                       1009
#define BDH_COMMENTS_AUTHOR_NAME_TAG            1010
#define BDH_COMMENTS_RATING_S_IMG_TAG           1011
#define BDH_COMMENTS_TEXT_TAG                   1012

//商户名称
#define BDH_NAME_COORDINATE_X                   10
#define BDH_NAME_COORDINATE_Y                   10
#define BDH_NAME_WIDTH                          300
//#define BDH_NAME_HEIGHT                         20
#define BDH_NAME_FONT                           @"ChalkboardSE-Regular"
#define BDH_NAME_FONT_SIZE                      18.0

//商户图片
#define BDH_S_PHOTO_COORDINATE_X                10    //NAME_COORDINATE_X
//#define BDH_S_PHOTO_COORDINATE_Y                40    //NAME_COORDINATE_Y + NAME_HEIGHT + 10
#define BDH_S_PHOTO_WIDTH                       100
#define BDH_S_PHOTO_HEIGHT                      72

//商户评级图片
#define BDH_RATING_S_IMG_COORDINATE_X           120   //S_PHOTO_COORDINATE_X + S_PHOTO_WIDTH + 10
//#define BDH_RATING_S_IMG_COORDINATE_Y           45    //S_PHOTO_COORDINATE_Y + 5
#define BDH_RATING_S_IMG_WIDTH                  80
#define BDH_RATING_S_IMG_HEIGHT                 20

//商户人均
#define BDH_DETAILS_AVG_PRICE_COORDINATE_X      120   //RATING_S_IMG_COORDINATE_X
//#define BDH_DETAILS_AVG_PRICE_COORDINATE_Y      75    //RATING_S_IMG_COORDINATE_Y + RATING_S_IMG_HEIGHT + 10
#define BDH_DETAILS_AVG_PRICE_WIDTH             50
#define BDH_DETAILS_AVG_PRICE_HEIGHT            10
#define BDH_DETAILS_AVG_PRICE_FONT              10

//商户产品评分
#define BDH_PRODUCT_SCORE_COORDINATE_X          120   //RATING_S_IMG_COORDINATE_X
//#define BDH_PRODUCT_SCORE_COORDINATE_Y          95    //AVG_PRICE_COORDINATE_Y + AVG_PRICE_HEIGHT + 10
#define BDH_PRODUCT_SCORE_WIDTH                 50
#define BDH_PRODUCT_SCORE_HEIGHT                10
#define BDH_PRODUCT_SCORE_FONT                  10

//商户环境评分
#define BDH_DECORATION_SCORE_COORDINATE_X       180   //PRODUCT_SCORE_COORDINATE_X + PRODUCT_SCORE_WIDTH + 10
//#define BDH_DECORATION_SCORE_COORDINATE_Y       95    //AVG_PRICE_COORDINATE_Y + AVG_PRICE_HEIGHT + 10
#define BDH_DECORATION_SCORE_WIDTH              50
#define BDH_DECORATION_SCORE_HEIGHT             10
#define BDH_DECORATION_SCORE_FONT               10

//商户服务评分
#define BDH_SERVICE_SCORE_COORDINATE_X          240   //DECORATION_SCORE_COORDINATE_X + DECORATION_SCORE_WIDTH + 10
//#define BDH_SERVICE_SCORE_COORDINATE_Y          95    //AVG_PRICE_COORDINATE_Y + AVG_PRICE_HEIGHT + 10
#define BDH_SERVICE_SCORE_WIDTH                 50
#define BDH_SERVICE_SCORE_HEIGHT                10
#define BDH_SERVICE_SCORE_FONT                  10

//地址信息参数
#define BDH_ADDRESS_COORDINATE_X                10
#define BDH_ADDRESS_COORDINATE_Y                10
#define BDH_ADDRESS_WIDTH                       [[UIScreen mainScreen] bounds].size.width - 20
#define BDH_ADDRESS_FONT                        @"ChalkboardSE-Regular"
#define BDH_ADDRESS_FONT_SIZE                   15
//电话列表参数
#define BDH_TELEPHONE_COORDINATE_X              10
#define BDH_TELEPHONE_COORDINATE_Y              10
#define BDH_TELEPHONE_WIDTH                     [[UIScreen mainScreen] bounds].size.width - 20
#define BDH_TELEPHONE_FONT                      @"ChalkboardSE-Regular"
#define BDH_TELEPHONE_FONT_SIZE                 15
//评论列表参数
#define BDH_COMMENTS_AUTHOR_NAME_COORDINATE_X   10
#define BDH_COMMENTS_AUTHOR_NAME_COORDINATE_Y   10
#define BDH_COMMENTS_AUTHOR_NAME_WIDTH          [[UIScreen mainScreen] bounds].size.width - 20
#define BDH_COMMENTS_AUTHOR_NAME_HEIGHT         14
#define BDH_COMMENTS_AUTHOR_NAME_FONT           @"Verdana"
#define BDH_COMMENTS_AUTHOR_NAME_FONT_SIZE      14
#define BDH_COMMENTS_RATING_S_IMG_COORDINATE_X  10   //COMMENTS_AUTHOR_NAME_COORDINATE_X
#define BDH_COMMENTS_RATING_S_IMG_COORDINATE_Y  34   //COMMENTS_AUTHOR_NAME_COORDINATE_Y + COMMENTS_AUTHOR_NAME_HEIGHT + 10
#define BDH_COMMENTS_RATING_S_IMG_WIDTH         40
#define BDH_COMMENTS_RATING_S_IMG_HEIGHT        10
#define BDH_COMMENTS_TEXT_COORDINATE_X          10   //COMMENTS_AUTHOR_NAME_COORDINATE_X
#define BDH_COMMENTS_TEXT_COORDINATE_Y          54   //COMMENTS_RATING_S_IMG_COORDINATE_Y + COMMENTS_RATING_S_IMG_HEIGHT + 10
#define BDH_COMMENTS_TEXT_WIDTH                 [[UIScreen mainScreen] bounds].size.width - 20
#define BDH_COMMENTS_TEXT_FONT                  @"Verdana"
#define BDH_COMMENTS_TEXT_FONT_SIZE             12