//
//  VoteChangeGenderViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteChangeGenderViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteChangeGenderViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    BOOL selectFlag[2];
}

@property (weak, nonatomic) IBOutlet UITableView *genderTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@property (strong, nonatomic) NSString *gender;

@end

@implementation VoteChangeGenderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    memset(selectFlag, NO, sizeof(selectFlag));
}

- (IBAction)save:(id)sender {
    if ([self.gender length] <= 0) {
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"请选择更新内容"
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
        return;
    }
    //连接网络提示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.rightBarButtonItem.customView = spinner;
    //发送更新请求
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/update_user_info.php"];
    NSDictionary *para = @{SERVER_USERNAME:username, SERVER_GENDER:self.gender};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rightBarButtonItem.customView = nil;
        });
        if (self.genderCallBack) {
            self.genderCallBack(self.gender);
        }
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"性别更新成功"
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rightBarButtonItem.customView = nil;
        });
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"性别更新失败"
                                           message:@"无网络连接或服务器出错，请稍后再试"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }];
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Gender Setting";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"男";
    } else {
        cell.textLabel.text = @"女";
    }
    if (selectFlag[indexPath.row] == YES) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    memset(selectFlag, NO, sizeof(selectFlag));
    selectFlag[indexPath.row] = YES;
    if (indexPath.row == 0) {
        self.gender = @"m";
    } else {
        self.gender = @"f";
    }
    [self.genderTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
    // or UIStatusBarStyleBlackOpaque, UIStatusBarStyleBlackTranslucent, or UIStatusBarStyleDefault
    
}

@end
