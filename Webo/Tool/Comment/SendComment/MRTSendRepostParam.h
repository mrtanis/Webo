//
//  MRTSendRepostParam.h
//  Webo
//
//  Created by mrtanis on 2017/6/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccessToken.h"

@interface MRTSendRepostParam : MRTAccessToken

@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *id;
//是否在转发的同时发表评论，0：否、1：评论给当前微博、2：评论给原微博、3：都评论，默认为0
@property (nonatomic) int is_comment;

@end
