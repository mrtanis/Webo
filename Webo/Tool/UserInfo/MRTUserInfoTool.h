//
//  MRTUserInfoTool.h
//  Webo
//
//  Created by mrtanis on 2017/5/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTUser.h"
#import "MRTUnreadParameter.h"

@interface MRTUserInfoTool : NSObject

+ (void)userInfoWithSuccess:(void (^)(MRTUser *user))success failure:(void (^)(NSError *error))failure;


@end
