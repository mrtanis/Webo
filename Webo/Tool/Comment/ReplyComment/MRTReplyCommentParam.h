//
//  MRTReplyCommentParam.h
//  Webo
//
//  Created by mrtanis on 2017/8/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccessToken.h"

@interface MRTReplyCommentParam : MRTAccessToken

@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *id;

@end
