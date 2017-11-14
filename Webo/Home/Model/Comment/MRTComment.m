//
//  MRTComment.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTComment.h"
#import "NSDate+MJ.h"
#import "NSMutableAttributedString+MRTConvert.h"

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

- (void)setText:(NSString *)text
{
    _text = text;
    
    NSString *copyText = text;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:copyText];
    [str addAttribute:NSFontAttributeName value:MRTTextFont range:NSMakeRange(0, copyText.length)];
    
    ////////////////////////////////////////////////////////
    //匹配用户昵称
    //昵称正则表达式
    NSString *pattern = @"@[\\u4e00-\\u9fa5\\w\\-]+";
    NSError *error = nil;
    NSRegularExpression *regExpre = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regExpre) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSArray *resultArray = [regExpre matchesInString:copyText options:0 range:NSMakeRange(0, copyText.length)];
    
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
    
    resultArray = [regExpre matchesInString:copyText options:0 range:NSMakeRange(0, copyText.length)];
    
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
    
    resultArray = [regExpre matchesInString:copyText options:0 range:NSMakeRange(0, copyText.length)];
    
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        //将短链接提取备用
        _urlStr = [copyText substringWithRange:range];
        
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
        attr[NSLinkAttributeName] = [NSURL URLWithString:_urlStr];
        [str addAttributes:attr range:range];
    }
   
    
    _attrText = str;
}

//读取attrText时根据text来匹配正则表达式，例如显示表情，昵称变蓝等
- (NSMutableAttributedString *)attrText
{
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:_attrText];
    [str addAttribute:NSFontAttributeName value:MRTCommentTextFont range:NSMakeRange(0, _attrText.length)];
    [str convertToAttributedEmoString];
    
    
    return str;
}

#pragma mark encode
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_created_at forKey:@"created_at"];
    [aCoder encodeObject:_idstr forKey:@"idstr"];
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeObject:_attrText forKey:@"attrText"];
    [aCoder encodeObject:_source forKey:@"source"];
    [aCoder encodeObject:_urlStr forKey:@"urlStr"];
    [aCoder encodeObject:_user forKey:@"user"];
    [aCoder encodeObject:_status forKey:@"status"];
    [aCoder encodeObject:_reply_comment forKey:@"reply_comment"];
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
        _urlStr = [aDecoder decodeObjectForKey:@"urlStr"];
        _user = [aDecoder decodeObjectForKey:@"user"];
        _status = [aDecoder decodeObjectForKey:@"status"];
        _reply_comment = [aDecoder decodeObjectForKey:@"reply_comment"];
    }
    
    return self;
}

@end
