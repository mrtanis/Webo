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

//因为description是已有关键字，所以要改名
+ (NSDictionary *)replacedKeyFromPropertyName{
    
    return @{@"introduction":@"description"};
    
}

- (void)setMbtype:(int)mbtype
{
    _mbtype = mbtype;
    
    _vip = (mbtype > 2);
}

#pragma mark encode
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_idstr forKey:@"idstr"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_introduction forKey:@"introduction"];
    [aCoder encodeObject:_profile_image_url forKey:@"profile_image_url"];
    [aCoder encodeObject:_avatar_large forKey:@"avatar_large"];
    [aCoder encodeObject:_avatar_hd forKey:@"avatar_hd"];
    [aCoder encodeInt:_followers_count forKey:@"followers_count"];
    [aCoder encodeInt:_statuses_count forKey:@"statuses_count"];
    [aCoder encodeInt:_friends_count forKey:@"friends_count"];
    [aCoder encodeInt:_mbtype forKey:@"mbtype"];
    [aCoder encodeInt:_mbrank forKey:@"mbrank"];
    [aCoder encodeBool:_vip forKey:@"vip"];
    
}
#pragma mark decode
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _idstr = [aDecoder decodeObjectForKey:@"idstr"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _introduction = [aDecoder decodeObjectForKey:@"introduction"];
        _profile_image_url = [aDecoder decodeObjectForKey:@"profile_image_url"];
        _avatar_large = [aDecoder decodeObjectForKey:@"avatar_large"];
        _avatar_hd = [aDecoder decodeObjectForKey:@"avatar_hd"];
        _followers_count = [aDecoder decodeIntForKey:@"followers_count"];
        _friends_count = [aDecoder decodeIntForKey:@"friends_count"];
        _statuses_count = [aDecoder decodeIntForKey:@"statuses_count"];
        _mbtype = [aDecoder decodeIntForKey:@"mbtype"];
        _mbrank = [aDecoder decodeIntForKey:@"mbrank"];
        _vip = [aDecoder decodeBoolForKey:@"vip"];
       
    }
    
    return self;
}

@end
