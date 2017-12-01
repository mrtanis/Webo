//
//  MRTCommentTool.h
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTCommentTool : NSObject

#pragma mark 首页点击微博后的评论、转发列表
//获取新评论
+ (void)newCommentWithID:(NSString *)ID sinceId:(NSString *)sinceId success:(void (^) (NSArray *comments))success failure:(void (^) (NSError *error))failure;
//获取旧评论
+ (void)moreCommentWithID:(NSString *)ID maxId:(NSString *)maxId success:(void (^) (NSArray *comments))success failure:(void (^) (NSError *error))failure;
//发送评论
+ (void)sendCommentWithText:(NSString *)text ID:(NSString *)ID success:(void (^)())success failure:(void (^)(NSError *error))failure;
//回复评论
+ (void)replyCommentWithText:(NSString *)text ID:(NSString *)ID CID:(NSString *)CID success:(void (^)())success failure:(void (^)(NSError *error))failure;

//获取新转发
+ (void)newRepostWithID:(NSString *)ID sinceId:(NSString *)sinceId success:(void (^) (NSArray *reposts))success failure:(void (^) (NSError *error))failure;
//获取旧转发
+ (void)moreRepostWithID:(NSString *)ID maxId:(NSString *)maxId success:(void (^) (NSArray *reposts))success failure:(void (^) (NSError *error))failure;
//转发微博
+ (void)sendRepostWithText:(NSString *)text ID:(NSString *)ID is_comment:(int)isComment success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark 消息页的@我的评论列表
+ (void)newAt_CommentWithSinceId:(NSString *)sinceId success:(void(^)(NSArray *comments))success failure:(void(^)(NSError *error))failure;
+ (void)moreAt_CommentWithMaxId:(NSString *)maxId success:(void(^)(NSArray *comments))success failure:(void(^)(NSError *error))failure;

#pragma mark 消息页我收到的评论列表
+ (void)newIn_CommentWithSinceId:(NSString *)sinceId success:(void(^)(NSArray *comments))success failure:(void(^)(NSError *error))failure;
+ (void)moreIn_CommentWithMaxId:(NSString *)maxId success:(void(^)(NSArray *comments))success failure:(void(^)(NSError *error))failure;

#pragma mark 消息页我发出的评论列表
+ (void)newOut_CommentWithSinceId:(NSString *)sinceId success:(void(^)(NSArray *comments))success failure:(void(^)(NSError *error))failure;
+ (void)moreOut_CommentWithMaxId:(NSString *)maxId success:(void(^)(NSArray *comments))success failure:(void(^)(NSError *error))failure;
@end
