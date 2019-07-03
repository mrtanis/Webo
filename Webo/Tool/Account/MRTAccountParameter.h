//
//  MRTAccountParameter.h
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTAccountParameter : NSObject

//AppKey
@property (nonatomic, copy) NSString *client_id;

//AppSecret
@property (nonatomic, copy) NSString *client_secret;

//填写"authorization_code"
@property (nonatomic, copy) NSString *grant_type;

//通过authorize得到的code
@property (nonatomic, copy) NSString *code;

//回调地址
@property (nonatomic, copy) NSString *redirect_uri;

@end
