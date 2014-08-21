//
//  VoteOptionDetailsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-12.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteOptionDetailsTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "DianPingAPI.h"
#import "VoteBusinessDetailsHelper.h"
#import "NSString+NSStringHelper.h"

@interface VoteOptionDetailsTableViewController ()
{
    BOOL customFlag;
    
    int hasCoupon;
    int hasDeal;
    BOOL businessOK;
    BOOL commentsOK;
}

@property (strong, nonatomic) NSDictionary *businessInfo;
@property (strong, nonatomic) NSMutableArray *commentsInfo;
@end

@implementation VoteOptionDetailsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.businessID integerValue] == BUSINESS_ID_OF_CUSTOM_ADDR) {
        customFlag = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getBusinessDataFromServer
{
    NSString *userInfoURL = [[NSString alloc] initWithFormat:@"http://api.dianping.com/v1/business/get_single_business"];
    NSNumber *platform = @2;
    NSDictionary *optionPara = @{DIANPING_BUSINESS_ID:self.businessID, DIANPING_PLATFORM:platform};
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:4];
    [parameters setValuesForKeysWithDictionary:optionPara];
    NSString *sign = [DianPingAPI signGeneratedInSHA1With:optionPara];
    [parameters setObject:APPKEY forKey:DIANPING_APPKEY];
    [parameters setObject:sign forKey:DIANPING_SIGN];
    NSLog(@"Get parameters: %@", parameters);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:userInfoURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        if ([[responseObject objectForKey:DIANPING_STATUS] isEqualToString:@"OK"]) {
            self.businessInfo = [[responseObject objectForKey:DIANPING_BUSINESS] firstObject];
            hasCoupon = [[self.businessInfo objectForKey:DIANPING_HAS_COUPON] intValue];
            hasDeal = [[self.businessInfo objectForKey:DIANPING_HAS_DEAL] intValue];
            businessOK = YES;
            if (businessOK && commentsOK) {
                [self.tableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        
    }];
}

- (void)getCommentsDataFromServer
{
    NSString *commentsURL = [[NSString alloc] initWithFormat:@"http://api.dianping.com/v1/review/get_recent_reviews"];
    NSNumber *platform = @2;
    NSNumber *limit = @1;
    NSDictionary *optionPara = @{DIANPING_BUSINESS_ID:self.businessID, DIANPING_PLATFORM:platform, DIANPING_LIMIT:limit};
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:4];
    [parameters setValuesForKeysWithDictionary:optionPara];
    NSString *sign = [DianPingAPI signGeneratedInSHA1With:optionPara];
    [parameters setObject:APPKEY forKey:DIANPING_APPKEY];
    [parameters setObject:sign forKey:DIANPING_SIGN];
    NSLog(@"Get parameters: %@", parameters);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:commentsURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        if ([[responseObject objectForKey:DIANPING_STATUS] isEqualToString:@"OK"]) {
            self.commentsInfo = [[NSMutableArray alloc] initWithArray:[(NSDictionary *)responseObject objectForKey:DIANPING_REVIEWS]];
            commentsOK = YES;
            if (businessOK && commentsOK) {
                [self.tableView reloadData];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"connect network failure in first table view!");
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (customFlag == YES) {
        return 2;
    } else if (businessOK && commentsOK) {
        NSInteger count = 1;
        if (hasCoupon || hasDeal) {
            count++;
        }
        if ([self.commentsInfo count] > 0) {
            count++;
        }
        return 1+count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (customFlag == YES) {
        return 1;
    } else {
        if (businessOK && commentsOK) {
            if (section == 0) {
                return 1;
            }
            if (section == 1) {
                return 3;
            } else if (section == 2) {
                if (hasCoupon || hasDeal) {
                    NSInteger count = 0;
                    if (hasCoupon) {
                        count++;
                    }
                    if (hasDeal) {
                        NSNumber *dealsNum = [self.businessInfo objectForKey:DIANPING_DEAL_COUNT];
                        count = count + [dealsNum integerValue];
                    }
                    return count;
                } else {
                    return [self.commentsInfo count];
                }

            } else if (section == 3) {
                return [self.commentsInfo count];
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UIFont *font = [UIFont boldSystemFontOfSize:ODTVC_NAME_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:self.name font:font width:ODTVC_NAME_WIDTH];
        return height + 20;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if (customFlag == YES) {
            UIFont *font = [UIFont systemFontOfSize:ODTVC_CUSTOM_ADDR_FONT_SIZE];
            CGFloat height = [NSString calculateTextHeight:self.address font:font width:ODTVC_CUSTOM_ADDR_WIDTH];
            return height + 20;
        } else {
            NSString *text = [[NSString alloc] initWithFormat:@"%@(%@)", [self.businessInfo objectForKey:DIANPING_NAME], [self.businessInfo objectForKey:DIANPING_BRANCH_NAME]];
            UIFont *font = [UIFont fontWithName:BDH_NAME_FONT size:BDH_NAME_FONT_SIZE];
            CGFloat height1 = [NSString calculateTextHeight:text font:font width:BDH_NAME_WIDTH];
            if (height1 < 20.0) {
                height1 = 20.0;
            }
            CGFloat height = BDH_NAME_COORDINATE_Y + height1 + 10.0 + BDH_S_PHOTO_HEIGHT + 10.0;
            return height;
        }
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        NSString *text = [self.businessInfo objectForKey:DIANPING_ADDRESS];
        UIFont *font = [UIFont fontWithName:BDH_ADDRESS_FONT size:BDH_ADDRESS_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_ADDRESS_WIDTH];
        
        return height + 20;
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        NSString *text = [self.businessInfo objectForKey:DIANPING_TELEPHONE];
        UIFont *font = [UIFont fontWithName:BDH_TELEPHONE_FONT size:BDH_TELEPHONE_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_TELEPHONE_WIDTH];
        
        return height + 20.0;
        
    } else if (indexPath.section == 2) {
        if (hasCoupon || hasDeal) {
            return 44.0;
        } else {
            NSString *text = [[self.commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_TEXT_EXCERPT];
            UIFont *font = [UIFont fontWithName:BDH_COMMENTS_TEXT_FONT size:BDH_COMMENTS_TEXT_FONT_SIZE];
            CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_COMMENTS_TEXT_WIDTH];
            return BDH_COMMENTS_TEXT_COORDINATE_Y + height + 10;
        }
    } else if (indexPath.section == 3) {
        NSString *text = [[self.commentsInfo objectAtIndex:indexPath.row] objectForKey:DIANPING_TEXT_EXCERPT];
        UIFont *font = [UIFont fontWithName:BDH_COMMENTS_TEXT_FONT size:BDH_COMMENTS_TEXT_FONT_SIZE];
        CGFloat height = [NSString calculateTextHeight:text font:font width:BDH_COMMENTS_TEXT_WIDTH];
        return BDH_COMMENTS_TEXT_COORDINATE_Y + height + 10;
        
    } else {
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Option Name" forIndexPath:indexPath];
        UILabel *nameLabel;
        if ([cell.contentView viewWithTag:ODTVC_NAME_TAG] == nil) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ODTVC_NAME_COORDINATE_X, ODTVC_NAME_COORDINATE_Y, ODTVC_NAME_WIDTH, cell.frame.size.height - 20)];
            nameLabel.tag = ODTVC_NAME_TAG;
            nameLabel.font = [UIFont boldSystemFontOfSize:ODTVC_NAME_FONT_SIZE];
            [cell.contentView addSubview:nameLabel];
        } else {
            nameLabel = (UILabel *)[cell.contentView viewWithTag:ODTVC_NAME_TAG];
        }
        nameLabel.text = self.name;

    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if (customFlag == YES) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Option Custom Address" forIndexPath:indexPath];
            UILabel *addressLabel;
            if ([cell.contentView viewWithTag:ODTVC_CUSTOM_ADDR_TAG] == nil) {
                addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ODTVC_CUSTOM_ADDR_COORDINATE_X, ODTVC_CUSTOM_ADDR_COORDINATE_Y, ODTVC_CUSTOM_ADDR_WIDTH, cell.frame.size.height - 20)];
                addressLabel.tag = ODTVC_CUSTOM_ADDR_TAG;
                addressLabel.font = [UIFont systemFontOfSize:ODTVC_CUSTOM_ADDR_FONT_SIZE];
                [cell.contentView addSubview:addressLabel];
            } else {
                addressLabel = (UILabel *)[cell.contentView viewWithTag:ODTVC_CUSTOM_ADDR_TAG];
            }
            addressLabel.text = self.address;

        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Business Basic Info" forIndexPath:indexPath];
            [VoteBusinessDetailsHelper configureBasicCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
            //添加cell间的分割线
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:v];
        }
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Business Address" forIndexPath:indexPath];
        [VoteBusinessDetailsHelper configureAddressCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Business Telephone" forIndexPath:indexPath];
        [VoteBusinessDetailsHelper configureTelephoneCell:cell forRowAtIndexPath:indexPath withBusinessInfo:self.businessInfo];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
        
    } else if (indexPath.section == 2) {
        if (hasCoupon || hasDeal) {
            //优惠券和团购信息
            cell = [tableView dequeueReusableCellWithIdentifier:@"Business Coupon" forIndexPath:indexPath];
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"Business Deal" forIndexPath:indexPath];
            
        } else {
            //如果没有优惠券和团购信息，则在section 2中显示评论
            cell = [tableView dequeueReusableCellWithIdentifier:@"Business Comments" forIndexPath:indexPath];
            [VoteBusinessDetailsHelper configureCommentsCell:cell forRowAtIndexPath:indexPath witCommentsInfo:self.commentsInfo];
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
            v.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:v];
        }
    } else if (indexPath.section == 3) {
        //如果有优惠券和团购信息，评论放在section 3中
        cell = [tableView dequeueReusableCellWithIdentifier:@"Business Comments" forIndexPath:indexPath];
        [VoteBusinessDetailsHelper configureCommentsCell:cell forRowAtIndexPath:indexPath witCommentsInfo:self.commentsInfo];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.frame.size.height - 0.5, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
