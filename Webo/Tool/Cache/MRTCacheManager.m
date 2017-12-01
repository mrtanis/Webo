//
//  MRTCacheManager.m
//  Webo
//
//  Created by mrtanis on 2017/7/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCacheManager.h"
#import <CommonCrypto/CommonDigest.h>   //摘要算法
#import "NSFileManager+MRTPathMethod.h"

NSString *const defaultCachePath =@"WeboCache";
static const NSInteger defaultCacheMaxCacheAge  = 60*60*24*7;
static const NSInteger timeOut = 60*60;

@interface MRTCacheManager()
@property (nonatomic, copy) NSString *diskCachePath;
@property (nonatomic, strong) dispatch_queue_t operationQueue;

@end

@implementation MRTCacheManager

+ (MRTCacheManager *)sharedInstance
{
    static MRTCacheManager *cacheInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheInstance = [[MRTCacheManager alloc] init];
    });
    
    return cacheInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _operationQueue = dispatch_queue_create("com.dispatch.MRTCacheManager", NULL);
        
        [self initCachesfileWithName:defaultCachePath];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self
        //                                         selector:@selector(clearAllMemory)
        //                                             name:UIApplicationDidReceiveMemoryWarningNotification
        //                                           object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self
        //                                         selector:@selector(automaticCleanCache)
        //                                             name:UIApplicationWillTerminateNotification
         //                                          object:nil];
        
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backgroundCleanCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
    }
    return self;
}

- (void)clearAllMemory
{
    [[NSURLCache sharedURLCache]removeAllCachedResponses];
}

- (void)backgroundCleanCache
{
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    // Start the long-running task and return immediately.
    [self clearCacheWithTime:defaultCacheMaxCacheAge path:self.diskCachePath completion:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

}

- (void)automaticCleanCache
{
    [self clearCacheWithTime:defaultCacheMaxCacheAge path:self.diskCachePath completion:nil];
}

- (void)clearCacheWithTime:(NSTimeInterval)time path:(NSString *)path completion:(MRTCacheCompletedBlock)completion
{
    if (!time||!path)return;
    dispatch_async(self.operationQueue,^{
        // “-” time
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-time];
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        
        for (NSString *fileName in fileEnumerator){
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *current = [info objectForKey:NSFileModificationDate];
            
            if ([[current laterDate:expirationDate] isEqualToDate:expirationDate]){
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)cachesPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)initCachesfileWithName:(NSString *)name
{
    self.diskCachePath =[[self cachesPath] stringByAppendingPathComponent:name];
    NSLog(@"diskCachePath:%@", self.diskCachePath);
    
    [self createDirectoryAtPath:self.diskCachePath];
}

- (void)createDirectoryAtPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        // NSLog(@"FileDir is exists.%@",path);
    }
}

- (void)storeContent:(NSObject *)content forKey:(NSString *)key toHead:(BOOL)flag isSuccess:(MRTCacheIsSuccessBlock)isSuccess
{
    dispatch_async(self.operationQueue,^{
        NSString *codingPath =[[self cachePathForKey:key] stringByDeletingPathExtension];
        NSLog(@"缓存codingPath:%@",codingPath);
        BOOL result=[self setContent:content writeToFile:codingPath toHead:flag];
        if (result) NSLog(@"缓存成功");
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(result);
            });
        }
    });
}


- (NSString *)cachePathForKey:(NSString *)key
{
    NSString *filename = [self MD5StringForKey:key];
    return [self.diskCachePath stringByAppendingPathComponent:filename];
}

- (NSString *)MD5StringForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    return filename;
}


- (BOOL)setContent:(NSObject *)content writeToFile:(NSString *)path toHead:(BOOL)flag{
    if (!content||!path){
        return NO;
    }
    if ([content isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"要缓存的对象属于NSMutableArray");
        return  [(NSMutableArray *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSArray class]]) {
        NSLog(@"要缓存的对象属于NSArray");
        return [(NSArray *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableData class]]) {
        NSLog(@"要缓存的对象属于NSMutableData");
        return [(NSMutableData *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSData class]]) {
        NSLog(@"要缓存的对象属于NSData");
        return  [(NSData *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"要缓存的对象属于NSMutableDictionary");
        [(NSMutableDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSDictionary class]]) {
        NSLog(@"要缓存的对象属于NSDictionary");
        return  [(NSDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSJSONSerialization class]]) {
        NSLog(@"要缓存的对象属于NSJSONSerialization");
        return [(NSDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableString class]]) {
        NSLog(@"要缓存的对象属于NSMutableString");
        /*BOOL exists =[[NSFileManager defaultManager] fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO;
        if (exists) {
            NSMutableData *oldData = [NSMutableData dataWithData:[NSData dataWithContentsOfFile:path]];
            NSMutableData *strData = [NSMutableData dataWithData:[(NSString *)content dataUsingEncoding:NSUTF8StringEncoding]];
            if (flag) {
                NSLog(@"写入开头");
                [strData appendData:oldData];
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:strData options:NSJSONWritingPrettyPrinted error:&error];
                if (error) NSLog(@"%@", error);
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                return [[jsonStr dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
            } else {
                NSLog(@"写入结尾");
                [oldData appendData:strData];
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:oldData options:NSJSONWritingPrettyPrinted error:&error];
                if (error) NSLog(@"%@", error);
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                return [[jsonStr dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
            }

        } else {
            NSLog(@"没找到路径所在缓存");*/
            return [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        //}

    }else if ([content isKindOfClass:[NSString class]]) {
        NSLog(@"要缓存的对象属于NSString");
        BOOL exists =[[NSFileManager defaultManager] fileExistsAtPath:path]&&[NSFileManager isTimeOutWithPath:path timeOut:timeOut]==NO;
        if (exists) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
            if (flag) {
                NSLog(@"写入开头");
                [fileHandle seekToFileOffset:0];
            } else {
                NSLog(@"写入结尾");
                [fileHandle seekToEndOfFile];
            }
            NSString *contentStr = [(NSString *)content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            contentStr = [(NSString *)content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            contentStr = [(NSString *)content stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            NSData *strData = [(NSString *)contentStr dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:strData];
            [fileHandle closeFile];
            return YES;
        } else {
            NSLog(@"没找到路径所在缓存");
            return [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }
    }else if ([content isKindOfClass:[UIImage class]]) {
        return [UIImageJPEGRepresentation((UIImage *)content,(CGFloat)0.9) writeToFile:path atomically:YES];
    }else if ([content conformsToProtocol:@protocol(NSCoding)]) {
        return [NSKeyedArchiver archiveRootObject:content toFile:path];
    }else {
        [NSException raise:@"非法的文件内容" format:@"文件类型%@异常。", NSStringFromClass([content class])];
        return NO;
    }
    return NO;
}

- (BOOL)diskCacheExistsWithKey:(NSString *)key{
    NSString *codingPath=[[self cachePathForKey:key] stringByDeletingPathExtension];
    NSLog(@"读取缓存codingPath:%@", codingPath);
    BOOL exists =[[NSFileManager defaultManager] fileExistsAtPath:codingPath]&&[NSFileManager isTimeOutWithPath:codingPath timeOut:timeOut]==NO;
    return exists;
}

- (void)getCacheDataForKey:(NSString *)key value:(MRTCacheValueBlock)value{
    if (!key)return;
    dispatch_async(self.operationQueue,^{
        @autoreleasepool {
            NSString *filePath=[[self cachePathForKey:key] stringByDeletingPathExtension];
            NSData *diskdata= [NSData dataWithContentsOfFile:filePath];
            if (value) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    value(diskdata,filePath);
                });
            }
        }
        
    });
}



@end
