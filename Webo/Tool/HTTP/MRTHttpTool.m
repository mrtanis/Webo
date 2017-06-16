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

+(void) UPLOAD:(NSString*_Nullable)urlString parameters:(id _Nullable )parameters uploadData:(NSData*_Nullable)imageData success:(void(^_Nullable)(id _Nullable responseObject))success failure:(void(^_Nullable)(NSError* _Nullable error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:urlString
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    //上传的文件在这里拼接到formdata
    //
    //  filedata 要上传的文件（二进制）
    //  name 参数名称 此处为pic
    //  filename 上传到服务器的名称
    //  mimetype 文件类型
    //

        [formData appendPartWithFileData:imageData name:@"pic" fileName:@"image.png" mimeType:@"image/png"];
    }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        }];
}


@end
