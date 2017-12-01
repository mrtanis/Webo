//
//  MRTFriendsListTool.m
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTFriendsListTool.h"
#import "MRTFriendsListParameter.h"
#import "MRTFriendsListResult.h"
#import "MRTHttpTool.h"
#import "MJExtension.h"
#import "MRTRelationParameter.h"
#import "MRTRelationResult.h"


#ifdef DEBUG

#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);

#else

#define NSLog(FORMAT, ...) nil

#endif
@implementation MRTFriendsListTool
+ (void)newFriendsListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure
{
    //创建参数模型
    MRTFriendsListParameter *parameter = [MRTFriendsListParameter accessToken];
    parameter.uid = uid;
    parameter.cursor = cursor;
    parameter.trim_status = trim_status;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/friendships/friends.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        MRTFriendsListResult *result = [MRTFriendsListResult mj_objectWithKeyValues:responseObject];

        if (success) success(result.users, result.next_cursor);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) failure(error);
    }];
}

+ (void)moreFriendsListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure
{
    //创建参数模型
    MRTFriendsListParameter *parameter = [MRTFriendsListParameter accessToken];
    parameter.uid = uid;
    parameter.cursor = cursor;
    parameter.trim_status = trim_status;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/friendships/friends.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        MRTFriendsListResult *result = [MRTFriendsListResult mj_objectWithKeyValues:responseObject];

        if (success) success(result.users, result.next_cursor);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) failure(error);
    }];
}

+ (void)newFollowersListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure
{
    //创建参数模型
    MRTFriendsListParameter *parameter = [MRTFriendsListParameter accessToken];
    parameter.uid = uid;
    parameter.cursor = cursor;
    parameter.trim_status = trim_status;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/friendships/followers.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        MRTFriendsListResult *result = [MRTFriendsListResult mj_objectWithKeyValues:responseObject];

        if (success) success(result.users, result.next_cursor);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) failure(error);
    }];
}

+ (void)moreFollowersListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure
{
    //创建参数模型
    MRTFriendsListParameter *parameter = [MRTFriendsListParameter accessToken];
    parameter.uid = uid;
    parameter.cursor = cursor;
    parameter.trim_status = trim_status;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/friendships/followers.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        MRTFriendsListResult *result = [MRTFriendsListResult mj_objectWithKeyValues:responseObject];
        
        if (success) success(result.users, result.next_cursor);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) failure(error);
    }];
}

+ (void)getRelationWithSource_id:(NSString *)source_id target_id:(NSString *)target_id success:(void(^)(MRTRelation *relation))success failure:(void(^)(NSError *error))failure
{
    MRTRelationParameter *parameter = [MRTRelationParameter accessToken];
    parameter.source_id = source_id;
    parameter.target_id = target_id;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/friendships/show.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        MRTRelationResult *result = [MRTRelationResult mj_objectWithKeyValues:responseObject];
        
        MRTRelation *relation = result.source;
        if (success) success(relation);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) failure(error);
    }];
    
}
@end
