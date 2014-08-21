//
//  VoteSetUserInfoTableViewController.m
//  Vote
//
//  Created by 丁 一 on 14-7-17.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteSetUserInfoTableViewController.h"
#import "CoreDataHelper.h"
#import "Users+UsersHelper.h"
#import "UIImage+UIImageHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "VoteChangeScreenNameViewController.h"
#import "VoteChangeGenderViewController.h"
#import "VoteChangeSignatureViewController.h"

@interface VoteSetUserInfoTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>



@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Users *aUser;


@end

@implementation VoteSetUserInfoTableViewController

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
        self.aUser = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CoreDataHelper sharedDatabase:^(UIManagedDocument *database) {
        self.document = database;
        self.managedObjectContext = database.managedObjectContext;
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        NSString *username = [ud objectForKey:USERNAME];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
        NSArray *users = [CoreDataHelper searchObjectsForEntity:USERS withPredicate:predicate andSortKey:nil andSortAscending:NO andContext:self.managedObjectContext];
        self.aUser = [users firstObject];
        [self.tableView reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else
        return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 90.0;
   else
        return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Personal Info" forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"头像";
        UIImageView *headImageView = (UIImageView *)[cell.contentView viewWithTag:SUITVC_HEAD_IMG_TAG];
        if (headImageView == nil) {
            CGRect rect = CGRectMake(210, 10, 70, 70);
            headImageView = [[UIImageView alloc] initWithFrame:rect];
            headImageView.tag = SUITVC_HEAD_IMG_TAG;
            headImageView.layer.cornerRadius = 6.0f;
            headImageView.layer.masksToBounds = YES;
            [cell.contentView addSubview:headImageView];
        }
        if (self.aUser.originalHeadImagePath != nil) {
            NSLog(@"originalHeadImagePath: %@", self.aUser.originalHeadImagePath);
            headImageView.image = [UIImage imageWithContentsOfFile:self.aUser.originalHeadImagePath];
        } else {
            headImageView.image = [UIImage imageNamed:@"friendLargeHeadImage.png"];
        }
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = @"昵称";
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:SUITVC_SCREEN_NAME_TAG];
        if (label == nil) {
            CGRect rect = CGRectMake(90, 10, 190, 30);
            label = [[UILabel alloc] initWithFrame:rect];
            label.tag = SUITVC_SCREEN_NAME_TAG;
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:17.0];
            label.textColor = [UIColor lightGrayColor];
            //label.layer.borderWidth = 1.0;
            //label.layer.borderColor = [[UIColor blackColor] CGColor];
            [cell.contentView addSubview:label];
        }
        if (self.aUser.screenname != nil) {
            label.text = self.aUser.screenname;
        } else {
            label.text= self.aUser.username;
        }

    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = @"性别";
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:SUITVC_GENDER_TAG];
        if (label == nil) {
            CGRect rect = CGRectMake(90, 10, 190, 30);
            label = [[UILabel alloc] initWithFrame:rect];
            label.tag = SUITVC_GENDER_TAG;
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:17.0];
            label.textColor = [UIColor lightGrayColor];
            //label.layer.borderWidth = 1.0;
            //label.layer.borderColor = [[UIColor blackColor] CGColor];
            [cell.contentView addSubview:label];
        }
        if (self.aUser.gender != nil) {
            if ([self.aUser.gender isEqualToString:@"m"]) {
                label.text = @"男";
            } else {
                label.text = @"女";
            }
        } else {
            label.text = @"男";
        }
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        cell.textLabel.text = @"个人签名";
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:SUITVC_SIGNATURE_TAG];
        if (label == nil) {
            CGRect rect = CGRectMake(90, 10, 190, 30);
            label = [[UILabel alloc] initWithFrame:rect];
            label.tag = SUITVC_SIGNATURE_TAG;
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:17.0];
            label.textColor = [UIColor lightGrayColor];
            //label.layer.borderWidth = 1.0;
            //label.layer.borderColor = [[UIColor blackColor] CGColor];
            [cell.contentView addSubview:label];
        }
        if (self.aUser.signature != nil) {
            label.text = self.aUser.signature;
        } else {
            label.text = @"这家伙很懒，什么也没留下";
        }
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选取", nil];
        [myActionSheet showInView:self.view];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self changeScreennameAtIndexPath:indexPath];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self changeGenderAtIndexPath:indexPath];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        [self changeSignatureAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"取消");
    } else {
        switch (buttonIndex) {
            case 0:
                [self selectImageByCamera];
                break;
            case 1:
                [self selectImageFromLibrary];
                break;
            default:
                break;
        }
    }
}

- (void)selectImageByCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

- (void)selectImageFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *tmpImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *image = [tmpImage copy];
        __weak typeof(self) weakSelf = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.managedObjectContext != nil) {
                [weakSelf.managedObjectContext performBlock:^{
                    [weakSelf uploadHeadImage:image ofUser:weakSelf.aUser withContext:weakSelf.managedObjectContext];
                }];
            } else {
                [picker dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void)saveHeadImage:(UIImage *)image ofUser:(Users *)aUser withContext:(NSManagedObjectContext *)context
{
    //存储头像图片为100*100, 50*50, 20*20
    CGSize size = CGSizeMake(ORIGINAL_HEAD_IMAGE_SIZE, ORIGINAL_HEAD_IMAGE_SIZE);
    UIImage *originalHeadImage = [UIImage imageWithImage:image scaledToSize:size];
    size = CGSizeMake(MEDIUM_HEAD_IMAGE_SIZE, MEDIUM_HEAD_IMAGE_SIZE);
    UIImage *mediumHeadImage = [UIImage imageWithImage:image scaledToSize:size];
    size = CGSizeMake(THUMBNAILS_HEAD_IMAGE_SIZE, THUMBNAILS_HEAD_IMAGE_SIZE);
    UIImage *thumbnailsHeadImage = [UIImage imageWithImage:image scaledToSize:size];
    
    //存储为本地文件
    BOOL success = [Users checkStoreDirectoryforUser:aUser];
    if (success) {
        NSString *originalHeadImagePath = [Users saveImage:originalHeadImage ofUsers:aUser withName:ORGINAL_HEAD_IMAGE_NAME andType:IMAGE_TYPE];
        NSString *mediumHeadImagePath = [Users saveImage:mediumHeadImage ofUsers:aUser withName:MEDIUM_HEAD_IMAGE_NAME andType:IMAGE_TYPE];
        NSString *thumbnailsHeadImagePath = [Users saveImage:thumbnailsHeadImage ofUsers:aUser withName:THUMBNAILS_HEAD_IMAGE_NAME andType:IMAGE_TYPE];
        //讲图像的文件路径存储到数据库里
        aUser.originalHeadImagePath = originalHeadImagePath;
        aUser.mediumHeadImagePath = mediumHeadImagePath;
        aUser.thumbnailsHeadImagePath = thumbnailsHeadImagePath;
    } else {
        NSLog(@"image directory error in VoteSetUserInfoViewController");
    }
    [context save:NULL];
}

- (void)uploadHeadImage:(UIImage *)image ofUser:(Users *)aUser withContext:(NSManagedObjectContext *)context
{
    __weak typeof(self) weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    activityIndicator.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y - NAVIGATION_BAR_HEIGHT);
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [weakSelf.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *originalHeadImagePath = aUser.originalHeadImagePath;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{SERVER_USERNAME: username};
    UIImage *originalHeadImage = [UIImage imageWithContentsOfFile:originalHeadImagePath];
    [manager POST:@"http://115.28.228.41/vote/update_head_imag.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(originalHeadImage) name:@"userfile" fileName:originalHeadImagePath mimeType:@"image/png"];
        //[formData appendPartWithFileURL:[NSURL URLWithString:originalHeadImagePath] name:@"userfile" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation: %@", operation);
        NSLog(@"Success: %@", responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        [weakSelf saveHeadImage:image ofUser:aUser withContext:context];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
        });
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"头像更新成功"
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation: %@", operation);
        NSLog(@"operation: %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        UIAlertView *alert = nil;
        alert = [[UIAlertView alloc] initWithTitle:@"头像更新失败"
                                           message:@"无网络或者服务器出错"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
    }];
}

- (void)changeScreennameAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak typeof(self) weakSelf = self;
    VoteChangeScreenNameViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"ChangeScreenNameViewController"];
    viewController.theNewScreenNameCallBack = ^(NSString *newScreenName) {
        if (context) {
            [context performBlock:^{
                weakSelf.aUser.screenname = newScreenName;
                [context save:NULL];
            }];
        }

    };
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)changeGenderAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak typeof(self) weakSelf = self;
    VoteChangeGenderViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"ChangeGenderViewController"];
    viewController.genderCallBack = ^(NSString *gender){
        if (context) {
            [context performBlock:^{
                weakSelf.aUser.gender = gender;
                [context save:NULL];
            }];
            
        }
    };
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)changeSignatureAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __weak NSManagedObjectContext *context = self.managedObjectContext;
    __weak typeof(self) weakSelf = self;
    VoteChangeSignatureViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"ChangeSignatureViewController"];
    viewController.signatureCallBack = ^(NSString *signature){
        if (context) {
            [context performBlock:^{
                weakSelf.aUser.signature = signature;
                [context save:NULL];
            }];
        }
    };
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
