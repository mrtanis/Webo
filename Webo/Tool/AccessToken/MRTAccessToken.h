//
//  MRTAccessToken.h
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTAccessToken : NSObject

@property (nonatomic, copy) NSString *access_token;

+ (instancetype)accessToken;

@end
