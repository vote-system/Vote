//
//  VoteAddParticipantsTableViewController.h
//  Vote
//
//  Created by 丁 一 on 14-6-22.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol AddParticipantsDelegate;

@interface VoteAddParticipantsTableViewController : UITableViewController

@property (weak, nonatomic) id<AddParticipantsDelegate> addParticipantsDelegate;
@property (strong, nonatomic) NSMutableArray *paticipants;

@end

#define ADD_PARTICIPANTS_SEPARATOR_TAG          1005

@protocol AddParticipantsDelegate <NSObject>

@optional
- (void)addParticipants:(NSMutableArray *)participants;

@end