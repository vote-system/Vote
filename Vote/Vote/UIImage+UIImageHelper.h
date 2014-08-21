//
//  UIImage+UIImageHelper.h
//  Vote
//
//  Created by 丁 一 on 14-3-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageHelper)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
+ (void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;

@end
