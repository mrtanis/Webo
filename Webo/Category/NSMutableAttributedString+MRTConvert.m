//
//  NSMutableAttributedString+MRTConvert.m
//  Webo
//
//  Created by mrtanis on 2017/9/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "NSMutableAttributedString+MRTConvert.h"
#import "MRTTextAttachment.h"

@implementation NSMutableAttributedString (MRTConvert)

- (void)convertToAttributedEmoString
{
    //加载表情bundle
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Emoticons.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    //加载表情plist
    NSString *plistPath = [bundle pathForResource:@"content" ofType:@"plist" inDirectory:@"com.sina.normal"];
    //获取plist中的数据
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *emoArray = dic[@"emoticons"];
    
    
    NSString *pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSError *error = nil;
    NSRegularExpression *regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSArray *resultArray = [regExpre matchesInString:self.string options:0 range:NSMakeRange(0, self.string.length)];
    //用来存放字典，字典中储存图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    
    //根据匹配范围来用图片进行相应的替换
    for (NSTextCheckingResult *match in resultArray) {
        //获取数组中的range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [self.string substringWithRange:range];
        
        for (int i = 0; i < emoArray.count; i++) {
            if ([emoArray[i][@"chs"] isEqualToString:subStr]) {
                //emoArray[i][@"png"]就是所匹配的表情
                //新建文字附件来保存表情图片
                MRTTextAttachment *textAttachment = [[MRTTextAttachment alloc] init];

                //给附件添加图片
                textAttachment.image = [UIImage imageNamed:emoArray[i][@"png"]];
                textAttachment.emoChs = emoArray[i][@"chs"];
                
                //把附件转换成属性字符串，用于替换原字符中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                
                //把字典存入数组中
                [imageArray addObject:imageDic];
            }
        }
    }
    
    //从后往前替换
    for (int i = (int)imageArray.count - 1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [self replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
}

@end
