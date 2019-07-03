//
//  MRTStatusTool.m
//  Webo
//
//  Created by mrtanis on 2017/5/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusTool.h"
#import "MRTStatusParameter.h"
#import "MRTStatusResult.h"
#import "MRTAccountStore.h"
#import "MRTAccount.h"
#import "MRTHttpTool.h"
#import "MJExtension.h"

#ifdef DEBUG

#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

#else

#define NSLog(FORMAT, ...) nil

#endif
@implementation MRTStatusTool

+ (void)newStatusWithSinceId:(NSString *)sinceId success:(void(^)(NSArray *statuses))success failure:(void(^)(NSError *error))failure
{
    //创建参数模型
    MRTStatusParameter *parameter = [[MRTStatusParameter alloc] init];
    
    //设置access_token
    parameter.access_token = [MRTAccountStore account].access_token;
    
    //设置sinceId
    if (sinceId) parameter.since_id = sinceId;
    //https://api.weibo.com/2/statuses/friends_timeline.json
    //发送GET请求
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/home_timeline.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
      
            //新建返回数据模型
            MRTStatusResult *result = [MRTStatusResult mj_objectWithKeyValues:responseObject];
            
            //将result.statuses作为实参传递给success block
            if (success) success(result.statuses);
        //}
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *_Nullable error) {
        
        //将error作为实参传递给failure block
        if (failure) failure(error);
    }];
}

+ (void)moreStatusWithMaxId:(NSString *)maxId success:(void(^)(NSArray *statuses))success failure:(void(^)(NSError *error))failure
{
    //新建参数模型
    MRTStatusParameter *parameter = [[MRTStatusParameter alloc] init];
    
    //设置access_token
    parameter.access_token = [MRTAccountStore account].access_token;
    
    //设置maxId
    if (maxId) parameter.max_id = maxId;
    
    //发送GET请求
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/friends_timeline.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        //新建返回数据模型
        MRTStatusResult *result = [MRTStatusResult mj_objectWithKeyValues:responseObject];
        
        //NSLog(@"此次获取旧微博的json数据%@", responseObject);
        
        //将result.statuses作为实参传递给success block
        if (success) success(result.statuses);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        //将error传递给failure block
        if (failure) failure(error);
    }];

}

+ (void)newAt_StatusWithSinceId:(NSString *)sinceId success:(void(^)(NSArray *statuses))success failure:(void(^)(NSError *error))failure
{
    //创建参数模型
    MRTStatusParameter *parameter = [[MRTStatusParameter alloc] init];
    
    //设置access_token
    parameter.access_token = [MRTAccountStore account].access_token;
    
    //设置sinceId
    if (sinceId) parameter.since_id = sinceId;
    
    //发送GET请求
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/mentions.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        
        //新建返回数据模型
        MRTStatusResult *result = [MRTStatusResult mj_objectWithKeyValues:responseObject];
        
        //将result.statuses作为实参传递给success block
        if (success) success(result.statuses);
        //}
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *_Nullable error) {
        
        //将error作为实参传递给failure block
        if (failure) failure(error);
    }];
}

+ (void)moreAt_StatusWithMaxId:(NSString *)maxId success:(void(^)(NSArray *statuses))success failure:(void(^)(NSError *error))failure
{
    //新建参数模型
    MRTStatusParameter *parameter = [[MRTStatusParameter alloc] init];
    
    //设置access_token
    parameter.access_token = [MRTAccountStore account].access_token;
    
    //设置maxId
    if (maxId) parameter.max_id = maxId;
    
    //发送GET请求
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/mentions.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        //新建返回数据模型
        MRTStatusResult *result = [MRTStatusResult mj_objectWithKeyValues:responseObject];
        
        //NSLog(@"%@", responseObject);
        
        //将result.statuses作为实参传递给success block
        if (success) success(result.statuses);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        //将error传递给failure block
        if (failure) failure(error);
    }];
    
}

+ (void)newUserStatusWithUID:(NSString *)uid SinceId:(NSString *)sinceId success:(void(^)(NSArray *statuses))success failure:(void(^)(NSError *error))failure
{
    //创建参数模型
    MRTStatusParameter *parameter = [[MRTStatusParameter alloc] init];
    
    //设置access_token
    parameter.access_token = [MRTAccountStore account].access_token;
    parameter.uid = uid;
    
    //设置sinceId
    if (sinceId) parameter.since_id = sinceId;
    //发送GET请求
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/user_timeline.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        
        //新建返回数据模型
        MRTStatusResult *result = [MRTStatusResult mj_objectWithKeyValues:responseObject];
        
        //将result.statuses作为实参传递给success block
        if (success) success(result.statuses);
        //}
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *_Nullable error) {
        
        //将error作为实参传递给failure block
        if (failure) failure(error);
    }];
}

+ (void)moreUserStatusWithUID:(NSString *)uid MaxId:(NSString *)maxId success:(void(^)(NSArray *statuses))success failure:(void(^)(NSError *error))failure
{
    //新建参数模型
    MRTStatusParameter *parameter = [[MRTStatusParameter alloc] init];
    
    //设置access_token
    parameter.access_token = [MRTAccountStore account].access_token;
    parameter.uid = uid;
    //设置maxId
    if (maxId) parameter.max_id = maxId;
    
    
    //发送GET请求
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/user_timeline.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        //新建返回数据模型
        MRTStatusResult *result = [MRTStatusResult mj_objectWithKeyValues:responseObject];
        
        //NSLog(@"此次获取旧微博的json数据%@", responseObject);
        
        //将result.statuses作为实参传递给success block
        if (success) success(result.statuses);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        //将error传递给failure block
        if (failure) failure(error);
    }];
    
}



@end
