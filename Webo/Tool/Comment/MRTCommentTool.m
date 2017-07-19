//
//  MRTCommentTool.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentTool.h"
#import "MRTCommentParam.h"
#import "MRTCommentResult.h"
#import "MRTRepostResult.h"
#import "MRTAccountStore.h"
#import "MRTAccount.h"
#import "MRTHttpTool.h"
#import "MJExtension.h"
#import "MRTSendCommentParam.h"
#import "MRTSendRepostParam.h"

@implementation MRTCommentTool

//请求新微博评论
+ (void)newCommentWithID:(NSString *)ID sinceId:(NSString *)sinceId success:(void (^) (NSArray *comments))success failure:(void (^) (NSError *error))failure
{
    //创建参数模型
    MRTCommentParam *param = [MRTCommentParam accessToken];
    param.id = ID;
    param.since_id = sinceId;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/comments/show.json" parameters:param.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        MRTCommentResult *result = [MRTCommentResult mj_objectWithKeyValues:responseObject];
        //将result.comments作为实参传递给success block
        if (success) {
            success(result.comments);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    } checkCache:NO toHead:YES];
}

//请求更多之前的评论
+ (void)moreCommentWithID:(NSString *)ID maxId:(NSString *)maxId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    //创建参数模型
    MRTCommentParam *param = [MRTCommentParam accessToken];
    param.id = ID;
    param.max_id = maxId;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/comments/show.json" parameters:param.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        MRTCommentResult *result = [MRTCommentResult mj_objectWithKeyValues:responseObject];
        //将result.comments作为实参传递给success block
        if (success) {
            success(result.comments);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    } checkCache:NO toHead:NO];
}

//发送评论
+ (void)sendCommentWithText:(NSString *)text ID:(NSString *)ID success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    MRTSendCommentParam *param = [MRTSendCommentParam accessToken];
    param.comment = text;
    param.id = ID;
    
    [MRTHttpTool POST:@"https://api.weibo.com/2/comments/create.json" parameters:param.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        if (success) success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) failure(error);
    }];
}


//获取新转发
+ (void)newRepostWithID:(NSString *)ID sinceId:(NSString *)sinceId success:(void (^) (NSArray *reposts))success failure:(void (^) (NSError *error))failure;
{
    MRTCommentParam *param = [MRTCommentParam accessToken];
    param.id = ID;
    param.since_id = sinceId;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/repost_timeline.json" parameters:param.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        MRTRepostResult *result = [MRTRepostResult mj_objectWithKeyValues:responseObject];
        //将result.comments作为实参传递给success block
        if (success) {
            success(result.reposts);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    } checkCache:NO toHead:YES];
}

//获取旧转发
+ (void)moreRepostWithID:(NSString *)ID maxId:(NSString *)maxId success:(void (^) (NSArray *reposts))success failure:(void (^) (NSError *error))failure
{
    MRTCommentParam *param = [MRTCommentParam accessToken];
    param.id = ID;
    param.max_id = maxId;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/statuses/repost_timeline.json" parameters:param.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        MRTRepostResult *result = [MRTRepostResult mj_objectWithKeyValues:responseObject];
        //将result.comments作为实参传递给success block
        if (success) {
            success(result.reposts);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    } checkCache:NO toHead:NO];

}

//转发微博
+ (void)sendRepostWithText:(NSString *)text ID:(NSString *)ID is_comment:(int)isComment success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    MRTSendRepostParam *param = [MRTSendRepostParam accessToken];
    param.status = text;
    param.id = ID;
    param.is_comment = isComment;
    
    [MRTHttpTool POST:@"https://api.weibo.com/2/statuses/repost.json" parameters:param.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        if (success) success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) failure(error);
    }];

}
@end
