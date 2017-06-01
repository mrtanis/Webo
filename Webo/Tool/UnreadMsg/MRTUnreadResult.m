//
//  MRTUnreadResult.m
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTUnreadResult.h"

@implementation MRTUnreadResult

- (int)messageCount
{
    return _cmt + _dm + _mention_cmt + _mention_status;
}

- (int)totalCount
{
    return _cmt + _dm + _mention_cmt + _mention_status + _follower;
}
@end
