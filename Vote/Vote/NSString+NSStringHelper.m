//
//  NSString+NSStringHelper.m
//  Vote
//
//  Created by 丁 一 on 14-8-10.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "NSString+NSStringHelper.h"

@implementation NSString (NSStringHelper)

+ (BOOL)checkWhitespaceAndNewlineCharacter:(NSString *)text
{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimedString = [text stringByTrimmingCharactersInSet:set];
    //只有空格，tab或换行返回YES
    if ([trimedString length] == 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (CGFloat)calculateTextHeight:(NSString *)text font:(UIFont *)font width:(CGFloat)width
{
    //设置一个行高上限
    CGSize size = CGSizeMake(width, 2000.0f);
    NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
    //设置字体大小
    [atts setObject:font forKey:NSFontAttributeName];
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:atts context:nil];
    
    return rect.size.height;
}

+ (CGFloat)calculateTextWidth:(NSString *)text font:(UIFont *)font
{
    CGFloat height = font.lineHeight;
    //设置一个宽度上限
    CGSize size = CGSizeMake(2000.0f, height);
    NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
    //设置字体大小
    [atts setObject:font forKey:NSFontAttributeName];
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:atts context:nil];
    
    return rect.size.width;
}

@end
