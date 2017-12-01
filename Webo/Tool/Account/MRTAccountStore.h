//
//  MRTAccountStore.h
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRTAccount;

@interface MRTAccountStore : NSObject

+ (MRTAccount *)account;

+ (void)saveAccount:(MRTAccount *)account;

+ (void)accountWithCode:(NSString *)code success:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
