//
//  VoteBusinessDetailsHelper.m
//  Vote
//
//  Created by 丁 一 on 14-8-15.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteBusinessDetailsHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "DianPingAPI.h"
#import "NSString+NSStringHelper.h"

@implementation VoteBusinessDetailsHelper

+ (void)configureBasicCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withBusinessInfo:(NSDictionary *)businessInfo
{
    CGRect rect;
    CGFloat height;
    NSString *text;
    UIFont *font;
    //商户名称
    UILabel *name;
    if ([cell.contentView viewWithTag:BDH_NAME_TAG] == nil) {
        text = [[NSString alloc] initWithFormat:@"%@(%@)", [businessInfo objectForKey:DIANPING_NAME], [businessInfo objectForKey:DIANPING_BRANCH_NAME]];
        font = [UIFont fontWithName:BDH_NAME_FONT size:BDH_NAME_FONT_SIZE];
        height = [NSString calculateTextHeight:text font:font width:BDH_NAME_WIDTH];
        rect = CGRectMake(BDH_NAME_COORDINATE_X, BDH_NAME_COORDINATE_Y, BDH_NAME_WIDTH, height);
        name = [[UILabel alloc] initWithFrame:rect];
        name.tag = BDH_NAME_TAG;
        name.font = font;
        name.text = [[NSString alloc] initWithFormat:@"%@(%@)", [businessInfo objectForKey:DIANPING_NAME], [businessInfo objectForKey:DIANPING_BRANCH_NAME]];
        [cell.contentView addSubview:name];
    }
    //商户图片
    UIImageView *imageView;
    if ([cell.contentView viewWithTag:BDH_S_PHOTO_TAG]) {
        rect = CGRectMake(BDH_S_PHOTO_COORDINATE_X, (FRAME_Y(name)+FRAME_HEIGHT(name)+10.0), BDH_S_PHOTO_WIDTH, BDH_S_PHOTO_HEIGHT);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = BDH_S_PHOTO_TAG;
        NSString *url = [businessInfo objectForKey:DIANPING_S_PHOTO_URL];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        __weak UIImageView *tmpImageView = imageView;
        [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            tmpImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"error:%@",error);
        }];
        [cell.contentView addSubview:imageView];
    }
    //商户评级图片
    UIImageView *ratingImageView;
    if ([cell.contentView viewWithTag:BDH_RATING_S_IMG_TAG] == nil) {
        rect = CGRectMake(BDH_RATING_S_IMG_COORDINATE_X, (FRAME_Y(name)+FRAME_HEIGHT(name)+15.0), BDH_RATING_S_IMG_WIDTH, BDH_RATING_S_IMG_HEIGHT);
        ratingImageView = [[UIImageView alloc] initWithFrame:rect];
        ratingImageView.tag = BDH_RATING_S_IMG_TAG;

        NSString *ratingUrl = [businessInfo objectForKey:DIANPING_RATING_IMAGE_URL];
        NSURLRequest *ratingReq = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:ratingUrl]];
        __weak UIImageView *tmpRatingImageView = ratingImageView;
        [ratingImageView setImageWithURLRequest:ratingReq placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            tmpRatingImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"error:%@",error);
        }];
        [cell.contentView addSubview:ratingImageView];
    }
    //商户人均消费
    UILabel *avgPrice;
    if ([cell.contentView viewWithTag:BDH_DETAILS_AVG_PRICE_TAG] == nil) {
        rect = CGRectMake(BDH_DETAILS_AVG_PRICE_COORDINATE_X, (FRAME_Y(ratingImageView)+FRAME_HEIGHT(ratingImageView)+10.0), BDH_DETAILS_AVG_PRICE_WIDTH, BDH_DETAILS_AVG_PRICE_HEIGHT);
        avgPrice = [[UILabel alloc] initWithFrame:rect];
        avgPrice.tag = BDH_DETAILS_AVG_PRICE_TAG;
        avgPrice.font = [UIFont systemFontOfSize:BDH_DETAILS_AVG_PRICE_FONT];
        if (!((NSNull *)[businessInfo objectForKey:DIANPING_AVG_PRICE] == [NSNull null])) {
            avgPrice.text = [[NSString alloc] initWithFormat:@"人均: ¥%@", [businessInfo objectForKey:DIANPING_AVG_PRICE]];
        } else {
            avgPrice.text = @"人均: ¥0";
        }
        [cell.contentView addSubview:avgPrice];
    }
    //商户产品评分
    UILabel *productScore;
    if ([cell.contentView viewWithTag:BDH_PRODUCT_SCORE_TAG] == nil) {
        rect = CGRectMake(BDH_PRODUCT_SCORE_COORDINATE_X, (FRAME_Y(avgPrice)+FRAME_HEIGHT(avgPrice)+10.0), BDH_PRODUCT_SCORE_WIDTH, BDH_PRODUCT_SCORE_HEIGHT);
        productScore = [[UILabel alloc] initWithFrame:rect];
        productScore.tag = BDH_PRODUCT_SCORE_TAG;
        productScore.font = [UIFont systemFontOfSize:BDH_PRODUCT_SCORE_FONT];
        if (!((NSNull *)[businessInfo objectForKey:DIANPING_PRODUCT_SCORE] == [NSNull null])) {
            productScore.text = [[NSString alloc] initWithFormat:@"总体: %@", [businessInfo objectForKey:DIANPING_PRODUCT_SCORE]];
        } else {
            productScore.text = @"总体: 0.0";
        }
        [cell.contentView addSubview:productScore];
    }
    //商户环境评分
    UILabel *decorationScore;
    if ([cell.contentView viewWithTag:BDH_DECORATION_SCORE_TAG] == nil) {
        rect = CGRectMake(BDH_DECORATION_SCORE_COORDINATE_X, (FRAME_Y(avgPrice)+FRAME_HEIGHT(avgPrice)+10.0), BDH_DECORATION_SCORE_WIDTH, BDH_DECORATION_SCORE_HEIGHT);
        decorationScore = [[UILabel alloc] initWithFrame:rect];
        decorationScore.tag = BDH_DECORATION_SCORE_TAG;
        decorationScore.font = [UIFont systemFontOfSize:BDH_DECORATION_SCORE_FONT];
        if (!((NSNull *)[businessInfo objectForKey:DIANPING_DECORATION_SCORE] == [NSNull null])) {
            decorationScore.text = [[NSString alloc] initWithFormat:@"环境: %@", [businessInfo objectForKey:DIANPING_DECORATION_SCORE]];
        } else {
            decorationScore.text = @"环境: 0.0";
        }
        [cell.contentView addSubview:decorationScore];
    }
    //商户服务评分
    UILabel *serviceScore;
    if ([cell.contentView viewWithTag:BDH_SERVICE_SCORE_TAG] == nil) {
        rect = CGRectMake(BDH_SERVICE_SCORE_COORDINATE_X, (FRAME_Y(avgPrice)+FRAME_HEIGHT(avgPrice)+10.0), BDH_SERVICE_SCORE_WIDTH, BDH_SERVICE_SCORE_HEIGHT);
        serviceScore = [[UILabel alloc] initWithFrame:rect];
        serviceScore.tag = BDH_SERVICE_SCORE_TAG;
        serviceScore.font = [UIFont systemFontOfSize:BDH_DECORATION_SCORE_FONT];
        if (!((NSNull *)[businessInfo objectForKey:DIANPING_SERVICE_SCORE] == [NSNull null])) {
            serviceScore.text = [[NSString alloc] initWithFormat:@"服务: %@", [businessInfo objectForKey:DIANPING_SERVICE_SCORE]];
        } else {
            serviceScore.text = @"服务: 0.0";
        }
        [cell.contentView addSubview:serviceScore];
    }
}

+ (void)configureAddressCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withBusinessInfo:(NSDictionary *)businessInfo
{
    CGRect rect;
    UILabel *addressLabel;
    if ([cell.contentView viewWithTag:BDH_ADDRESS_TAG] == nil) {
        if (!((NSNull *)[businessInfo objectForKey:DIANPING_ADDRESS] == [NSNull null])) {
            rect = CGRectMake(BDH_ADDRESS_COORDINATE_X, BDH_ADDRESS_COORDINATE_Y, BDH_ADDRESS_WIDTH, cell.frame.size.height - 20.0);
            NSString *address = [businessInfo objectForKey:DIANPING_ADDRESS];
            UIFont *font = [UIFont fontWithName:BDH_ADDRESS_FONT size:BDH_ADDRESS_FONT_SIZE];
            addressLabel = [[UILabel alloc] initWithFrame:rect];
            addressLabel.tag = BDH_ADDRESS_TAG;
            addressLabel.font = font;
            addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
            addressLabel.numberOfLines = 0;
            addressLabel.text = address;
        } else {
            rect = CGRectMake(BDH_ADDRESS_COORDINATE_X, BDH_ADDRESS_COORDINATE_Y, BDH_ADDRESS_WIDTH, BDH_ADDRESS_FONT_SIZE);
            addressLabel = [[UILabel alloc] initWithFrame:rect];
            addressLabel.tag = BDH_ADDRESS_TAG;
            addressLabel.font = [UIFont systemFontOfSize:BDH_ADDRESS_FONT_SIZE];
            addressLabel.text = @"暂无地址信息";
        }
        [cell.contentView addSubview:addressLabel];
    }
}

+ (void)configureTelephoneCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withBusinessInfo:(NSDictionary *)businessInfo
{
    CGRect rect;
    UILabel *telephoneLabel;
    if ([cell.contentView viewWithTag:BDH_TELEPHONE_TAG] == nil) {
        if (!((NSNull *)[businessInfo objectForKey:DIANPING_TELEPHONE] == [NSNull null])) {
            rect = CGRectMake(BDH_TELEPHONE_COORDINATE_X, BDH_TELEPHONE_COORDINATE_Y, BDH_TELEPHONE_WIDTH, cell.frame.size.height - 20.0);
            NSString *telephone = [businessInfo objectForKey:DIANPING_TELEPHONE];
            UIFont *font = [UIFont fontWithName:BDH_TELEPHONE_FONT size:BDH_TELEPHONE_FONT_SIZE];
            telephoneLabel = [[UILabel alloc] initWithFrame:rect];
            telephoneLabel.tag = BDH_TELEPHONE_TAG;
            telephoneLabel.font = font;
            telephoneLabel.lineBreakMode = NSLineBreakByWordWrapping;
            telephoneLabel.numberOfLines = 0;
            if ([telephone length]) {
                telephoneLabel.text = telephone;
            } else {
                telephoneLabel.text = @"暂无电话号码";
            }
        } else {
            rect = CGRectMake(BDH_TELEPHONE_COORDINATE_X, BDH_TELEPHONE_COORDINATE_Y, BDH_TELEPHONE_WIDTH, BDH_TELEPHONE_FONT_SIZE);
            telephoneLabel = [[UILabel alloc] initWithFrame:rect];
            telephoneLabel.tag = BDH_TELEPHONE_TAG;
            telephoneLabel.font = [UIFont systemFontOfSize:BDH_TELEPHONE_FONT_SIZE];
            telephoneLabel.text = @"暂无电话号码";
        }
        [cell.contentView addSubview:telephoneLabel];
    }
}

+ (void)configureCommentsCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath witCommentsInfo:(NSMutableArray *)commentsInfo
{
    UILabel *authorNameLabel;
    UIImageView *commentsRatingImgView;
    UILabel *commentsLabel;
    CGRect rect;
    if ([commentsInfo count] > 0) {
        if ([cell.contentView viewWithTag:BDH_COMMENTS_AUTHOR_NAME_TAG] == nil) {
            if (!((NSNull *)[[commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_USER_NICKNAME] == [NSNull null])) {
                rect = CGRectMake(BDH_COMMENTS_AUTHOR_NAME_COORDINATE_X, BDH_COMMENTS_AUTHOR_NAME_COORDINATE_Y, BDH_COMMENTS_AUTHOR_NAME_WIDTH, BDH_COMMENTS_AUTHOR_NAME_HEIGHT);
                authorNameLabel = [[UILabel alloc] initWithFrame:rect];
                authorNameLabel.tag = BDH_COMMENTS_AUTHOR_NAME_TAG;
                authorNameLabel.font = [UIFont fontWithName:BDH_COMMENTS_AUTHOR_NAME_FONT size:BDH_COMMENTS_AUTHOR_NAME_FONT_SIZE];
                [cell.contentView addSubview:authorNameLabel];
            }
        } else {
            authorNameLabel = (UILabel *)[cell.contentView viewWithTag:BDH_COMMENTS_AUTHOR_NAME_TAG];
        }
        authorNameLabel.text = [[commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_USER_NICKNAME];
        
        if ([cell.contentView viewWithTag:BDH_COMMENTS_RATING_S_IMG_TAG] == nil) {
            if (!((NSNull *)[[commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_S_RATING_IMAGE_URL] == [NSNull null])) {
                rect = CGRectMake(BDH_COMMENTS_RATING_S_IMG_COORDINATE_X, BDH_COMMENTS_RATING_S_IMG_COORDINATE_Y, BDH_COMMENTS_RATING_S_IMG_WIDTH, BDH_COMMENTS_RATING_S_IMG_HEIGHT);
                commentsRatingImgView = [[UIImageView alloc] initWithFrame:rect];
                commentsRatingImgView.tag = BDH_COMMENTS_RATING_S_IMG_TAG;
                [cell.contentView addSubview:commentsRatingImgView];
            }
        } else {
            commentsRatingImgView = (UIImageView *)[cell.contentView viewWithTag:BDH_COMMENTS_RATING_S_IMG_TAG];
        }
        NSString *ratingUrl = [[commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_S_RATING_IMAGE_URL];
        NSURLRequest *ratingReq = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:ratingUrl]];
        __weak UIImageView *tmpRatingImageView = commentsRatingImgView;
        [commentsRatingImgView setImageWithURLRequest:ratingReq placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            tmpRatingImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"error:%@",error);
        }];
        
        if ([cell.contentView viewWithTag:BDH_COMMENTS_TEXT_TAG] == nil) {
            if (!((NSNull *)[[commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_TEXT_EXCERPT] == [NSNull null])) {
                CGFloat height = cell.frame.size.height - BDH_COMMENTS_TEXT_COORDINATE_Y - 10;
                rect = CGRectMake(BDH_COMMENTS_TEXT_COORDINATE_X, BDH_COMMENTS_TEXT_COORDINATE_Y, BDH_COMMENTS_TEXT_WIDTH, height);
                commentsLabel = [[UILabel alloc] initWithFrame:rect];
                commentsLabel.tag = BDH_COMMENTS_TEXT_TAG;
                commentsLabel.font = [UIFont fontWithName:BDH_COMMENTS_TEXT_FONT size:BDH_COMMENTS_TEXT_FONT_SIZE];
                commentsLabel.lineBreakMode = NSLineBreakByWordWrapping;
                commentsLabel.numberOfLines = 0;
                [cell.contentView addSubview:commentsLabel];
            }
        } else {
            commentsLabel = (UILabel *)[cell.contentView viewWithTag:BDH_COMMENTS_TEXT_TAG];
        }
        commentsLabel.text = [[commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_TEXT_EXCERPT];

    }
}

@end
