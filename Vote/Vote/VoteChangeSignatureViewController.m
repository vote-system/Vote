//
//  VoteChangeSignatureViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-25.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteChangeSignatureViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteChangeSignatureViewController () <UIAlertViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *signatureTextView;
@property (weak, nonatomic) IBOutlet UILabel *wordsPrompt;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;


@end

@implementation VoteChangeSignatureViewController

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
    self.signatureTextView.layer.borderWidth = 1.0;
    self.signatureTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.wordsPrompt.text = @"还可输入30个字";
    //self.wordsPrompt.layer.borderWidth = 1.0;
    //self.wordsPrompt.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.signatureTextView becomeFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)save:(id)sender {
    if ([self.signatureTextView.text length] > 30 || [self.signatureTextView.text length] <= 0) {
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"字数不满足要求"
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.rightBarButtonItem.customView = spinner;
    //发送更新请求
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/update_user_info.php"];
    NSDictionary *para = @{SERVER_USERNAME: username, SERVER_USER_SIGNATURE:self.signatureTextView.text};
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
        if (self.signatureCallBack) {
            self.signatureCallBack(self.signatureTextView.text);
        }
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"签名更新成功"
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
        alert = [[UIAlertView alloc] initWithTitle:@"签名更新失败"
                                           message:@"无网络连接或服务器出错，请稍后再试"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //设置换行符为退出键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    //删除字符打的时候
    if([text length] == 0)
    {
        if([textView.text length] != 0)
        {
            return YES;
        }
    }
    //输入字符的时候
    else if([[textView text] length] > 29)
    {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    int len = (int)textView.text.length;
    self.wordsPrompt.text = [NSString stringWithFormat:@"还可输入%i个字",30-len];
    if (30-len < 0) {
        self.wordsPrompt.textColor = [UIColor redColor];
    } else {
        self.wordsPrompt.textColor = [UIColor blackColor];
    }
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
