//
//  MRTHttpTool.m
//  Webo
//
//  Created by mrtanis on 2017/5/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTHttpTool.h"
#import "AFNetworking.h"

@implementation MRTHttpTool

+ (void)GET:(NSString *_Nonnull)URLString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:URLString
      parameters:parameters
        progress:progress
         success:success
         failure:failure];
}

+ (void)POST:(NSString *_Nonnull)urlString
  parameters:(nullable id)parameters
    progress:(nullable void (^)(NSProgress * _Nonnull uploadPregress))uploadProgress
     success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString
       parameters:parameters
         progress:uploadProgress
          success:success
          failure:failure];
}

@end
