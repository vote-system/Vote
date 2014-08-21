//
//  VoteForgetPasswordViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-2.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteForgetPasswordViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteForgetPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameOrEmail;

@end

@implementation VoteForgetPasswordViewController

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
    [self.usernameOrEmail becomeFirstResponder];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender {
    //发送所有注册信息进行注册
    NSDictionary *para = nil;
    NSString *textRegex = @"@";
    NSPredicate *uoePredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", textRegex];
    if ([uoePredicate evaluateWithObject:self.usernameOrEmail.text]) {
        para = @{@"email": self.usernameOrEmail.text};
    } else {
        para = @{@"username": self.usernameOrEmail.text};
    }
    NSString *registerURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/228/forget.php"];
    
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:registerURL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"发送成功" message:@"请查收邮件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [successAlert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"发送失败" message:@"哪地方错了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [failureAlert show];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
