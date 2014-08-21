//
//  DianPingAPI.h
//  TestProj
//
//  Created by 丁 一 on 14-4-23.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DianPingAPI : NSObject

+ (NSString *)signGeneratedInSHA1With:(NSDictionary *)para;

@end

#define APPKEY                       @"84937741"
#define APP_SECRET                   @"db391aa7fa184f6f804fa3593628c3bb"

//request parameters
#define DIANPING_APPKEY              @"appkey"
#define DIANPING_SIGN                @"sign"
#define DIANPING_CITY                @"city"
#define DIANPING_REGION              @"region"
#define DIANPING_RADIUS              @"radius"
#define DIANPING_CATEGORY            @"category"
#define DIANPING_SORT                @"sort"
#define DIANPING_LATITUDE            @"latitude"   //纬度
#define DIANPING_LONGITUDE           @"longitude"  //经度
#define DIANPING_OFFSET_TYPE         @"offset_type"
#define DIANPING_PLATFORM            @"platform"
#define DIANPING_PAGE                @"page"
#define DIANPING_LIMIT               @"limit"
#define DIANPING_KEYWORD             @"keyword"

//response parameters
#define DIANPING_STATUS              @"status"
#define DIANPING_S_PHOTO_URL         @"s_photo_url"
#define DIANPING_BUSINESS            @"businesses"
#define DIANPING_NAME                @"name"
#define DIANPING_BRANCH_NAME         @"branch_name"
#define DIANPING_BUSINESS_NAME       @"business_name"
#define DIANPING_ADDRESS             @"address"
#define DIANPING_TELEPHONE           @"telephone"
#define DIANPING_RATING_IMAGE_URL    @"rating_img_url"
#define DIANPING_S_RATING_IMAGE_URL  @"rating_s_img_url"
#define DIANPING_REGION_REP          @"regions"
#define DIANPING_CATEGORY_REP        @"categories"
#define DIANPING_DISTANCE            @"distance"
#define DIANPING_BUSINESS_ID         @"business_id"
#define DIANPING_AVG_PRICE           @"avg_price"
#define DIANPING_PRODUCT_SCORE       @"product_score"
#define DIANPING_DECORATION_SCORE    @"decoration_score"
#define DIANPING_SERVICE_SCORE       @"service_score"
#define DIANPING_HAS_COUPON          @"has_coupon" //是否有优惠券
#define DIANPING_HAS_DEAL            @"has_deal"   //是否有团购
#define DIANPING_DEAL_COUNT          @"deal_count"
#define DIANPING_DEALS               @"deals"
//用户点评参数
#define DIANPING_REVIEWS             @"reviews"
#define DIANPING_USER_NICKNAME       @"user_nickname"
#define DIANPING_TEXT_EXCERPT        @"text_excerpt"
