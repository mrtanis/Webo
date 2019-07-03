//
//  MRTCacheManager.h
//  Webo
//
//  Created by mrtanis on 2017/7/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MRTCacheIsSuccessBlock)(BOOL isSuccess);
typedef void(^MRTCacheCompletedBlock)();
typedef void(^MRTCacheValueBlock)(id responseObj,NSString *filePath);

@interface MRTCacheManager : NSObject

//返回单例对象
+ (MRTCacheManager *)sharedInstance;

//将获取的内容缓存起来
- (void)storeContent:(NSObject *)content forKey:(NSString *)key toHead:(BOOL)flag isSuccess:(MRTCacheIsSuccessBlock)isSuccess;


//拼接路径与编码后的文件

- (NSString *)cachePathForKey:(NSString *)key;

//文档路径(用于保存timeline)
- (NSString *)documentPath;

//判断是否有对应的缓存
- (BOOL)diskCacheExistsWithKey:(NSString *)key;

/**
 *  返回数据及路径
 *  @param  key         存储的文件的url
 *  @param  value       返回在本地的数据及存储文件路径
 */
- (void)getCacheDataForKey:(NSString *)key value:(MRTCacheValueBlock)value;

@end
