//
//  MRTPicture.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTPicture.h"
#import "MJExtension.h"

@implementation MRTPicture
//利用MJExtension快捷编码解码，默认编码解码全部属性，如需针对部分可调用
//[Person setupIgnoredCodingPropertyNames:^NSArray *{return @[@"属性名"];}];
//MJCodingImplementation

#pragma mark encode
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_thumbnail_pic forKey:@"thumbnail_pic"];
    
}
#pragma mark decode
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _thumbnail_pic = [aDecoder decodeObjectForKey:@"thumbnail_pic"];
    }
    
    return self;
}

@end
