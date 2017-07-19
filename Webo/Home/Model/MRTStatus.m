//
//  MRTStatus.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatus.h"

#import "NSDate+MJ.h"


@implementation MRTStatus

//利用MJExtension快捷编码解码，默认编码解码全部属性，如需针对部分可调用

//MJCodingImplementation

//+ (NSArray *)mj_ignoredCodingPropertyNames
//{
//    return @[@"pic_urls"];
//}

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

//设置text的同时设置好attrText，例如显示表情，昵称变蓝等
- (NSMutableAttributedString *)attrText
{
    NSString *text = self.text;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttribute:NSFontAttributeName value:MRTTextFont range:NSMakeRange(0, text.length)];
    
    ////////////////////////////////////////////////////////
    //匹配用户昵称
    //昵称正则表达式
    NSString *pattern = @"@[\\u4e00-\\u9fa5\\w\\-]+";
    NSError *error = nil;
    NSRegularExpression *regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSArray *resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
        attr[NSLinkAttributeName] = [NSURL URLWithString:@"at://"];
        [str addAttributes:attr range:range];
    }
    
    ////////////////////////////////////////////////////////
    //匹配话题
    pattern = @"#([^\\#|.]+)#";
    regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
        attr[NSLinkAttributeName] = [NSURL URLWithString:@"trend://"];
        [str addAttributes:attr range:range];
    }
    
    ////////////////////////////////////////////////////////
    //匹配短连接
    pattern = @"http(s)?://([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%=]*)?";
    regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
        attr[NSLinkAttributeName] = [NSURL URLWithString:@"short://"];
        [str addAttributes:attr range:range];
    }
    
    //////////////////////////////////////////
    //最后替换表情，因为将字符替换成表情字符数会变化
    
    //加载表情bundle
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Emoticons.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    //加载表情plist
    NSString *plistPath = [bundle pathForResource:@"content" ofType:@"plist" inDirectory:@"com.sina.normal"];
    //获取plist中的数据
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *emoArray = dic[@"emoticons"];
    
    
    
    
    //表情正则表达式
    pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    regExpre = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    //通过正则表达式来匹配字符串
    resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    //用来存放字典，字典中储存图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    
    //根据匹配范围来用图片进行相应的替换
    for (NSTextCheckingResult *match in resultArray) {
        //获取数组中的range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];
        
        for (int i = 0; i < emoArray.count; i++) {
            if ([emoArray[i][@"chs"] isEqualToString:subStr]) {
                //emoArray[i][@"png"]就是所匹配的表情
                //新建文字附件来保存表情图片
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                CGRect rect = CGRectMake(0, -4, 20, 20);
                textAttachment.bounds = rect;
                
                
                //给附件添加图片,先转变大小
                //NSData *data = UIImagePNGRepresentation([UIImage imageNamed:emoArray[i][@"png"]]);
                //UIImage *image = [UIImage imageWithData:data scale:3.5];
                textAttachment.image = [UIImage imageNamed:emoArray[i][@"png"]];
                
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
        [str replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    
    return str;
}
/*
- (void)setText:(NSString *)text
{
    _text = text;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttribute:NSFontAttributeName value:MRTTextFont range:NSMakeRange(0, text.length)];
    
    ////////////////////////////////////////////////////////
    //匹配用户昵称
    //昵称正则表达式
    NSString *pattern = @"@[\\u4e00-\\u9fa5\\w\\-]+";
    NSError *error = nil;
    NSRegularExpression *regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSArray *resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
        attr[NSLinkAttributeName] = [NSURL URLWithString:@"at://"];
        [str addAttributes:attr range:range];
    }
    
    ////////////////////////////////////////////////////////
    //匹配话题
    pattern = @"#([^\\#|.]+)#";
    regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
        attr[NSLinkAttributeName] = [NSURL URLWithString:@"trend://"];
        [str addAttributes:attr range:range];
    }
    
    ////////////////////////////////////////////////////////
    //匹配短连接
    pattern = @"http(s)?://([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%=]*)?";
    regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
        attr[NSLinkAttributeName] = [NSURL URLWithString:@"short://"];
        [str addAttributes:attr range:range];
    }

    //////////////////////////////////////////
    //最后替换表情，因为将字符替换成表情字符数会变化
    
    //加载表情bundle
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Emoticons.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    //加载表情plist
    NSString *plistPath = [bundle pathForResource:@"content" ofType:@"plist" inDirectory:@"com.sina.normal"];
    //获取plist中的数据
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *emoArray = dic[@"emoticons"];
    
    
    
    
    //表情正则表达式
    pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    regExpre = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    //通过正则表达式来匹配字符串
    resultArray = [regExpre matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    //用来存放字典，字典中储存图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    
    //根据匹配范围来用图片进行相应的替换
    for (NSTextCheckingResult *match in resultArray) {
        //获取数组中的range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];
        
        for (int i = 0; i < emoArray.count; i++) {
            if ([emoArray[i][@"chs"] isEqualToString:subStr]) {
                //emoArray[i][@"png"]就是所匹配的表情
                //新建文字附件来保存表情图片
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                CGRect rect = CGRectMake(0, -4, 20, 20);
                textAttachment.bounds = rect;
                
                
                //给附件添加图片,先转变大小
                //NSData *data = UIImagePNGRepresentation([UIImage imageNamed:emoArray[i][@"png"]]);
                //UIImage *image = [UIImage imageWithData:data scale:3.5];
                textAttachment.image = [UIImage imageNamed:emoArray[i][@"png"]];
                
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
        [str replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    
    _attrText = str;
}*/

#pragma mark encode
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_created_at forKey:@"created_at"];
    [aCoder encodeObject:_idstr forKey:@"idstr"];
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeObject:_attrText forKey:@"attrText"];
    [aCoder encodeObject:_source forKey:@"source"];
    [aCoder encodeObject:_user forKey:@"user"];
    [aCoder encodeObject:_retweeted_status forKey:@"retweeted_status"];
    [aCoder encodeInt:_reposts_count forKey:@"reposts_count"];
    [aCoder encodeInt:_comments_count forKey:@"comments_count"];
    [aCoder encodeInt:_attitudes_count forKey:@"attitudes_count"];
    [aCoder encodeObject:_pic_urls forKey:@"pic_urls"];
}
#pragma mark decode
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _created_at = [aDecoder decodeObjectForKey:@"created_at"];
        _idstr = [aDecoder decodeObjectForKey:@"idstr"];
        _text = [aDecoder decodeObjectForKey:@"text"];
        _attrText = [aDecoder decodeObjectForKey:@"attrText"];
        _source = [aDecoder decodeObjectForKey:@"source"];
        _user = [aDecoder decodeObjectForKey:@"user"];
        _retweeted_status = [aDecoder decodeObjectForKey:@"retweeted_status"];
        _reposts_count = [aDecoder decodeIntForKey:@"reposts_count"];
        _comments_count = [aDecoder decodeIntForKey:@"comments_count"];
        _attitudes_count = [aDecoder decodeIntForKey:@"attitudes_count"];
        _pic_urls = [aDecoder decodeObjectForKey:@"pic_urls"];
    }
    
    return self;
}

@end

