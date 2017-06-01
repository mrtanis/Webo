//
//  MRTUser.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTUser.h"

@implementation MRTUser

- (void)setMbtype:(int)mbtype
{
    _mbtype = mbtype;
    
    _vip = (mbtype > 2);
}


@end
