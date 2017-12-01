//
//  MRTStatus.h
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"
#import "MRTPicture.h"
#import "MRTURL_object.h"
#import "MRTUser.h"
#import "MRTVideoURL.h"

@interface MRTStatus : NSObject <MJKeyValue, NSCoding>

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *idstr;
@property (nonatomic, copy) NSString *text;
//建立一个属性字符串
@property (nonatomic, strong) NSMutableAttributedString *attrText;

@property (nonatomic, copy) NSString *source;
@property (nonatomic, strong) MRTUser *user;
@property (nonatomic, strong) MRTStatus *retweeted_status;
@property (nonatomic, assign) int reposts_count;
@property (nonatomic, assign) int comments_count;
@property (nonatomic, assign) int attitudes_count;
@property (nonatomic, strong) NSArray *pic_urls;

//@我的微博中返回的视频、链接数据
@property (nonatomic, strong) NSArray *url_objects;
//@我的微博中返回原创或转发的图片数据
@property (nonatomic, strong) NSArray *pic_ids;
@property (nonatomic, copy) NSString *thumbnail_pic;


//从正文中提取的短连接
@property (nonatomic, copy) NSString *urlStr;
//从短链接源代码中解析出的视频封面
@property (nonatomic, copy) NSString *videoPosterStr;
//提前预获取的视频链接
@property (nonatomic, copy) NSString *videoStr;

@property (nonatomic, strong) MRTVideoURL *video;
@end
