//
//  VoteHomeViewController.m
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "VoteHomeViewController.h"
#import "VoteLoginViewController.h"
#import "CoreDataHelper.h"
#import "VoteFirstTableViewController.h"
#import "VoteSecondTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Users+UsersHelper.h"

@interface VoteHomeViewController ()

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation VoteHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //更改tabbar样式
    [[UITabBar appearance] setBarTintColor:UIColorFromRGB(0xF7F7F7)];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:10.0f], NSForegroundColorAttributeName:UIColorFromRGB(0x8E8E8E)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:10.0f], NSForegroundColorAttributeName:UIColorFromRGB(0xEE0000)} forState:UIControlStateSelected];
    UITabBarItem *item;
    NSArray *imageArray = [[NSArray alloc] initWithObjects:@"first.png", @"second.png", @"third.png", @"fourth.png", nil];
    NSArray *textArray = [[NSArray alloc] initWithObjects:@"首页", @"通讯录", @"热门", @"设置", nil];
    NSArray *selectedImageArray = [[NSArray alloc] initWithObjects:@"selectedFirst.png", @"selectedSecond.png", @"selectedThird.png", @"selectedFourth.png", nil];
    
    for (int i = 0; i < [imageArray count]; i++)
    {
        item = [self.tabBar.items objectAtIndex:i];
        NSString *imageName = [[NSString alloc] initWithString:[imageArray objectAtIndex:i]];
        NSString *selectedImageName = [[NSString alloc] initWithString:[selectedImageArray objectAtIndex:i]];
        item.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.title = [textArray objectAtIndex:i];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]}];
    //UIImage *image = [UIImage imageNamed:@"green-menu-bar.png"];
    //[[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundColor:UIColorFromRGB(0xEE0000)];
    //1744BD 325BCA 399FDF 257CD3 267CD3 1981ea
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x1D66F1)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} forState:UIControlStateNormal];
    
    [self loadCookies];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    if ([ud boolForKey:SIGN_IN_FLAG] == NO) {
        [ud setBool:YES forKey:SIGN_IN_FLAG];
        //用户退出后，回到第一个tab界面
        [self setSelectedIndex:0];
    }
    //authenticated = YES;
    //增加一个覆盖view，让tabbarview不可见
    if (authenticated == NO) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        UIView *uv = [[UIView alloc] initWithFrame:rect];
        uv.tag = HVC_PRELOAD_VIEW_TAG;
        uv.backgroundColor = [UIColor blackColor];
        [self.view addSubview:uv];
    } else {
        if ([self.view viewWithTag:HVC_PRELOAD_VIEW_TAG] != nil) {
            [[self.view viewWithTag:HVC_PRELOAD_VIEW_TAG] removeFromSuperview];
        }
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    authenticated = [ud boolForKey:SERVER_AUTHENTICATED];
    //authenticated = YES;
    if (authenticated == YES) {
        //清除badge number
        NSLog(@"authen=%d", authenticated);
        
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VoteLoginViewController *lvc=[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [lvc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [lvc setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:lvc animated:YES completion:nil];
    }
}



- (void)loadCookies{
    
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    if ([cookies count] == 0) {
        return;
    }
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
