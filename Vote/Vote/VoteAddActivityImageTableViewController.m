//
//  VoteAddActivityImageTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-11.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAddActivityImageTableViewController.h"
#import "UIImage+UIImageHelper.h"
#import "VoteCreateActivityTableViewController.h"

@interface VoteAddActivityImageTableViewController ()

@property (strong, nonatomic) NSArray *sectionTitle;
@property (strong, nonatomic) NSArray *sectionContainer;

@end

@implementation VoteAddActivityImageTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sectionTitle = [[NSArray alloc] initWithObjects:@"聚会", @"饭团", @"休闲娱乐", @"运动健身", @"旅游" , nil];
    NSArray *party = [[NSArray alloc] initWithObjects:@"小聚一下", @"生日聚会", @"好久不见", @"不醉不归", nil];
    NSArray *meal = [[NSArray alloc] initWithObjects:@"吃个便饭", @"上档次", nil];
    NSArray *entertainment = [[NSArray alloc] initWithObjects:@"约会", @"看电影", @"棋牌", @"K歌", @"游戏", nil];
    NSArray *sports = [[NSArray alloc] initWithObjects:@"篮球", @"足球", @"羽毛球", @"台球", nil];
    NSArray *travel = [[NSArray alloc] initWithObjects:@"城市周边", @"长途跋涉", nil];
    self.sectionContainer = [[NSArray alloc] initWithObjects:party, meal, entertainment, sports, travel, nil];
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
    return [self.sectionContainer count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.sectionContainer objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 25.0)];
    //uv.layer.borderWidth = 1.0;
    //uv.layer.borderColor = [[UIColor blackColor] CGColor];
    uv.backgroundColor = UIColorFromRGB(0xEFEFF4);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10, 270, 15.0)];
    if (section == 0) {
        title.frame = CGRectMake(15.0, 10, 270, 15.0);
    }
    title.backgroundColor = [UIColor clearColor];
    title.text = [self.sectionTitle objectAtIndex:section];
    
    title.textColor = UIColorFromRGB(0x4C566C);
    title.font = [UIFont systemFontOfSize:14.0];
    [uv addSubview:title];
    
    return uv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Activity Image" forIndexPath:indexPath];
    
    // Configure the cell...
    UIImage *image = [UIImage imageNamed:@"sports.png"];
    CGSize itemSize = CGSizeMake(30.0, 30.0);
    cell.imageView.image = [UIImage imageWithImage:image scaledToSize:itemSize];
    cell.textLabel.text = [[self.sectionContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *imageAttr = @{@"name":@"sports.png", @"text":[[self.sectionContainer objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]};
    if (self.activityImgName) {
        self.activityImgName(imageAttr);
    }
    NSArray *navArr = self.navigationController.viewControllers;
    for (UIViewController *nav in navArr)
    {
        if ([nav isKindOfClass:[VoteCreateActivityTableViewController class]])
        {
            [self.navigationController popToViewController:nav animated:YES];
        }
    }
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
