//
//  MRTTextTool.h
//  Webo
//
//  Created by mrtanis on 2017/6/15.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTTextTool : NSObject

+ (void)weboWithStatus:(NSString *)status success:(void (^)())success failure:(void (^)(NSError *))failure;
+ (void)weboWithStatus:(NSString *)status imageData:(NSMutableArray *)imageData success:(void (^)())success failure:(void (^)(NSError *))failure;

@end
