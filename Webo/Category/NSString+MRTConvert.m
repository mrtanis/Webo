//
//  NSString+MRTConvert.m
//  Webo
//
//  Created by mrtanis on 2017/8/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "NSString+MRTConvert.h"

#ifdef DEBUG

#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

#else

#define NSLog(FORMAT, ...) nil

#endif
@implementation NSString (MRTConvert)
+ (NSString *)convertTime:(float)second
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    
    NSString *timeStr = [formatter stringFromDate:date];
    
    return timeStr;
}

+ (NSString *)videoUrlFromString:(NSString *)htmlStr
{
    
    //用于存储链接，通过key判断是微博视频还是秒拍
    //NSMutableDictionary *urlDic = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *videoStr = nil;
    //微博视频range
    NSRange range1begin = [htmlStr rangeOfString:@"flashvars=\"list=" options:NSLiteralSearch];
    NSLog(@"range1begin(%ld,%ld)", range1begin.location, range1begin.length);
    
    
    if (range1begin.location != NSNotFound) {
        NSLog(@"%@", htmlStr);
        NSRange range1end = [htmlStr rangeOfString:@"unistore%2Cvideo" options:NSLiteralSearch];
        NSLog(@"range1end(%ld,%ld)", range1end.location, range1end.length);
        if (range1end.location != NSNotFound) {
            NSRange range1 = NSMakeRange(range1begin.location + range1begin.length, range1end.location + range1end.length - range1begin.location - range1begin.length);
            videoStr = [htmlStr substringWithRange:range1];
        }
        
        NSLog(@"微博视频videoStr:%@", videoStr);
        videoStr = [videoStr stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
        videoStr = [videoStr stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
        videoStr = [videoStr stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
        videoStr = [videoStr stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
        videoStr = [videoStr stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
        videoStr = [videoStr stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
       
        NSLog(@"微博视频videoStr:%@", videoStr);
        //urlDic[@"weibo"] = videoStr;
        return videoStr;
    }
    
    //秒拍视频range
    NSRange range2begin = [htmlStr rangeOfString:@"videoSrc\":\"" options:NSLiteralSearch];
    NSLog(@"range2begin(%ld,%ld)", range2begin.location, range2begin.length);
    if (range2begin.location != NSNotFound) {
        NSRange range2end = [htmlStr rangeOfString:@"poster" options:NSLiteralSearch];
        NSLog(@"range2end(%ld,%ld)", range2end.location, range2end.length);
        NSLog(@"htmlStr.length:%ld", htmlStr.length);
        NSString *substr;
        if (range2end.location != NSNotFound) {
            substr = [htmlStr substringWithRange:NSMakeRange(range2begin.location + range2begin.length, range2end.location - range2begin.location - range2begin.length)];
        }
        NSRange range2realEnd = [substr rangeOfString:@"__\"" options:NSLiteralSearch];
        NSLog(@"range2realEnd(%ld,%ld)", range2realEnd.location, range2realEnd.length);
        if (range2realEnd.location != NSNotFound) {
            videoStr = [substr substringWithRange:NSMakeRange(0, range2realEnd.location + range2realEnd.length)];
        }
        //进行utf8转换，避免含有中文、空格、"/"等字符，转换为url会返回nil
        videoStr = [videoStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"秒拍视频videoStr:%@", videoStr);
        //urlDic[@"miaopai"] = videoStr;
        return videoStr;
    }
    return nil;
}

+ (NSString *)videoPicUrlFromString:(NSString *)htmlStr
{
    NSLog(@"视频封面源代码%@", htmlStr);
    NSString *picStr = nil;
    //微博视频封面range
    NSRange range1begin = [htmlStr rangeOfString:@"img src = \"" options:NSLiteralSearch];
    //NSLog(@"range1begin(%ld,%ld)", range1begin.location, range1begin.length);
    
    
    if (range1begin.location != NSNotFound) {
        
        NSRange range1end = [htmlStr rangeOfString:@"jpg\" style" options:NSLiteralSearch];
        //NSLog(@"range1end(%ld,%ld)", range1end.location, range1end.length);
        NSRange range1 = NSMakeRange(range1begin.location + range1begin.length, range1end.location + range1end.length - range1begin.location - range1begin.length - 7);
        picStr = [htmlStr substringWithRange:range1];
        NSLog(@"微博视频封面picStr:%@", picStr);
        NSLog(@"微博视频封面url:%@", [NSURL URLWithString:picStr]);
        
    }
    
    //秒拍视频封面range
    NSRange range2begin = [htmlStr rangeOfString:@"poster\":\"" options:NSLiteralSearch];
    //NSLog(@"range2begin(%ld,%ld)", range2begin.location, range2begin.length);
    if (range2begin.location != NSNotFound) {
        NSRange range2end = [htmlStr rangeOfString:@"下载分块儿滚动固定" options:NSLiteralSearch];
        //NSLog(@"range2end(%ld,%ld)", range2end.location, range2end.length);
        //NSLog(@"htmlStr.length:%ld", htmlStr.length);
        
        NSString *substr = [htmlStr substringWithRange:NSMakeRange(range2begin.location + range2begin.length, range2end.location - range2begin.location - range2begin.length)];
        NSRange range2realEnd = [substr rangeOfString:@"jpg\"" options:NSLiteralSearch];
        //NSLog(@"range2realEnd(%ld,%ld)", range2realEnd.location, range2realEnd.length);
        picStr = [substr substringWithRange:NSMakeRange(0, range2realEnd.location + range2realEnd.length - 1)];
        
        NSLog(@"秒拍视频封面picStr:%@", picStr);
        NSLog(@"秒拍视频封面url:%@", [NSURL URLWithString:picStr]);
        
    }
    //进行utf8转换，避免含有中文、空格、"/"等字符，转换为url会返回nil
    picStr = [picStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return picStr;
}
@end
