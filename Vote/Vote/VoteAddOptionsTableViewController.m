//
//  VoteAddOptionsTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAddOptionsTableViewController.h"
#import "VoteSelectCategoryTableViewController.h"
#import "VoteDefaultOptionsListViewController.h"
#import "DianPingAPI.h"
#import "NSString+NSStringHelper.h"
#import "VoteCustomAddressViewController.h"

@interface VoteAddOptionsTableViewController () <UITextFieldDelegate, SelectOptionCategoryDelegate, AddCustomAddressDelegate, AddBusinessOptionDelegate>
{
    NSArray *sectionTitles;
}

@property (strong, nonatomic) UITextField *optionName;
@property (strong, nonatomic) NSString *optionCatrgory;
@property (strong, nonatomic) NSString *customAddress;
@property (strong, nonatomic) NSMutableDictionary *optionAddress;//储存大众点评网信息

@end

@implementation VoteAddOptionsTableViewController

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
    sectionTitles = [[NSArray alloc] initWithObjects:@"名称", @"分类", @"地点", nil];
    self.optionAddress = [[NSMutableDictionary alloc] initWithCapacity:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//添加选项
- (IBAction)addOptions:(id)sender {
    NSMutableDictionary *data = nil;
    if ([NSString checkWhitespaceAndNewlineCharacter:self.optionName.text] == YES) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"名称不可为空" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [av show];
        return;
    }
    if ([self.optionCatrgory length] <= 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"分类不可为空" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [av show];
        return;
    }
    data = [NSMutableDictionary dictionary];
    [data setObject:self.optionName.text forKey:SERVER_OPTIONS_NAME];
    [data setObject:self.optionCatrgory forKey:SERVER_OPTIONS_CATEGORY];
    if ([self.optionAddress count] > 0) {
        [data setObject:[self.optionAddress objectForKey:SERVER_OPTIONS_BUSINESS_ID] forKey:SERVER_OPTIONS_BUSINESS_ID];
        [data setObject:[self.optionAddress objectForKey:SERVER_OPTIONS_ADDRESS] forKey:SERVER_OPTIONS_ADDRESS];
    } else if ([self.customAddress length] > 0) {
        NSNumber *num = [NSNumber numberWithInteger:BUSINESS_ID_OF_CUSTOM_ADDR];
        [data setObject:num forKey:SERVER_OPTIONS_BUSINESS_ID];
        [data setObject:self.customAddress forKey:SERVER_OPTIONS_ADDRESS];
    } else {
        NSNumber *num = [NSNumber numberWithInteger:BUSINESS_ID_OF_NO_ADDR];
        [data setObject:num forKey:SERVER_OPTIONS_BUSINESS_ID];
        [data setObject:[NSNull null] forKey:SERVER_OPTIONS_ADDRESS];
    }
    [self.addOptionsDelegate addOptionWithData:data];
    NSArray *navArr = self.navigationController.viewControllers;
    for (UIViewController *nav in navArr)
    {
        if ([nav isKindOfClass:[VoteCreateActivityTableViewController class]])
        {
            [self.navigationController popToViewController:nav animated:YES];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 50.0;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        return 50.0;
    } else {
        CGFloat height = 0.0;
        CGFloat width = 290.0;
        if ([self.optionAddress count] > 0) {
            height = [NSString calculateTextHeight:[self.optionAddress objectForKey:SERVER_OPTIONS_ADDRESS] font:[UIFont systemFontOfSize:15.0] width:width];
        } else if ([self.customAddress length] > 0) {
            height = [NSString calculateTextHeight:self.customAddress font:[UIFont systemFontOfSize:15.0] width:width];
        }
        if (height + 20.0 < 50.0) {
            return 50.0;
        } else {
            return height + 20.0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0;
    }
    return 25.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 25.0)];
    //uv.layer.borderWidth = 1.0;
    //uv.layer.borderColor = [[UIColor blackColor] CGColor];
    uv.backgroundColor = UIColorFromRGB(0xEFEFF4);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 270, 15.0)];
    if (section == 0) {
        title.frame = CGRectMake(15.0, 10, 270, 15.0);
    }
    title.backgroundColor = [UIColor clearColor];
    title.text = [sectionTitles objectAtIndex:section];
    title.textColor = UIColorFromRGB(0x4C566C);
    title.font = [UIFont systemFontOfSize:14.0];
    //title.layer.borderWidth = 1.0;
    //title.layer.borderColor = [[UIColor blackColor] CGColor];
    [uv addSubview:title];
    
    return uv;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Name" forIndexPath:indexPath];
        [cell.contentView addSubview:self.optionName];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Category" forIndexPath:indexPath];
        if (self.optionCatrgory != nil) {
            cell.textLabel.text = self.optionCatrgory;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.textLabel.text = @"点击选择分类";
            cell.textLabel.textColor = UIColorFromRGB(0xC7C7CD);
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Location" forIndexPath:indexPath];
        // 删除cell中的子对象,刷新覆盖问题。
        while ([cell.contentView.subviews lastObject] != nil)
        {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        UILabel *locationText = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 290.0, cell.frame.size.height - 20)];
        locationText.font = [UIFont systemFontOfSize:15.0];
        locationText.textAlignment = NSTextAlignmentLeft;
        locationText.numberOfLines = 0;
        locationText.lineBreakMode = NSLineBreakByWordWrapping;
        locationText.textColor = [UIColor blackColor];
        [cell.contentView addSubview:locationText];
        if ([self.optionAddress count] > 0) {
            locationText.text = [self.optionAddress objectForKey:SERVER_OPTIONS_ADDRESS];
        } else if ([self.customAddress length] > 0) {
            locationText.text = self.customAddress;
        } else {
            locationText.text = @"点击添加";
            locationText.textColor = UIColorFromRGB(0xC7C7CD);
        }
    }
    
    
    return cell;
}

#pragma mark - UITableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"Select Option Category" sender:indexPath];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"Select Option Location" sender:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //清空当前cell内容
        [self.optionAddress removeAllObjects];
        self.customAddress = @"";
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"清空";
}

- (UITextField *)optionName
{
    if (_optionName == nil) {
        CGRect frame = CGRectMake(15, 0, 290, 50.0);
        _optionName = [[UITextField alloc] initWithFrame:frame];
        _optionName.font = [UIFont systemFontOfSize:15];
        //_subject.textColor = [UIColor grayColor];
        _optionName.placeholder = @"选项名称";
        _optionName.autocorrectionType = UITextAutocorrectionTypeNo;
        _optionName.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _optionName.textAlignment = NSTextAlignmentLeft;
        _optionName.keyboardType = UIKeyboardTypeDefault;
        _optionName.returnKeyType = UIReturnKeyDone;
        _optionName.clearButtonMode = UITextFieldViewModeWhileEditing;
        _optionName.delegate = self;
    }
    
    return _optionName;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

//分类选择
- (void)selectOptionCategory:(NSString *)category
{
    self.optionCatrgory = category;
    [self.tableView reloadData];
}

//自定义地址回调
- (void)addCustomAddress:(NSString *)address
{
    [self.optionAddress removeAllObjects];
    self.customAddress = address;
    [self.tableView reloadData];
}

//商户地址回调
- (void)addBusinessWithData:(NSDictionary *)data
{
    self.customAddress = @"";
    if ((NSNull *)[data objectForKey:DIANPING_BUSINESS_ID] != [NSNull null]) {
        NSNumber *businessID = [data objectForKey:DIANPING_BUSINESS_ID];
        [self.optionAddress setObject:businessID forKey:SERVER_OPTIONS_BUSINESS_ID];
    } else {
        [self.optionAddress setObject:[NSNull null] forKey:SERVER_OPTIONS_BUSINESS_ID];
    }
    if ((NSNull *)[data objectForKey:DIANPING_NAME] != [NSNull null]) {
        NSString *name;
        NSString *prename = [data objectForKey:DIANPING_NAME];
        if ((NSNull *)[data objectForKey:DIANPING_BRANCH_NAME] != [NSNull null]) {
            NSString *subname = [data objectForKey:DIANPING_BRANCH_NAME];
            name = [[NSString alloc] initWithFormat:@"%@(%@)", prename, subname];
        } else {
            name = prename;
        }
        [self.optionAddress setObject:name forKey:SERVER_OPTIONS_ADDRESS];
    } else {
        [self.optionAddress setObject:[NSNull null] forKey:SERVER_OPTIONS_ADDRESS];
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Select Option Category"]) {
        VoteSelectCategoryTableViewController *tvc = segue.destinationViewController;
        tvc.optionCategoryDelegate = self;
        
    } else if ([segue.identifier isEqualToString:@"Select Option Location"]) {
        //VoteDefaultOptionsListViewController *vc = segue.destinationViewController;

    } else {
    
    }
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}


@end
