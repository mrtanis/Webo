//
//  MRTUserInfoTool.h
//  Webo
//
//  Created by mrtanis on 2017/5/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTUser.h"
#import "MRTUnreadParameter.h"

@interface MRTUserInfoTool : NSObject

//通过网络获取用户信息
+ (void)userInfoWithSuccess:(void (^)(MRTUser *user))success failure:(void (^)(NSError *error))failure;
//将用户信息保存到本地
+ (void)saveUserInfo:(MRTUser *)user;
//获取本地保存的用户信息
+ (MRTUser *)userInfo;

@end
