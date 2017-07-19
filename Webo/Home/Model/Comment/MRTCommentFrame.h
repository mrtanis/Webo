//
//  MRTCommentFrame.h
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTComment.h"

@interface MRTCommentFrame : NSObject
//微博评论（转发也可借用）
@property (nonatomic, strong) MRTComment *comment;


//原始评论frame
@property (nonatomic) CGRect commentViewFrame;

//原始评论子控件frame
//头像frame
@property (nonatomic) CGRect commentIconFrame;
//昵称frame
@property (nonatomic) CGRect commentNameFrame;
//vip frame
@property (nonatomic) CGRect commentVipFrame;
//时间frame
@property (nonatomic) CGRect commentTimeFrame;
//评论正文frame
@property (nonatomic) CGRect commentTextFrame;

//cell的高度
@property (nonatomic) CGFloat cellHeight;

@end
