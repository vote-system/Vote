//
//  VoteLoginViewController.m
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "VoteSignUpViewController.h"
#import "CoreDataHelper.h"
#import "Users+UsersHelper.h"

@interface VoteLoginViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UITableView *loginTableView;
@property (strong, nonatomic) UITextField *usenameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation VoteLoginViewController

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
    self.view.backgroundColor = UIColorFromRGB(0xF8F8FF);
    self.loginData = @[@"帐号", @"密码"];
    //self.loginTableView.layer.cornerRadius = 6.0;
    self.loginTableView.separatorInset = UIEdgeInsetsZero;
    self.loginTableView.layer.borderWidth = 1.0;
    self.loginTableView.layer.borderColor = CGColorCreateCopyWithAlpha([[UIColor grayColor] CGColor], 1.0);
    self.loginTableView.layer.masksToBounds = NO;
    self.loginTableView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.loginTableView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.loginTableView.layer.shadowRadius = 3.0f;
    self.loginTableView.layer.shadowOpacity = 0.5f;
    self.loginTableView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.loginTableView.layer.bounds] CGPath];
    self.loginTableView.separatorColor = [UIColor grayColor];//设置行间隔边框
    
    self.loginBtn.backgroundColor = UIColorFromRGB(0x3C78D8);
    self.loginBtn.tintColor = [UIColor whiteColor];
    
}


- (IBAction)signup:(id)sender {
    //[self performSegueWithIdentifier:@"Sign Up" sender:self];
    
}

- (IBAction)forgetPassword:(id)sender {
    
}

- (void)saveCookies{
    NSLog(@"cookies = %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject: cookiesData forKey: @"sessionCookies"];
    [ud synchronize];
}

- (void)deleteCookies
{
    //NSString *url = [[NSString alloc] initWithFormat:@"115.28.228.41"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    NSLog(@"cookies = %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
}

- (IBAction)login:(id)sender {
    [self deleteCookies];
    [self startLoadingView];
    NSString *loginURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/login.php"];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [ud objectForKey:DEVICE_TOKEN];
    NSLog(@"%@", deviceToken);
    NSDictionary *para = @{SERVER_USERNAME:self.usenameTextField.text, SERVER_PASSWORD:self.passwordTextField.text, DEVICE_TOKEN:deviceToken};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:loginURL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [self endLoadingView];
        NSInteger loginResponse = [[(NSDictionary *)responseObject objectForKey:SERVER_LOGIN_RESPONSE] integerValue];
        if (loginResponse == LOGIN_SUCCESS) {
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            [ud setBool:YES forKey:SERVER_AUTHENTICATED];
            [ud setObject:self.usenameTextField.text forKey:USERNAME];
            [ud setObject:self.passwordTextField.text forKey:PASSWORD];
            [ud synchronize];
            [self saveCookies];

            [self dismissViewControllerAnimated:YES completion:nil];
        } else if (loginResponse == DB_ITEM_NOT_FOUND) {
            UIView *loadingView = (UIView *)[self.view viewWithTag:LVC_LOADING_VIEW_TAG];
            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[loadingView viewWithTag:LVC_ACTIVITY_INDICATOR_TAG];
            [activityIndicator stopAnimating];
            [loadingView removeFromSuperview];
            UIAlertView *alert = nil;
            alert = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                               message:@"用户名或密码错误"
                                              delegate:nil
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil];
            [alert show];
        } else {
            UIView *loadingView = (UIView *)[self.view viewWithTag:LVC_LOADING_VIEW_TAG];
            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[loadingView viewWithTag:LVC_ACTIVITY_INDICATOR_TAG];
            [activityIndicator stopAnimating];
            [loadingView removeFromSuperview];
            UIAlertView *alert = nil;
            alert = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                               message:@"服务器错误，请稍后再试"
                                              delegate:nil
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil];
            [alert show];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [self endLoadingView];
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                           message:@"服务器错误"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }];

}

- (void)startLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIView *loadingView;
    UILabel *label;
    UIActivityIndicatorView *activityIndicator;
    
    if ([self.view viewWithTag:LVC_LOADING_VIEW_TAG] == nil) {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        loadingView.center = self.view.center;
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.6;
        loadingView.tag = LVC_LOADING_VIEW_TAG;
        loadingView.layer.cornerRadius = 6.0;
        [self.view addSubview: loadingView];
        
        CGRect loadingViewFrame = loadingView.bounds;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        label.center = CGPointMake(loadingViewFrame.origin.x + loadingViewFrame.size.width/2, loadingViewFrame.origin.y + loadingViewFrame.size.height/2 - 25);
        label.text = @"请稍等...";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [loadingView addSubview:label];
        
        
        activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        activityIndicator.center = CGPointMake(loadingViewFrame.origin.x + loadingViewFrame.size.width/2, loadingViewFrame.origin.y + loadingViewFrame.size.height/2 + 25);
        [loadingView addSubview: activityIndicator];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.tag = LVC_ACTIVITY_INDICATOR_TAG;
        
        [activityIndicator startAnimating];
    }
}

- (void)endLoadingView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIView *loadingView = (UIView *)[self.view viewWithTag:LVC_LOADING_VIEW_TAG];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[loadingView viewWithTag:LVC_ACTIVITY_INDICATOR_TAG];
    [activityIndicator stopAnimating];
    [loadingView removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //判断是否为跳转到详细界面
    if ([segue.identifier isEqualToString: @"Sign Up"])
    {
        
    }
    else if ([segue.identifier isEqualToString: @"Forget Password"])
    {

    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Login" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = UIColorFromRGB(0xFFFFFF);
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:15];
    
    cell.textLabel.text = [self.loginData objectAtIndex: indexPath.row];
    
    UITextField *textField;
    
    if (indexPath.row == 0) {
        textField = self.usenameTextField;
    } else {
        textField = self.passwordTextField;
    }
    
    // make sure this textfield's width matches the width of the cell
    CGRect newFrame = textField.frame;
    NSLog(@"frame = %f, %f", newFrame.size.width, newFrame.size.height);
    newFrame.origin.x = cell.contentView.frame.origin.x + 60;
    newFrame.origin.y = cell.contentView.frame.origin.y + cell.contentView.frame.size.height/2 - newFrame.size.height/2;
    NSLog(@"cell contentview y = %f, height = %f", cell.contentView.frame.origin.y, cell.contentView.frame.size.height);
    NSLog(@"cell y = %f, height = %f", cell.frame.origin.y, cell.frame.size.height);
    newFrame.size.width = CGRectGetWidth(cell.contentView.frame) - 10*7;
    NSLog(@"frame = %f, %f", newFrame.origin.y, newFrame.size.height);
    textField.frame = newFrame;
    NSLog(@"textField.frame = %f, %f", textField.frame.origin.y, textField.frame.size.height);
    // if the cell is ever resized, keep the textfield's width to match the cell's width
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [cell.contentView addSubview:textField];
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    //找到键盘左上角的y坐标
    CGFloat keyPointY = [UIScreen mainScreen].bounds.size.height - 216;
    //判断当前textField的左下角y坐标是否大于键盘左上角的y坐标
    //if (textField.frame.origin.y + textField.frame.size.height > keyPointY)
    {
        //设置偏移值
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height - keyPointY + 30;
        offset = 50.0;
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
/*
//收起键盘
- (void)hideKeyBoard:(id)sender
{
    [(UITextField *)sender  resignFirstResponder];
}
 */

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField//编辑结束view移回原先的位置
{
    CGRect frame = self.view.frame;
    //找到键盘左上角的y坐标
    CGFloat keyPointY = [UIScreen mainScreen].bounds.size.height - 216;
    //if (textField.frame.origin.y + textField.frame.size.height > keyPointY)
    {
        //设置偏移值
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height - keyPointY + 30;
        offset = 50.0;
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

- (UITextField *)usenameTextField
{
    if (_usenameTextField == nil)
    {
        CGRect frame = CGRectMake(20, 20, 20, 30);
        _usenameTextField = [[UITextField alloc] initWithFrame:frame];
        
        self.usenameTextField.borderStyle = UITextBorderStyleNone;
        self.usenameTextField.textColor = [UIColor blackColor];
        self.usenameTextField.font = [UIFont fontWithName:@"Verdana" size:15];
        //self.usenameTextField.placeholder = @"Email...";
        self.usenameTextField.backgroundColor = UIColorFromRGB(0xFFFFFF);
        self.usenameTextField.autocorrectionType = UITextAutocorrectionTypeNo;  // no auto correction support
        self.usenameTextField.textAlignment = NSTextAlignmentLeft;
        self.usenameTextField.keyboardType = UIKeyboardTypeASCIICapable;
        self.usenameTextField.returnKeyType = UIReturnKeyDone;
        
        self.usenameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;    // has a clear 'x' button to the right
        self.usenameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.usenameTextField.tag = 1;       // tag this control so we can remove it later for recycled cells
        
        self.usenameTextField.delegate = self;  // let us be the delegate so we know when the keyboard's "Done" button is pressed
        
    }
    return _usenameTextField;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil)
    {
        CGRect frame = CGRectMake(20, 20, 20, 30);
        _passwordTextField = [[UITextField alloc] initWithFrame:frame];
        
        self.passwordTextField.borderStyle = UITextBorderStyleNone;
        self.passwordTextField.textColor = [UIColor blackColor];
        self.passwordTextField.font = [UIFont fontWithName:@"Verdana" size:15];
        self.passwordTextField.backgroundColor = UIColorFromRGB(0xFFFFFF);
        self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;  // no auto correction support
        self.usenameTextField.textAlignment = NSTextAlignmentLeft;
        self.passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.passwordTextField.returnKeyType = UIReturnKeyDone;
        self.passwordTextField.secureTextEntry = YES; // make the text entry secure (bullets)
        self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;    // has a clear 'x' button to the right
        
        self.passwordTextField.tag = 1;       // tag this control so we can remove it later for recycled cells
        
        self.passwordTextField.delegate = self;  // let us be the delegate so we know when the keyboard's "Done" button is pressed
    }
    return _passwordTextField;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
    // or UIStatusBarStyleBlackOpaque, UIStatusBarStyleBlackTranslucent, or UIStatusBarStyleDefault
    
}

@end
