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

@interface MRTCommentViewController : UIViewController

@property (nonatomic, strong) MRTStatusFrame *statusFrame;
@property (nonatomic) BOOL onlyOriginal;
@property (nonatomic) BOOL scorllToComment;
@end
