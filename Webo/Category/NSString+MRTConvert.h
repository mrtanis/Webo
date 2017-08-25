//
//  NSString+MRTConvert.h
//  Webo
//
//  Created by mrtanis on 2017/8/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MRTConvert)
//转换视频显示时间
+ (NSString *)convertTime:(float)second;

//从网页源代码中筛选出视频链接
+ (NSMutableDictionary *)videoUrlFromString:(NSString *)htmlStr;
@end
