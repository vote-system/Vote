//
//  VoteFourthViewController.m
//  Vote
//
//  Created by 丁 一 on 14-3-17.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteFourthViewController.h"
#import "VoteLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VoteFourthViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *setInfoTableView;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;


@end

@implementation VoteFourthViewController

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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.logoutBtn.backgroundColor = UIColorFromRGB(0xFF3030);
    self.logoutBtn.tintColor = [UIColor whiteColor];
    
}

- (void)deleteCookies
{
    NSString *loginURL = [[NSString alloc] initWithFormat:@"115.28.228.41"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:loginURL]];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (IBAction)signout:(id)sender {
    [self deleteCookies];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:SERVER_AUTHENTICATED];
    [ud setBool:NO forKey:SIGN_IN_FLAG];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VoteLoginViewController *lvc=[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [lvc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [lvc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:lvc animated:YES completion:^{
        NSString *url = [[NSString alloc] initWithFormat:@"http://115.28.228.41/vote/logout.php"];
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud objectForKey:USERNAME];
        NSDictionary *para = @{SERVER_USERNAME: username};
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation: %@", operation);
            NSLog(@"responseObject: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"operation: %@", operation);
            NSLog(@"operation: %@", operation.responseString);
            NSLog(@"Error: %@", error);
        }];
    }];
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
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Personal Setting";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"个人信息";
            cell.imageView.image = [UIImage imageNamed:@"personalInfo.png"];
            break;
        case 1:
            cell.textLabel.text = @"密码修改";
            cell.imageView.image = [UIImage imageNamed:@"personalInfo.png"];
            break;
        case 2:
            cell.textLabel.text = @"问题反馈";
            cell.imageView.image = [UIImage imageNamed:@"personalInfo.png"];
            break;
        case 3:
            cell.textLabel.text = @"给个评分";
            cell.imageView.image = [UIImage imageNamed:@"personalInfo.png"];
            break;
        case 4:
            cell.textLabel.text = @"新版本检测";
            cell.imageView.image = [UIImage imageNamed:@"personalInfo.png"];
            break;
        case 5:
            cell.textLabel.text = @"关于投票";
            cell.imageView.image = [UIImage imageNamed:@"personalInfo.png"];
            break;
        default:
            break;
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"modify personal info" sender:self];
    } else {
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //设置返回键的标题
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
