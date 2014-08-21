//
//  VoteLookUpParticipantsFlowLayout.m
//  Vote
//
//  Created by 丁 一 on 14-8-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteLookUpParticipantsFlowLayout.h"

@implementation VoteLookUpParticipantsFlowLayout

- (id)init
{
    if (self = [super init])
    {
        self.itemSize = CGSizeMake(60, 72);
        self.minimumInteritemSpacing = 2;
        self.minimumLineSpacing = 2;
        //self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 22);
    }
    return self;
}


@end
