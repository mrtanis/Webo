//
//  MRTAccount.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccount.h"
#import "MJExtension.h"

#define MRTAccess_tokenKey @"access_token"
#define MRTUidKey @"uid"
#define MRTExpires_inKey @"expires_in"
#define MRTExpires_dateKey @"expires_date"
#define MRTName @"name"
@implementation MRTAccount

//利用MJExtension快捷编码解码，默认编码解码全部属性，如需针对部分可调用
//[Person setupIgnoredCodingPropertyNames:^NSArray *{return @[@"属性名"];}];
MJCodingImplementation

+ (instancetype)accountWithDict:(NSDictionary *)dict
{
    MRTAccount *account = [[MRTAccount alloc] init];
    
    //用字典里的key匹配properties，并将对应的value赋值给属性，所以属性名应该和获取的字典里面的key一样
    [account setValuesForKeysWithDictionary:dict];
    
    return account;
}

- (void)setExpires_in:(NSString *)expires_in
{
    _expires_in = expires_in;
    
    //计算过期的时间 = 当前时间 + 有效期
    _expires_date = [NSDate dateWithTimeIntervalSinceNow:[expires_in longLongValue]];
}

/*
//编码时调用
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_access_token forKey:MRTAccess_tokenKey];
    [aCoder encodeObject:_expires_in forKey:MRTExpires_inKey];
    [aCoder encodeObject:_uid forKey:MRTUidKey];
    [aCoder encodeObject:_expires_date forKey:MRTExpires_dateKey];
    [aCoder encodeObject:_name forKey:MRTName];
}

//解码时调用
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _access_token = [aDecoder decodeObjectForKey:MRTAccess_tokenKey];
        _uid = [aDecoder decodeObjectForKey:MRTUidKey];
        _expires_in = [aDecoder decodeObjectForKey:MRTExpires_inKey];
        _expires_date = [aDecoder decodeObjectForKey:MRTExpires_dateKey];
        _name = [aDecoder decodeObjectForKey:MRTName];
    }
    
    return self;
}
*/
@end
