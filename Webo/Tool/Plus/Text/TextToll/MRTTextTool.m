//
//  MRTTextTool.m
//  Webo
//
//  Created by mrtanis on 2017/6/15.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextTool.h"
#import "MRTTextParam.h"
#import "MRTHttpTool.h"
#import "MJExtension.h"

@implementation MRTTextTool
+ (void)weboWithStatus:(NSString *)status success:(void (^)())success failure:(void (^)(NSError *))failure
{
    MRTTextParam *param = [MRTTextParam accessToken];
    param.status = status;
    
    [MRTHttpTool POST:@"https://api.weibo.com/2/statuses/update.json" parameters:param.mj_keyValues progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)weboWithStatus:(NSString *)status image:(UIImage *)image success:(void (^)())success failure:(void (^)(NSError *))failure
{
    MRTTextParam *param = [MRTTextParam accessToken];
    param.status = status;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [MRTHttpTool UPLOAD:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:param.mj_keyValues uploadData:imageData success:^(id  _Nullable responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
