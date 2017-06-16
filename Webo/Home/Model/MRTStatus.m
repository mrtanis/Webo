//
//  MRTStatus.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatus.h"
#import "MJExtension.h"
#import "NSDate+MJ.h"

@implementation MRTStatus

//自动把数组中的字典转换成对应的模型
+(NSDictionary*)objectClassInArray
{
    return @{@"pic_urls":[MRTPicture class]};
}

//读取微博创建时间时进行计算，返回对应字符串

- (NSString *)created_at
{
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    dateFmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];//很重要
    NSDate *created_at = [dateFmt dateFromString:_created_at];
    
    if ([created_at isThisYear]) {//今年
        if ([created_at isToday]) {//今天
            //计算与当前时间的时间差
            NSDateComponents *dateCmp = [created_at deltaWithNow];
            if (dateCmp.hour >= 1) {//大于一小时
                return [NSString stringWithFormat:@"%ld小时之前", dateCmp.hour];
            } else {//一小时内
                if (dateCmp.minute >= 1) {//大于一分钟
                    return [NSString stringWithFormat:@"%ld分钟之前", dateCmp.minute];
                } else {//一分钟内
                    return [NSString stringWithFormat:@"1分钟"];
                }
            }
        } else if ([created_at isYesterday]) {//昨天
            dateFmt.dateFormat = @"昨天 HH:MM";
            return [dateFmt stringFromDate:created_at];
        } else {//昨天之前
            dateFmt.dateFormat = @"MM-dd HH:mm";
            return [dateFmt stringFromDate:created_at];
        }
    } else {//今年以前
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [dateFmt stringFromDate:created_at];
    }
}

- (void)setSource:(NSString *)source
{
    //来源示例：
    // <a href="http://app.weibo.com/t/feed/6vtZb0" rel="nofollow">微博 weibo.com</a>
    // <a href="http://app.weibo.com/t/feed/3napkb" rel="nofollow">政务直通车</a>
    //通过以上可知来源字符串在><符号之间
    NSString *final = nil;
    NSRange begin = [source rangeOfString:@">"];
    if (begin.location != NSNotFound) {
        NSString *str1 = [source substringFromIndex:begin.location + begin.length];
        
        NSRange end = [str1 rangeOfString:@"<"];
        NSString *str2 = [str1 substringToIndex:end.location];
        
        final = [NSString stringWithFormat:@"来自%@", str2];
    }
    
    _source = final;
}

@end
