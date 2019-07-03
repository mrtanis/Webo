//
//  MRTVideoURL.h
//  Webo
//
//  Created by mrtanis on 2017/10/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTVideoURL : NSObject<NSCoding>

//用于保存从网页解析的微博视频链接，初步设定过期时间为半个小时
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSDate *expires_date;

@end
