//
//  DianPingAPI.m
//  TestProj
//
//  Created by 丁 一 on 14-4-23.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "DianPingAPI.h"
#import <CommonCrypto/CommonDigest.h>

@implementation DianPingAPI

+ (NSString *)signGeneratedInSHA1With:(NSDictionary *)para
{
    NSArray *myKeys = [para allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *str = APPKEY;
    for(id key in sortedKeys) {
        str = [str stringByAppendingFormat:@"%@%@", key, [para objectForKey:key]];
    }
    str = [str stringByAppendingString:APP_SECRET];
    NSLog(@"Sorted string: %@", str);
    //const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [NSData dataWithBytes:cstr length:str.length];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (uint32_t)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    //转换成全大写
    NSString *ret = [output uppercaseString];
    NSLog(@"SHA-1: %@", ret);
    
    return ret;
}

@end
