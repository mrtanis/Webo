//
//  MRTUser.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTUser.h"
#import "MJExtension.h"

@implementation MRTUser

//利用MJExtension快捷编码解码，默认编码解码全部属性，如需针对部分可调用
//[Person setupIgnoredCodingPropertyNames:^NSArray *{return @[@"属性名"];}];
//MJCodingImplementation

- (void)setMbtype:(int)mbtype
{
    _mbtype = mbtype;
    
    _vip = (mbtype > 2);
}

#pragma mark encode
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_profile_image_url forKey:@"profile_image_url"];
    [aCoder encodeObject:_avatar_large forKey:@"avatar_large"];
    [aCoder encodeInt:_mbtype forKey:@"mbtype"];
    [aCoder encodeInt:_mbrank forKey:@"mbrank"];
    [aCoder encodeBool:_vip forKey:@"vip"];
    
}
#pragma mark decode
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _profile_image_url = [aDecoder decodeObjectForKey:@"profile_image_url"];
        _avatar_large = [aDecoder decodeObjectForKey:@"avatar_large"];
        _mbtype = [aDecoder decodeIntForKey:@"mbtype"];
        _mbrank = [aDecoder decodeIntForKey:@"mbrank"];
        _vip = [aDecoder decodeBoolForKey:@"vip"];
       
    }
    
    return self;
}

@end
