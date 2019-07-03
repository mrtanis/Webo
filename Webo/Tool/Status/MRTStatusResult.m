//
//  MRTStatusResult.m
//  Webo
//
//  Created by mrtanis on 2017/5/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusResult.h"
#import "MRTStatus.h"

@implementation MRTStatusResult
//模型(MRTStatusResult)中有个数组(statuses)属性，数组里面又要装着其它模型(MRTStatus)
//实现这个方法的目的：告诉MJExtension框架statuses数组里面装的是什么模型
+ (NSDictionary *)objectClassInArray
{
    return @{@"statuses":[MRTStatus class]};
}

@end
