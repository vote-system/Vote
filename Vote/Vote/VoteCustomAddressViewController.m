//
//  VoteCustomAddressViewController.m
//  Vote
//
//  Created by 丁 一 on 14-8-18.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteCustomAddressViewController.h"
#import "YIInnerShadowView.h"
#import "NSString+NSStringHelper.h"
#import "VoteAddOptionsTableViewController.h"

@interface VoteCustomAddressViewController () <UITextViewDelegate>
{
    YIInnerShadowView *innerShadowView;
}
@property (strong, nonatomic) UITextView *customAddress;
@property (strong, nonatomic) UILabel *wordsPrompt;

@end

@implementation VoteCustomAddressViewController

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
    NSArray *navArr = self.navigationController.viewControllers;
    for (UIViewController *nav in navArr)
    {
        if ([nav isKindOfClass:[VoteAddOptionsTableViewController class]])
        {
            self.addCustomAddrDelegate = (id)nav;
            break;
        }
    }
    
    [self.view setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    [self.view addSubview:self.customAddress];
    [self.view addSubview:self.wordsPrompt];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addCustomAddress:(id)sender {
    if ([NSString checkWhitespaceAndNewlineCharacter:self.customAddress.text] == NO) {
        [self.addCustomAddrDelegate addCustomAddress:self.customAddress.text];
        NSArray *navArr = self.navigationController.viewControllers;
        for (UIViewController *nav in navArr)
        {
            if ([nav isKindOfClass:[VoteAddOptionsTableViewController class]])
            {
                [self.navigationController popToViewController:nav animated:YES];
            }
        }
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"输入不可为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
    }
}


#pragma mark - UITextView delegate

- (UITextView *)customAddress
{
    if (_customAddress == nil) {
        
        _customAddress = [[UITextView alloc] initWithFrame:CGRectMake(20.0, NAVIGATION_BAR_HEIGHT + 20, 280.0, 110.0)];
        _customAddress.font = [UIFont systemFontOfSize:15.0];
        _customAddress.autocorrectionType = UITextAutocorrectionTypeNo;
        _customAddress.textAlignment = NSTextAlignmentLeft;
        _customAddress.keyboardType = UIKeyboardTypeDefault;
        _customAddress.returnKeyType = UIReturnKeyDone;
        _customAddress.scrollEnabled = NO;
        _customAddress.delegate = self;
        //_customAddress.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        //_customAddress.layer.borderWidth = 0.5;
        _customAddress.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _customAddress.layer.masksToBounds = YES;
        
        innerShadowView = [[YIInnerShadowView alloc] initWithFrame:_customAddress.bounds];
        innerShadowView.shadowRadius = 2;
        innerShadowView.cornerRadius = 0;
        innerShadowView.shadowMask = YIInnerShadowMaskAll;
        innerShadowView.layer.borderColor = [UIColorFromRGB(0xF7F7F7) CGColor];
        innerShadowView.layer.borderWidth = 1.0;
        [_customAddress addSubview:innerShadowView];
        
        
    }
    
    return _customAddress;
}

- (UILabel *)wordsPrompt
{
    if (_wordsPrompt == nil) {
        CGRect rect = CGRectMake(155, 200, 150, 20);
        _wordsPrompt = [[UILabel alloc] initWithFrame:rect];
        _wordsPrompt.text = @"还可输入70个字";
        _wordsPrompt.font = [UIFont systemFontOfSize:15.0];
        _wordsPrompt.textColor = UIColorFromRGB(0xC7C7CD);
        _wordsPrompt.textAlignment = NSTextAlignmentRight;
    }
    
    return _wordsPrompt;
}


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
    else if([[textView text] length] > 69)
    {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    int len = (int)textView.text.length;
    self.wordsPrompt.text = [NSString stringWithFormat:@"还可输入%i个字",70-len];
    if (70-len < 0) {
        self.wordsPrompt.textColor = [UIColor redColor];
    } else {
        self.wordsPrompt.textColor = UIColorFromRGB(0xC7C7CD);
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
