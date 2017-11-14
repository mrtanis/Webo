//
//  MRTOtherUser.m
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTOtherUser.h"

@implementation MRTOtherUser
//因为description是已有关键字，所以要改名
+ (NSDictionary *)replacedKeyFromPropertyName{
    
    return @{@"introduction":@"description"};
    
}

- (void)setMbtype:(int)mbtype
{
    _mbtype = mbtype;
    
    _vip = (mbtype > 2);
}
@end
