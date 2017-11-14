//
//  MRTHttpTool.m
//  Webo
//
//  Created by mrtanis on 2017/5/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTHttpTool.h"
#import "AFNetworking.h"
#import "MRTCacheManager.h"

@interface MRTHttpTool()
@property (nonatomic, strong) AFHTTPSessionManager *AFmanager;

@end

@implementation MRTHttpTool

+ (MRTHttpTool *)sharedInstance
{
    static MRTHttpTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MRTHttpTool alloc] init];
    });
    
    return sharedInstance;
}


+ (void)GET:(NSString *_Nonnull)urlString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
 checkCache:(BOOL)checkCache
     toHead:(BOOL)flag
{
    [[MRTHttpTool sharedInstance] GET:urlString parameters:parameters progress:progress success:success failure:failure checkCache:checkCache toHead:flag];
    
}

+ (void)GET:(NSString *_Nonnull)urlString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    [[MRTHttpTool sharedInstance] GET:urlString parameters:parameters progress:progress success:success failure:failure];
    
}

+ (void)POST:(NSString *_Nonnull)urlString
  parameters:(nullable id)parameters
    progress:(nullable void (^)(NSProgress * _Nonnull uploadPregress))uploadProgress
     success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    [[MRTHttpTool sharedInstance] POST:urlString parameters:parameters progress:uploadProgress success:success failure:failure];
}

+(void) UPLOAD:(NSString*_Nullable)urlString parameters:(id _Nullable )parameters uploadData:(NSMutableArray*_Nullable)imageData success:(void(^_Nullable)(id _Nullable responseObject))success failure:(void(^_Nullable)(NSError* _Nullable error))failure
{
    [[MRTHttpTool sharedInstance] UPLOAD:urlString parameters:parameters uploadData:imageData success:success failure:failure];
}

- (void)GET:(NSString *_Nonnull)URLString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
 checkCache:(BOOL)checkCache
     toHead:(BOOL)flag;
{
    if (checkCache) {
        NSString *key = URLString;
        if ([[MRTCacheManager sharedInstance] diskCacheExistsWithKey:key]) {
            NSLog(@"找到缓存");
            [[MRTCacheManager sharedInstance] getCacheDataForKey:key value:^(id responseObj, NSString *filePath) {
                
                NSError *error = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingMutableContainers error:&error];
                
                if (error) NSLog(@"%@", error);

                if (success) success(nil, dict);
            }];
        } else {
            NSLog(@"没找到缓存");
            //设置请求超时为6秒
            [self.AFmanager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            self.AFmanager.requestSerializer.timeoutInterval = 6.f;
            [self.AFmanager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
            
            [self.AFmanager GET:URLString
                     parameters:parameters
                       progress:progress
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            NSError *error = nil;
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
                            if (error) NSLog(@"%@", error);
                            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            
                            NSString *key = URLString;
                            [[MRTCacheManager sharedInstance] storeContent:jsonStr forKey:key toHead:flag isSuccess:nil];
                            if (success) success(nil, responseObject);
                        } failure:failure];
        }
    } else {
        //设置请求超时为6秒
        [self.AFmanager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        self.AFmanager.requestSerializer.timeoutInterval = 6.f;
        [self.AFmanager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        [self.AFmanager GET:URLString
                 parameters:parameters
                   progress:progress
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
                        if (error) NSLog(@"%@", error);
                        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        NSString *key = URLString;
                        [[MRTCacheManager sharedInstance] storeContent:jsonStr forKey:key toHead:flag isSuccess:nil];
                        if (success) success(nil, responseObject);
                    } failure:failure];
    }
}

- (void)GET:(NSString *_Nonnull)URLString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    //设置请求超时为6秒
    [self.AFmanager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.AFmanager.requestSerializer.timeoutInterval = 6.f;
    [self.AFmanager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [self.AFmanager GET:URLString
             parameters:parameters
               progress:progress
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (success) success(nil, responseObject);
                } failure:failure];
}

- (void)POST:(NSString *_Nonnull)urlString
  parameters:(nullable id)parameters
    progress:(nullable void (^)(NSProgress * _Nonnull uploadPregress))uploadProgress
     success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
{
    //设置请求超时为6秒
    [self.AFmanager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.AFmanager.requestSerializer.timeoutInterval = 6.f;
    [self.AFmanager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [self.AFmanager POST:urlString
       parameters:parameters
         progress:uploadProgress
          success:success
          failure:failure];
}

- (void) UPLOAD:(NSString*_Nullable)urlString parameters:(id _Nullable )parameters uploadData:(NSMutableArray*_Nullable)imageData success:(void(^_Nullable)(id _Nullable responseObject))success failure:(void(^_Nullable)(NSError* _Nullable error))failure
{
    //设置请求超时为15秒
    [self.AFmanager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.AFmanager.requestSerializer.timeoutInterval = 15.f;
    [self.AFmanager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [self.AFmanager POST:urlString
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    //上传的文件在这里拼接到formdata
    //
    //  filedata 要上传的文件（二进制）
    //  name 参数名称 此处为pic
    //  filename 上传到服务器的名称
    //  mimetype 文件类型
    //
    for (int i = 0; i < imageData.count; i++) {
        [formData appendPartWithFileData:imageData[i] name:@"pic" fileName:[NSString stringWithFormat:@"image%d.jpeg", i] mimeType:@"image/jpeg"];
    }
    
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

- (AFHTTPSessionManager*)AFmanager{
    if (!_AFmanager) {
        _AFmanager=[AFHTTPSessionManager manager];
    }
    
    return _AFmanager;
}


@end
