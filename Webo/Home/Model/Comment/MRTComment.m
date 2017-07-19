//
//  MRTComment.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTComment.h"
#import "NSDate+MJ.h"

@implementation MRTComment

//读取微博创建时间时进行计算，返回对应字符串

- (NSString *)created_at
{
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    dateFmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];//很重要
    NSDate *created_at = [dateFmt dateFromString:_created_at];
    
    if ([created_at isThisYear]) {//今年
        dateFmt.dateFormat = @"MM-dd HH:mm";
        return [dateFmt stringFromDate:created_at];
    } else {//今年以前
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [dateFmt stringFromDate:created_at];
    }
}

@end
