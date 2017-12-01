//
//  MRTAccessToken.m
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccessToken.h"
#import "MRTAccountStore.h"
#import "MRTAccount.h"

@implementation MRTAccessToken

+ (instancetype)accessToken
{
    MRTAccessToken *accessToken = [[self alloc] init];
    
    accessToken.access_token = [MRTAccountStore account].access_token;
    
    return accessToken;
}

@end
