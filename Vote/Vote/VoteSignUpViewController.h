//
//  VoteSignUpViewController.h
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define USRNAME_TAG           101
#define SCREEN_NAME_TAG       102
#define PSW_TAG               103
#define CFMPSW_TAG            104
#define EMAIL_TAG             105

#define USRNAME_PROMPT_TAG    201
#define NICKNAME_PROMPT_TAG   202
#define PSW_PROMPT_TAG        203
#define CFMPSW_PROMPT_TAG     204
#define EMAIL_PROMPT_TAG      205

#define INPUT_RIGHT           @"right"
#define INPUT_WRONG           @"wrong"

#define NAME_NOT_USED         0
#define NAME_BEEN_USED        1
#define NAME_CHECK_ERROR      -1

#define REGISTER_SUCCESS      1
#define REGISTER_ERROR        2

@interface VoteSignUpViewController : UIViewController

@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *viewTitle;

@end
