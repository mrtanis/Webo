//
//  MRTUserInfoTool.m
//  Webo
//
//  Created by mrtanis on 2017/5/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTUserInfoTool.h"
#import "MRTAccountStore.h"
#import "MRTAccount.h"
#import "MRTHttpTool.h"
#import "MJExtension.h"


#ifdef DEBUG

#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

#else

#define NSLog(FORMAT, ...) nil

#endif
@implementation MRTUserInfoTool

+ (void)userInfoWithSuccess:(void (^)(MRTUser *))success failure:(void (^)(NSError *))failure
{
    //由于参数是access_token和uid，可直接利用MRTUnreadParameter模型
    //先设置access_token
    MRTUnreadParameter *parameter = [MRTUnreadParameter accessToken];
    //再设置uid
    parameter.uid = [MRTAccountStore account].uid;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/users/show.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        //NSLog(@"%@", responseObject);
        //字典转模型
        MRTUser *user = [MRTUser mj_objectWithKeyValues:responseObject];
        
        //将user模型传递给success block
        if (success) success(user);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (failure) failure(error);
    } checkCache:NO toHead:YES];
}

+ (void)saveUserInfo:(MRTUser *)user
{
    [NSKeyedArchiver archiveRootObject:user toFile:[self userInfoArchivePath]];
    
}

+ (NSString *)userInfoArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"userInfo.data"];
    
    return path;
}

+ (MRTUser *)userInfo
{
    MRTUser *user = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userInfoArchivePath]];
    
    return user;
}


@end
