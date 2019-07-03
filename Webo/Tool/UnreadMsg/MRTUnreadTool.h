//
//  MRTUnreadTool.h
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTUnreadResult.h"

@interface MRTUnreadTool : NSObject

+ (void)unreadWithSuccess:(void (^)(MRTUnreadResult *result))success
                  failure:(void (^)(NSError *error))failure;

@end
