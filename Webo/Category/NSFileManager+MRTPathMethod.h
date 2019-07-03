//
//  NSFileManager+MRTPathMethod.h
//  Webo
//
//  Created by mrtanis on 2017/7/10.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (MRTPathMethod)

/**
 *   判断指定路径下的文件，是否超出规定时间的方法
 *
 *  @param path 文件路径
 *  @param time NSTimeInterval 秒
 *
 *  @return 是否超时
 */
+(BOOL)isTimeOutWithPath:(NSString *)path timeOut:(NSTimeInterval)time;


@end
