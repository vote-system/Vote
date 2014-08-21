//
//  VoteChangeScreenNameViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteChangeScreenNameViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteChangeScreenNameViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *theNewScreenname;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@end

@implementation VoteChangeScreenNameViewController

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
    [self.theNewScreenname becomeFirstResponder];
}

- (IBAction)save:(id)sender {
    //连接网络提示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.rightBarButtonItem.customView = spinner;
    //发送更新请求
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/update_user_info.php"];
    NSDictionary *para = @{SERVER_USERNAME: username, SERVER_SCREENNAME:self.theNewScreenname.text};
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
        if (self.theNewScreenNameCallBack) {
            self.theNewScreenNameCallBack(self.theNewScreenname.text);
        }
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"昵称更新成功"
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
        alert = [[UIAlertView alloc] initWithTitle:@"昵称更新失败"
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //删除字符打的时候
    if([string length] == 0)
    {
        if([textField.text length] != 0)
        {
            return YES;
        }
    }
    //输入字符的时候
    else if([[textField text] length] > 12)
    {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    //找到键盘左上角的y坐标
    CGFloat keyPointY = [UIScreen mainScreen].bounds.size.height - 216;
    //判断当前textField的左下角y坐标是否大于键盘左上角的y坐标
    if (textField.frame.origin.y + textField.frame.size.height > keyPointY)
    {
        //设置偏移值
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height - keyPointY + 30;
        //将view上移到中文输入下不遮住uitextfield。
        frame.origin.y -= offset;
        //不设置时键盘出现时会有黑色
        frame.size.height += offset;
        const float animationDuration = 0.3f;
        [UIView beginAnimations:@"ResizeView" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
    }
    /*
     //增加手势，点击空白处收起键盘
     UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
     tapGestureRecognizer.numberOfTapsRequired = 1;
     tapGestureRecognizer.numberOfTouchesRequired = 1;
     [self.view addGestureRecognizer: tapGestureRecognizer];
     */
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    //找到键盘左上角的y坐标
    CGFloat keyPointY = [UIScreen mainScreen].bounds.size.height - 216;
    if (textField.frame.origin.y + textField.frame.size.height > keyPointY)
    {
        //设置偏移值
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height - keyPointY + 30;
        //还原上移的view
        frame.origin.y += offset;
        frame.size.height -= offset;
        const float animationDuration = 0.3f;
        [UIView beginAnimations:@"ResizeView" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
    }
    return YES;
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
