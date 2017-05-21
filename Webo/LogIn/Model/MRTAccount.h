//
//  MRTAccount.h
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

/*
"access_token" = "2.00FLU6KDUnKE8Bd2a7601ed10ku5WF";
"expires_in" = 157679999;
"remind_in" = 157679999;
uid = 2902236063;
*/

#import <Foundation/Foundation.h>

@interface MRTAccount : NSObject <NSCoding>

//用户授权的唯一票据，用于调用微博的开放接口，同时也是第三方应用验证微博用户登录的唯一票据
@property (nonatomic, copy) NSString *access_token;
//access_token的生命周期，单位是秒数
@property (nonatomic, copy) NSString *expires_in;
//授权用户的唯一标识符，本字段只是为了方便开发者，减少一次user/show接口调用而返回的，第三方应用不能用此字段作为用户登录状态的识别，只有access_token才是用户授权的唯一票据
@property (nonatomic, copy) NSString *uid;
//access_token的生命周期（该参数即将废弃，开发者请使用expires_in）
@property (nonatomic, copy) NSString *remind_in;
//过期时间 = 当前保存时间 + 有效期
@property (nonatomic, strong) NSDate *expires_date;

+ (instancetype)accountWithDict:(NSDictionary *)dict;

@end
