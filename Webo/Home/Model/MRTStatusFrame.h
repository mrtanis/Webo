//
//  MRTStatusFrame.h
//  Webo
//
//  Created by mrtanis on 2017/5/24.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTStatus.h"


@interface MRTStatusFrame : NSObject<NSCoding>
//微博数据
@property (nonatomic, strong) MRTStatus *status;

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
//视频封面
@property (nonatomic) CGRect originalVideoPosterFrame;


//转发微博frame
@property (nonatomic) CGRect retweetViewFrame;

//转发微博子控件frame
//头像frame
@property (nonatomic) CGRect retweetIconFrame;
//昵称frame
@property (nonatomic) CGRect retweetNameFrame;

//正文frame
@property (nonatomic) CGRect retweetTextFrame;
//图片frame
@property (nonatomic) CGRect retweetPictureFrame;
//只有单个配图时图片的size
@property (nonatomic) CGSize retweetOnePicSize;
//视频封面
@property (nonatomic) CGRect retweetVideoPosterFrame;


//工具条frame
@property (nonatomic) CGRect toolBarFrame;


//cell的高度
@property (nonatomic) CGFloat cellHeight;
//不含工具栏的cell高度
@property (nonatomic) CGFloat noBarCellHeight;


@property (nonatomic) BOOL isAtStatus;

@end
