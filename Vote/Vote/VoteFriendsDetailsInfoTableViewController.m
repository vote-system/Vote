//
//  VoteFriendsDetailsInfoTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-7-20.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteFriendsDetailsInfoTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+UIImageHelper.h"
#import "VoteFriendsSendAddReqViewController.h"
#import "NSString+NSStringHelper.h"

@interface VoteFriendsDetailsInfoTableViewController ()
{
    NSInteger rowNum;
}
@end

@implementation VoteFriendsDetailsInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.username = [[NSString alloc] init];
        self.originalHeadImageURL = [[NSString alloc] init];
        self.screenname = [[NSString alloc] init];
        self.gender = [[NSString alloc] init];
        self.signature = [[NSString alloc] init];
        rowNum = 2;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    if (self.isFriend == NO) {
        rowNum++;
    }
    self.tableView.backgroundColor = UIColorFromRGB(0xEDEDED);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return rowNum;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 100.0;
    } else if (indexPath.row == 1) {
        return [self CalculateCellHeight:indexPath.row font:[UIFont systemFontOfSize:15.0]];
    } else if (indexPath.row == 2) {
        return 84.0;
    }
    return 60.0;
}

//动态的计算需要显示的cell的高度
- (CGFloat)CalculateCellHeight:(NSInteger)row font:(UIFont *)font
{
    //calculate text height
    NSString *text;
    if (row == 1) {
        if ([self.signature length] <= 0) {
            return 45.0;
        }
        text = self.signature;
        //设置一个行高上限
        CGFloat width = 220.0;
        CGSize size = CGSizeMake(width, 2000.0f);
        NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
        [atts setObject:font forKey:NSFontAttributeName];
        CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:atts context:nil];
        
        return rect.size.height + 30.0;
    }
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Basic Info" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 删除cell中的子对象,刷新覆盖问题。
        while ([cell.contentView.subviews lastObject])
        {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        cell.backgroundColor = UIColorFromRGB(0xEDEDED);
        //头像
        CGRect rect = CGRectMake(10.0, 15.0, 70.0, 70.0);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.layer.cornerRadius = 6.0f;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        [self downloadHeadImage:imageView];
        //昵称
        CGFloat screennameWidth = [NSString calculateTextWidth:self.screenname font:[UIFont boldSystemFontOfSize:18.0]];
        rect = CGRectMake(90.0, 20.0, screennameWidth, 22.0);
        UILabel *screenname = [[UILabel alloc] initWithFrame:rect];
        screenname.font = [UIFont boldSystemFontOfSize:18.0];
        screenname.text = self.screenname;
        //screenname.layer.borderColor = [[UIColor blackColor] CGColor];
        //screenname.layer.borderWidth = 1.0;
        [cell.contentView addSubview:screenname];
        //性别
        rect = CGRectMake(screenname.frame.origin.x + screenname.frame.size.width + 10, screenname.frame.origin.y, screenname.frame.size.height, screenname.frame.size.height);
        UIImageView *gender = [[UIImageView alloc] initWithFrame:rect];
        if ([self.gender isEqualToString:@"f"]) {
            gender.image = [UIImage imageNamed:@"male.png"];
        } else {
            gender.image = [UIImage imageNamed:@"male.png"];
        }
        [cell.contentView addSubview:gender];
        //用户名
        CGFloat usernameWidth = [NSString calculateTextWidth:[NSString stringWithFormat:@"注册号: %@", self.username] font:[UIFont systemFontOfSize:15.0]];
        rect = CGRectMake(90.0, 52.0, usernameWidth, 18.0);
        UILabel *username = [[UILabel alloc] initWithFrame:rect];
        username.font = [UIFont systemFontOfSize:15.0];
        username.text = [NSString stringWithFormat:@"注册号: %@", self.username];
        username.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:username];
        //添加cell间的分割线
        CGFloat sepratorHeight = cell.frame.size.height - 0.5;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, sepratorHeight, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
        
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Signature" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 删除cell中的子对象,刷新覆盖问题。
        while ([cell.contentView.subviews lastObject])
        {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        //个人签名标签
        CGRect rect = CGRectMake(10.0, cell.frame.size.height/2 - 9.0, 60.0, 18.0);
        UILabel *title = [[UILabel alloc] initWithFrame:rect];
        title.text = @"个人签名";
        title.textColor = [UIColor grayColor];
        title.font = [UIFont boldSystemFontOfSize:15.0];
        //title.layer.borderWidth = 1.0;
        //title.layer.borderColor = [[UIColor blackColor] CGColor];
        [cell.contentView addSubview:title];
        //个人签名内容
        CGFloat height = cell.frame.size.height - 30;
        rect = CGRectMake(90.0, 15.0, 220, height);
        UILabel *signature = [[UILabel alloc] initWithFrame:rect];
        if ([self.signature length] > 0) {
            signature.text = self.signature;
            signature.lineBreakMode = NSLineBreakByWordWrapping;
            signature.numberOfLines = 0;
        } else {
            signature.text = @"这家伙很懒，什么也没留下";
        }
        signature.font = [UIFont systemFontOfSize:15.0];
        [cell.contentView addSubview:signature];
        //添加cell间的分割线
        CGFloat sepratorHeight = cell.frame.size.height - 0.5;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, sepratorHeight, 320.0, 0.5)];
        v.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:v];
    } else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Add Friend" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xEDEDED);
        // 删除cell中的子对象,刷新覆盖问题。
        while ([cell.contentView.subviews lastObject])
        {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        UIButton *addFriendBtn;
        addFriendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addFriendBtn.frame = CGRectMake(10.0, 40.0, 300.0, 44.0);
        [addFriendBtn setTitle:@"加为好友" forState:UIControlStateNormal];
        [addFriendBtn setBackgroundColor:UIColorFromRGB(0x3C78D8)];
        [addFriendBtn setTintColor:[UIColor whiteColor]];
        addFriendBtn.layer.cornerRadius = 6.0f;
        [addFriendBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        addFriendBtn.tag = indexPath.row;
        [cell.contentView addSubview:addFriendBtn];
    }
    
    return cell;
}

- (void)downloadHeadImage:(UIImageView *)headImageView
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.originalHeadImageURL]];
    __weak UIImageView *weakHeadImage = headImageView;
    //placeholderImage
    UIImage *headImage = [UIImage imageNamed:@"friendLargeHeadImage.png"];
    /*
    __block BOOL success = YES;
    //check directory like .../tmp/user/Friends/username... or .../tmp/user/Strangers/username...
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *path = NSTemporaryDirectory();
    NSString *userPath = [path stringByAppendingPathComponent:username];
    NSString *mainPath;
    if (self.isFriend) {
        mainPath = [userPath stringByAppendingPathComponent:FRIENDS];
    } else {
        mainPath = [userPath stringByAppendingPathComponent:STRANGERS];
    }
    NSString *fullPath = [mainPath stringByAppendingPathComponent:self.screenname];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", ORGINAL_HEAD_IMAGE_NAME, IMAGE_TYPE];
    __block BOOL isDir;
    __block BOOL existed;
    existed = [[NSFileManager defaultManager] fileExistsAtPath:[fullPath stringByAppendingPathComponent:filename] isDirectory:&isDir];
    CGSize itemSize = CGSizeMake(70.0, 70.0);
    if (existed == YES) {
        UIImage *image = [UIImage imageWithContentsOfFile:[fullPath stringByAppendingPathComponent:filename]];
        headImageView.image = [UIImage imageWithImage:image scaledToSize:itemSize];
        return;
    }
     */
    CGSize itemSize = CGSizeMake(70.0, 70.0);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [headImageView setImageWithURLRequest:(NSURLRequest *)request placeholderImage:headImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        /*
        //store in the tmp directory
        existed = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
        if (!(isDir == YES && existed == YES)) {
            success = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (success == NO) {
            NSLog(@"create Directory failed in Friends");
        }
        [UIImage saveImage:image withFileName:ORGINAL_HEAD_IMAGE_NAME ofType:IMAGE_TYPE inDirectory:fullPath];
        weakHeadImage.image = [UIImage imageWithImage:image scaledToSize:itemSize];
         */
        weakHeadImage.image = [UIImage imageWithImage:image scaledToSize:itemSize];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"operation: %@", request);
        NSLog(@"operation: %@", response);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
}

- (void)addFriend
{
    [self performSegueWithIdentifier:@"Send Add Request" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Send Add Request"]) {
        VoteFriendsSendAddReqViewController *friendsSendReqVC = [segue destinationViewController];
        friendsSendReqVC.username = self.username;
    }
}


@end
