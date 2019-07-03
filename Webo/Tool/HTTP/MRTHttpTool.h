//
//  MRTHttpTool.h
//  Webo
//
//  Created by mrtanis on 2017/5/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTHttpTool : NSObject

//返回单例对象
+ (MRTHttpTool *_Nullable)sharedInstance;

+ (void)GET:(NSString *_Nonnull)urlString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
 checkCache:(BOOL)checkCache
     toHead:(BOOL)flag;

+ (void)GET:(NSString *_Nonnull)urlString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

+ (void)POST:(NSString *_Nonnull)urlString
  parameters:(nullable id)parameters
    progress:(nullable void (^)(NSProgress * _Nonnull uploadPregress))uploadProgress
     success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

+(void) UPLOAD:(NSString*_Nullable)url parameters:(id _Nullable )parameters uploadData:(NSMutableArray*_Nullable)imageData success:(void(^_Nullable)(id _Nullable responseObject))success failure:(void(^_Nullable)(NSError* _Nullable error))failure;

- (void)GET:(NSString *_Nonnull)urlString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
 checkCache:(BOOL)checkCache
     toHead:(BOOL)flag;

- (void)GET:(NSString *_Nonnull)urlString
 parameters:(id _Nullable )parameters
   progress:(void (^_Nullable)(NSProgress * _Nonnull downloadProgress))progress
    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject))success
    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

- (void)POST:(NSString *_Nonnull)urlString
  parameters:(nullable id)parameters
    progress:(nullable void (^)(NSProgress * _Nonnull uploadPregress))uploadProgress
     success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

- (void) UPLOAD:(NSString*_Nullable)urlString parameters:(id _Nullable )parameters uploadData:(NSMutableArray*_Nullable)imageData success:(void(^_Nullable)(id _Nullable responseObject))success failure:(void(^_Nullable)(NSError* _Nullable error))failure;

@end
