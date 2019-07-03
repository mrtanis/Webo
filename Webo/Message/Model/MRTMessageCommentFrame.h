//
//  MRTMessageCommentFrame.h
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTComment.h"

@interface MRTMessageCommentFrame : NSObject <NSCoding>

@property (nonatomic, strong) MRTComment *comment;

//主评论frame
@property (nonatomic) CGRect originalViewFrame;

//主评论子控件frame
//头像frame
@property (nonatomic) CGRect originalIconFrame;
//昵称frame
@property (nonatomic) CGRect originalNameFrame;
//vip frame
@property (nonatomic) CGRect originalVipFrame;

//正文frame
@property (nonatomic) CGRect originalTextFrame;

//主评论的status概览frame
@property (nonatomic) CGRect originalStatusPictureFrame;
@property (nonatomic) CGRect originalStatusNameFrame;
@property (nonatomic) CGRect originalStatusTextFrame;

//灰色背景
@property (nonatomic) CGRect originalStatusBackgroundFrame;


//被回复评论frame
@property (nonatomic) CGRect retweetViewFrame;

//被回复评论子控件frame
//正文frame
@property (nonatomic) CGRect retweetTextFrame;
//被恢复评论的status概览frame
@property (nonatomic) CGRect retweetStatusPictureFrame;
@property (nonatomic) CGRect retweetStatusNameFrame;
@property (nonatomic) CGRect retweetStatusTextFrame;

//白色背景
@property (nonatomic) CGRect retweetStatusBackgroundFrame;

//cell的高度
@property (nonatomic) CGFloat cellHeight;

@end
