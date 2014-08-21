//
//  WGS84ToGCJ02.h
//  TestProj
//
//  Created by 丁 一 on 14-4-23.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WGS84ToGCJ02 : NSObject

//判断是否已经超出中国范围
+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
//转GCJ-02
+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end
