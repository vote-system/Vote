//
//  VoteAddFriendsViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-15.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAddFriendsViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "VoteFriendsDetailsInfoTableViewController.h"
#import "CoreDataHelper.h"
#import "Friends+FriendsHelper.h"

@interface VoteAddFriendsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *friendNameTextField;
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation VoteAddFriendsViewController

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
    [self.friendNameTextField becomeFirstResponder];
    self.friendNameTextField.keyboardType = UIKeyboardTypeASCIICapable;
	// Do any additional setup after loading the view.
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        //create nsfetchresultcontroller...
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
    }];
}

- (IBAction)search:(id)sender {
    
    if (self.friendNameTextField.text.length > 0) {
        //连接网络提示
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        NSString *getInfoURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/get_user_info.php"];
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud objectForKey:USERNAME];
        NSDictionary *para = @{SERVER_USERNAME: username, SERVER_FETCH_NAME:self.friendNameTextField.text};
        NSLog(@"URL para = %@", para);
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        [manager GET:getInfoURL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSLog(@"operation: %@", operation);
            NSLog(@"responseObject: %@", responseObject);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = sender;
            });
            [self performSegueWithIdentifier:@"Stranger Info" sender:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"operation: %@", operation);
            NSLog(@"operation: %@", operation.responseString);
            NSLog(@"Error: %@", error);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = sender;
            });
            UIAlertView *alert = nil;
            alert = [[UIAlertView alloc] initWithTitle:@"查询失败"
                                               message:@"无网络或服务器错误，请稍后再试"
                                              delegate:nil
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil];
            [alert show];
        }];
    } else {
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"输入错误"
                                           message:@"用户名不可为空"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Stranger Info"]) {
        NSDictionary *data = (NSDictionary *)sender;
        VoteFriendsDetailsInfoTableViewController *friendsDetailsVC = [segue destinationViewController];
        if (!((NSNull *)[data objectForKey:SERVER_USERNAME] == [NSNull null])) {
            friendsDetailsVC.username = [data objectForKey:SERVER_USERNAME];
            Friends *aFriend =[ Friends fetchFriendsWithName:friendsDetailsVC.username withContext:self.managedObjectContext];
            friendsDetailsVC.isFriend = NO;
            if (aFriend != nil) {
                friendsDetailsVC.isFriend = YES;
            }
        }
        if (!((NSNull *)[data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL] == [NSNull null])) {
            friendsDetailsVC.originalHeadImageURL = [data objectForKey:SERVER_ORGINAL_HEAD_IMAGE_URL];
        }
        if (!((NSNull *)[data objectForKey:SERVER_SCREENNAME] == [NSNull null])) {
            friendsDetailsVC.screenname = [data objectForKey:SERVER_SCREENNAME];
        }
        if (!((NSNull *)[data objectForKey:SERVER_GENDER] == [NSNull null])) {
            friendsDetailsVC.gender = [data objectForKey:SERVER_GENDER];
        }
        if (!((NSNull *)[data objectForKey:SERVER_USER_SIGNATURE] == [NSNull null])) {
            friendsDetailsVC.signature = [data objectForKey:SERVER_USER_SIGNATURE];
        }

    } else {
    
    }

}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
