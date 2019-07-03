//
//  MRTUnreadResult.h
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//


/*
status	int	新微博未读数
follower	int	新粉丝数
cmt	int	新评论数
dm	int	新私信数
mention_status	int	新提及我的微博数
mention_cmt	int	新提及我的评论数
group	int	微群消息未读数
private_group	int	私有微群消息未读数
notice	int	新通知未读数
invite	int	新邀请未读数
badge	int	新勋章数
photo	int	相册消息未读数
 */
 
#import <Foundation/Foundation.h>

@interface MRTUnreadResult : NSObject

@property (nonatomic) int status;

@property (nonatomic) int follower;

@property (nonatomic) int cmt;

@property (nonatomic) int dm;

@property (nonatomic) int mention_status;

@property (nonatomic) int mention_cmt;

@property (nonatomic) int group;

@property (nonatomic) int private_group;

@property (nonatomic) int notice;

@property (nonatomic) int invite;

@property (nonatomic) int badge;

//消息按钮角标、程序图标角标
- (int)messageCount;

- (int)totalCount;
@end
