//
//  MRTMessageStatusFrame.h
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTStatus.h"
#import "MRTComment.h"

@interface MRTMessageStatusFrame : NSObject<NSCoding>
//微博数据
@property (nonatomic, strong) MRTStatus *status;
@property (nonatomic, strong) MRTComment *comment;

//原创微博frame
@property (nonatomic) CGRect originalViewFrame;

//原创微博子控件frame
//头像frame
@property (nonatomic) CGRect originalIconFrame;
//昵称frame
@property (nonatomic) CGRect originalNameFrame;
//vip frame
@property (nonatomic) CGRect originalVipFrame;

//正文frame
@property (nonatomic) CGRect originalTextFrame;
//图片frame
@property (nonatomic) CGRect originalPictureFrame;
//只有单个配图时图片的size
@property (nonatomic) CGSize originalOnePicSize;


//转发微博frame
@property (nonatomic) CGRect retweetViewFrame;

//转发微博子控件frame

//昵称frame
@property (nonatomic) CGRect retweetNameFrame;

//正文frame
@property (nonatomic) CGRect retweetTextFrame;
//图片frame
@property (nonatomic) CGRect retweetPictureFrame;
//灰色背景
@property (nonatomic) CGRect retweetBackgroundFrame;


//工具条frame
@property (nonatomic) CGRect toolBarFrame;


//cell的高度
@property (nonatomic) CGFloat cellHeight;
//不含工具栏的cell高度
@property (nonatomic) CGFloat noBarCellHeight;



@end
