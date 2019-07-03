//
//  MRTStatusToolBar.h
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTStatusFrame.h"
#import "MRTMessageStatusFrame.h"
@class MRTStatusToolBar;


@interface MRTStatusToolBar : UIImageView



@property (nonatomic, strong) MRTStatusFrame *statusFrame;
@property (nonatomic, strong) MRTMessageStatusFrame *messageStatusFrame;

@property (nonatomic, weak) UIButton *retweetBtn;
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *likeBtn;

@end
