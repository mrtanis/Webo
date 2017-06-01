//
//  MRTUnreadTool.m
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTUnreadTool.h"
#import "MRTUnreadParameter.h"
#import "MRTAccount.h"
#import "MRTAccountStore.h"
#import "MRTHttpTool.h"
#import "MJExtension.h"

@implementation MRTUnreadTool

+ (void)unreadWithSuccess:(void (^)(MRTUnreadResult *result))success
                  failure:(void (^)(NSError *error))failure
{
    MRTUnreadParameter *parameter = [MRTUnreadParameter accessToken];
    parameter.uid = [MRTAccountStore account].uid;
    
    [MRTHttpTool GET:@"https://rm.api.weibo.com/2/remind/unread_count.json" parameters:parameter.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        //将获取数据的字典转化为模型
        MRTUnreadResult *result = [MRTUnreadResult mj_objectWithKeyValues:responseObject];
        
        if (success) success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (failure) failure(error);
        
    }];
}

@end
