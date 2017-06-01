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

+ (NSDictionary *)objectClassInArray
{
    return @{@"statuses":[MRTStatus class]};
}

@end
