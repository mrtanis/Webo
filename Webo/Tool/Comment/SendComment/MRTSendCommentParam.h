//
//  MRTSendCommentParam.h
//  Webo
//
//  Created by mrtanis on 2017/6/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccessToken.h"

@interface MRTSendCommentParam : MRTAccessToken

@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *id; //要回复的微博id
@property (nonatomic, copy) NSString *cid; //要回复得评论id


@end
