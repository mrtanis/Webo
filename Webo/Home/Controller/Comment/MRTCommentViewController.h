//
//  MRTCommentViewController.h
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTStatusCell.h"
#import "MRTMessageStatusFrame.h"
#import "MRTVideoPlayer.h"

@interface MRTCommentViewController : UIViewController

@property (nonatomic, copy) NSString *leftTitle;

@property (nonatomic, strong) MRTStatusFrame *statusFrame;
@property (nonatomic) BOOL onlyOriginal;
@property (nonatomic) BOOL scorllToComment;

@property (nonatomic, strong) MRTVideoPlayer *videoView;

//是否是从@我的微博进入的
@property (nonatomic) BOOL isFromAt_status;
@end
