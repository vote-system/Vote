//
//  VoteSignUpViewController.m
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteSignUpViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usrnameTextField;

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

@property (weak, nonatomic) IBOutlet UITextField *pswTextField;

@property (weak, nonatomic) IBOutlet UITextField *cfmpswTextField;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UILabel *usrnamePrompt;

@property (weak, nonatomic) IBOutlet UILabel *nicknamePrompt;

@property (weak, nonatomic) IBOutlet UILabel *pswPrompt;

@property (weak, nonatomic) IBOutlet UILabel *cfmpswPrompt;

@property (weak, nonatomic) IBOutlet UILabel *emailPrompt;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSArray *textFields;
@property (strong, nonatomic) NSArray *labels;
@property (assign, nonatomic) BOOL username_unique;
@property (strong, nonatomic) NSMutableDictionary *allCheck;

@end

@implementation VoteSignUpViewController

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
    /*
    self.titleBar.title = self.viewTitle;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.website]];
    [request setCachePolicy:NSURLCacheStorageAllowedInMemoryOnly];
    [self.signupWebview loadRequest:request];
    */
    self.textFields = [[NSArray alloc] initWithObjects:self.usrnameTextField, self.nicknameTextField, self.pswTextField, self.cfmpswTextField, self.emailTextField, nil];
    self.usrnameTextField.tag = USRNAME_TAG;
    self.nicknameTextField.tag = NICKNAME_TAG;
    self.pswTextField.tag = PSW_TAG;
    self.cfmpswTextField.tag = CFMPSW_TAG;
    self.emailTextField.tag = EMAIL_TAG;
    self.username_unique = NO;
    self.allCheck = [[NSMutableDictionary alloc] initWithObjectsAndKeys:INPUT_WRONG, @"username", INPUT_WRONG, @"password", INPUT_WRONG, @"email", nil];
    NSLog(@"%@",self.allCheck);
    [self.usrnameTextField becomeFirstResponder];
    
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}

- (IBAction)send:(id)sender {
    //检查是否有输入框没有填写
    for (UITextField *element in self.textFields) {
        if (element.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册错误" message:@"注册信息未填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    for (id key in self.allCheck) {
        if ([[self.allCheck objectForKey:key] isEqualToString:INPUT_WRONG]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册错误" message:@"注册信息填写错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    //发送所有注册信息进行注册
    NSString *registerURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/228/register.php"];
    self.username_unique = NO;
    NSNumber *usernameUnique = [[NSNumber alloc] initWithBool:self.username_unique];
    NSDictionary *para = @{@"username": self.usrnameTextField.text, @"password":self.pswTextField.text, @"email":self.emailTextField.text, @"username_unique":usernameUnique};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:registerURL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"注册成功" message:@"请返回登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [successAlert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"注册失败" message:@"哪地方错了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [failureAlert show];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag) {
        case USRNAME_TAG:
        {
            [self.allCheck setObject:INPUT_WRONG forKey:@"username"];
            //提示用户名长度是否满足要求
            if (string.length == 0) {
                if (textField.text.length <= 3) {
                    self.usrnamePrompt.textColor = [UIColor redColor];
                    self.usrnamePrompt.text = @"用户名太短";
                }
                else {
                    self.usrnamePrompt.textColor = [UIColor blackColor];
                    self.usrnamePrompt.text = @"3-16个字符，只支持英文和数字";
                }
                return YES;
            }
            //判断输入的是否只有英文和数字
            NSString *textRegex = @"[a-zA-Z0-9]";
            NSPredicate *textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", textRegex];
            if ([textPredicate evaluateWithObject:string]) {
                self.usrnamePrompt.textColor = [UIColor blackColor];
                self.usrnamePrompt.text = @"3-16个字符，只支持英文和数字";
            } else {
                self.usrnamePrompt.textColor = [UIColor redColor];
                self.usrnamePrompt.text = @"格式错误，只支持英文和数字";
                return NO;
            }
            //判断长度是否符合要求
            if (textField.text.length >= 16) {
                self.usrnamePrompt.textColor = [UIColor redColor];
                self.usrnamePrompt.text = @"已达到用户名长度限制";
                return NO;
            }
            else if (textField.text.length <= 1)
            {
                self.usrnamePrompt.textColor = [UIColor redColor];
                self.usrnamePrompt.text = @"用户名太短";
            }
            else {
                self.usrnamePrompt.textColor = [UIColor blackColor];
                self.usrnamePrompt.text = @"3-16个字符，只支持英文和数字";
            }
        }
            break;
        case NICKNAME_TAG:
            NSLog(@"bbb");
            break;
        case PSW_TAG:
        {
            [self.allCheck setObject:INPUT_WRONG forKey:@"password"];
            //提示密码长度要求
            if (string.length == 0) {
                if (textField.text.length <= 6) {
                    self.pswPrompt.textColor = [UIColor redColor];
                    self.pswPrompt.text = @"密码长度未达到要求";
                }
                else {
                    self.pswPrompt.textColor = [UIColor blackColor];
                    self.pswPrompt.text = @"6-16个字符";
                }
                return YES;
            }
            //判断密码长度是否符合要求
            if (textField.text.length >= 16) {
                self.pswPrompt.textColor = [UIColor redColor];
                self.pswPrompt.text = @"已达到密码长度限制";
                return NO;
            }
            else if (textField.text.length <= 4)
            {
                self.pswPrompt.textColor = [UIColor redColor];
                self.pswPrompt.text = @"密码长度未达到要求";
            }
            else {
                self.pswPrompt.textColor = [UIColor blackColor];
                self.pswPrompt.text = @"6-16个字符";
            }
        }
            break;
        case CFMPSW_TAG:
        {
            [self.allCheck setObject:INPUT_WRONG forKey:@"password"];
            //提示密码长度要求
            if (string.length == 0) {
                if (textField.text.length <= 6) {
                    self.cfmpswPrompt.textColor = [UIColor redColor];
                    self.cfmpswPrompt.text = @"密码长度未达到要求";
                }
                else {
                    self.cfmpswPrompt.textColor = [UIColor blackColor];
                    self.cfmpswPrompt.text = @"";
                }
                return YES;
            }
            //判断密码长度是否符合要求
            if (textField.text.length >= 16) {
                self.cfmpswPrompt.textColor = [UIColor redColor];
                self.cfmpswPrompt.text = @"已达到密码长度限制";
                return NO;
            }
            else if (textField.text.length <= 4)
            {
                self.cfmpswPrompt.textColor = [UIColor redColor];
                self.cfmpswPrompt.text = @"密码长度未达到要求";
            }
            else {
                self.cfmpswPrompt.textColor = [UIColor blackColor];
                self.cfmpswPrompt.text = @"";
            }
        }
            break;
        case EMAIL_TAG:
        {
            [self.allCheck setObject:INPUT_WRONG forKey:@"email"];
        }
            break;
        default:
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == USRNAME_TAG)
    {
        //如果没有输入任何用户名，直接返回
        if (textField.text.length < 3) {
            return;
        }
        //如果输入用户名，则进行用户名唯一性检查
        self.username_unique = YES;
        NSString *registerURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/228/register.php"];
        NSNumber *usernameUnique = [[NSNumber alloc] initWithBool:self.username_unique];
        NSDictionary *para = @{@"username": self.usrnameTextField.text, @"username_unique":usernameUnique};
        NSLog(@"URL para = %@", para);
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:registerURL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSLog(@"operation: %@", operation);
            NSLog(@"responseObject: %@", responseObject);
            self.usrnamePrompt.text = @"该用户名可用";
            //用户名输入正确，可以通过
            [self.allCheck setObject:INPUT_RIGHT forKey:@"username"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"operation: %@", operation);
            NSLog(@"operation: %@", operation.responseString);
            NSLog(@"Error: %@", error);
            if (1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络无法连接" message:@"请检查网络再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } else {
                self.usrnamePrompt.textColor = [UIColor redColor];
                self.usrnamePrompt.text = @"该用户名已经存在";
            }
        }];
    }
    //判断两次输入的密码是否一致
    else if (textField.tag == PSW_TAG)
    {
        if (textField.text.length < 6) {
            return;
        }
        if ([self.pswTextField.text isEqualToString:self.cfmpswTextField.text]) {
            [self.allCheck setObject:INPUT_RIGHT forKey:@"password"];
        } else {
            self.cfmpswPrompt.textColor = [UIColor redColor];
            self.cfmpswPrompt.text = @"两次输入的密码不一致";
        }
    }
    //判断两次输入的密码是否一致
    else if (textField.tag == CFMPSW_TAG)
    {
        if (textField.text.length < 6) {
            return;
        }
        if ([self.pswTextField.text isEqualToString:self.cfmpswTextField.text]) {
            [self.allCheck setObject:INPUT_RIGHT forKey:@"password"];
        } else {
            self.cfmpswPrompt.textColor = [UIColor redColor];
            self.cfmpswPrompt.text = @"两次输入的密码不一致";
        }
    }
    else if (textField.tag == EMAIL_TAG)
    {
        BOOL stricterFilter = YES;
        NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
        NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
        NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if ([emailTest evaluateWithObject:textField.text]) {
            [self.allCheck setObject:INPUT_RIGHT forKey:@"email"];
            self.emailPrompt.textColor = [UIColor blackColor];
            self.emailPrompt.text = @"";
        } else {
            self.emailPrompt.textColor = [UIColor redColor];
            self.emailPrompt.text = @"电子邮件输入错误";
        }
        
    }
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
/*
 - (void)webViewDidStartLoad:(UIWebView *)webView
 {
 [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
 //创建UIActivityIndicatorView背底半透明View
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
 [view setTag:108];
 [view setBackgroundColor:[UIColor blackColor]];
 [view setAlpha:0.5];
 [self.view addSubview:view];
 
 self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
 [self.activityIndicator setCenter:view.center];
 [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
 [view addSubview:self.activityIndicator];
 
 [self.activityIndicator startAnimating];
 }
 
 - (void)webViewDidFinishLoad:(UIWebView *)webView
 {
 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
 [self.activityIndicator stopAnimating];
 UIView *view = (UIView*)[self.view viewWithTag:108];
 [view removeFromSuperview];
 UILabel *label = (UILabel*)[self.view viewWithTag:109];
 [label removeFromSuperview];
 }
 
 - (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
 {
 [self.activityIndicator stopAnimating];
 UIView *view = (UIView*)[self.view viewWithTag:108];
 [view removeFromSuperview];
 CGRect rect = CGRectMake(20.0, 104.0, 280.0, 20.0);
 UILabel *label = [[UILabel alloc] initWithFrame:rect];
 [label setTag:109];
 label.text = @"网页无响应，请检查网络再试";
 label.textAlignment = NSTextAlignmentCenter;
 label.font = [UIFont fontWithName:@"STHeitiSC-Light" size:20];
 label.textColor = [UIColor lightGrayColor];
 [self.view addSubview:label];
 }
 */



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
