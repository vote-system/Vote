//
//  NSString+NSStringHelper.h
//  Vote
//
//  Created by 丁 一 on 14-8-10.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringHelper)

+ (BOOL)checkWhitespaceAndNewlineCharacter:(NSString *)text;

+ (CGFloat)calculateTextHeight:(NSString *)text font:(UIFont *)font width:(CGFloat)width;
+ (CGFloat)calculateTextWidth:(NSString *)text font:(UIFont *)font;

@end
