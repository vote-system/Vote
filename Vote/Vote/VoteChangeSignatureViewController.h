//
//  VoteChangeSignatureViewController.h
//  Vote
//
//  Created by 丁 一 on 14-3-25.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Signature)(NSString *signature);

@interface VoteChangeSignatureViewController : UIViewController

@property (copy, nonatomic) Signature signatureCallBack;

@end


#define CSVC_ALERTVIEW_UPDATE_SUCCESS_TAG     1001