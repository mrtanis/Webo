//
//  MRTRepostFrame.h
//  Webo
//
//  Created by mrtanis on 2017/8/13.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTStatus.h"

@interface MRTRepostFrame : NSObject
//转发内容
@property (nonatomic, strong) MRTStatus *repost;

//原始评论frame
@property (nonatomic) CGRect repostViewFrame;

//原始评论子控件frame
//头像frame
@property (nonatomic) CGRect repostIconFrame;
//昵称frame
@property (nonatomic) CGRect repostNameFrame;
//vip frame
@property (nonatomic) CGRect repostVipFrame;
//时间frame
@property (nonatomic) CGRect repostTimeFrame;
//评论正文frame
@property (nonatomic) CGRect repostTextFrame;

//cell的高度
@property (nonatomic) CGFloat cellHeight;

@end
