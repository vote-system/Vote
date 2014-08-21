//
//  VoteFriendsSendAddReqViewController.m
//  Vote
//
//  Created by 丁 一 on 14-7-23.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteFriendsSendAddReqViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteFriendsSendAddReqViewController ()

@property (weak, nonatomic) IBOutlet UITextField *additionalMsg;

@end

@implementation VoteFriendsSendAddReqViewController

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
    [self.additionalMsg becomeFirstResponder];
}


- (IBAction)sendReq:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    NSString *addFriendsURL = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/friend.php"];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSNumber *friendAction = [[NSNumber alloc] initWithInt:ADD_FRIEND_REQUEST];
    NSDictionary *para = @{SERVER_USERNAME: username, SERVER_FRIEND_NAME:self.username, SERVER_FRIEND_ACTION:friendAction, SERVER_ADD_FRIEND_MSG:self.additionalMsg.text};
    NSLog(@"URL para = %@", para);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:addFriendsURL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"operation: %@", operation);
        NSLog(@"responseObject: %@", responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
        });
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"发送成功"
                                           message:@"添加好友请求已发送"
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
            self.navigationItem.rightBarButtonItem = sender;
        });
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"请求发送失败"
                                           message:@"网络错误，请稍后再试"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
