//
//  MRTRepostResult.m
//  Webo
//
//  Created by mrtanis on 2017/6/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRepostResult.h"
#import "MRTComment.h"

@implementation MRTRepostResult


//实现这个方法的目的：告诉MJExtension框架reposts数组里面装的是什么模型
+ (NSDictionary *)objectClassInArray
{
    return @{@"reposts":[MRTComment class]};
}

@end
