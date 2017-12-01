//
//  MRTWriteCommentViewController.h
//  Webo
//
//  Created by mrtanis on 2017/6/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTStatusCell.h"
#import "MRTCommentFrame.h"

@interface MRTWriteCommentViewController : UIViewController

@property (nonatomic, strong) MRTStatusFrame *statusFrame;
@property (nonatomic, strong) MRTCommentFrame *commentFrame;
@property (nonatomic) BOOL replyToComment;

@end
