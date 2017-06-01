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

@implementation MRTUserInfoTool

+ (void)userInfoWithSuccess:(void (^)(MRTUser *))success failure:(void (^)(NSError *))failure
{
    //由于参数是access_token和uid，可直接利用MRTUnreadParameter模型
    //先设置access_token
    MRTUnreadParameter *parameter = [MRTUnreadParameter accessToken];
    //再设置uid
    parameter.uid = [MRTAccountStore account].uid;
    
    [MRTHttpTool GET:@"https://api.weibo.com/2/users/show.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        //字典转模型
        MRTUser *user = [MRTUser mj_objectWithKeyValues:responseObject];
        
        //将user模型传递给success block
        if (success) success(user);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (failure) failure(error);
    }];
}


@end
