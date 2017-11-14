//
//  MRTCommentParam.h
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//


#import "MRTAccessToken.h"

@interface MRTCommentParam : MRTAccessToken

//需要查询的微博id
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *since_id;
@property (nonatomic, copy) NSString *max_id;

@end
