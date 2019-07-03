//
//  MRTStatusParameter.h
//  Webo
//
//  Created by mrtanis on 2017/5/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTStatusParameter : NSObject
//uid只有获取指定用户发布的微博时才需要
@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *access_token;

@property (nonatomic, copy) NSString *since_id;

@property (nonatomic, copy) NSString *max_id;



@end
