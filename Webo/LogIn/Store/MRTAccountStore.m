//
//  MRTAccountStore.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccountStore.h"
#import "MRTAccount.h"
#import "MRTAccountParameter.h"
#import "MRTHttpTool.h"
#import "MJExtension.h"
#import "MRTRootVCPicker.h"

#define MRTClient_id @"1316088724"
#define MRTClient_secret @"1cc4b41b7fee63dddbd4739831434efa"
#define MRTAuthorizeBaseUrl @"https://api.weibo.com/oauth2/authorize"
#define MRTRedirect_uri @"http://www.baidu.com"
@implementation MRTAccountStore

//类方法一般用静态变量代替成员属性
static MRTAccount *_account;

+ (void)saveAccount:(MRTAccount *)account
{
    
    NSString *path = [self accountArchivePath];
    
    [NSKeyedArchiver archiveRootObject:account toFile:path];
}

//获得account固化路径
+ (NSString *)accountArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //从documentDirectories数组获取第一个，也是唯一文档目录路径
    NSString *documentDirectory = [documentDirectories firstObject];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"account.data"];

    return path;
}

+ (MRTAccount *)account
{
    if (!_account) {
        _account = [NSKeyedUnarchiver unarchiveObjectWithFile:[self accountArchivePath]];
        
        //判断账号是否过期，过期返回nil
        //现在日期在过期期限之前：NSOrderedAscending  未过期
        //现在日期在过期期限之后：NSOrderedDescending  过期
        //现在日期与过期期限相同：NSOrderedSame 相当于过期
        if ([[NSDate date] compare:_account.expires_date] != NSOrderedAscending) return nil;
    }
    
    return _account;
}

+ (void)accountWithCode:(NSString *)code success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    //创建参数模型
    MRTAccountParameter *parameter = [[MRTAccountParameter alloc] init];
    
    parameter.client_id = MRTClient_id;
    parameter.client_secret = MRTClient_secret;
    parameter.grant_type = @"authorization_code";
    parameter.code = code;
    parameter.redirect_uri = MRTRedirect_uri;
    
    [MRTHttpTool POST:@"https://api.weibo.com/oauth2/access_token" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        //将字典转化为account模型
        MRTAccount *account = [MRTAccount accountWithDict:responseObject];
        
        //存储account
        [MRTAccountStore saveAccount:account];
        
        //执行success block
        if (success) success();
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (failure) failure(error);
        
    }];
}

@end
