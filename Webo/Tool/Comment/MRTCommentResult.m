//
//  MRTCommentResult.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentResult.h"
#import "MRTComment.h"

@implementation MRTCommentResult
//实现这个方法的目的：告诉MJExtension框架comments数组里面装的是什么模型
+ (NSDictionary *)objectClassInArray
{
    return @{@"comments":[MRTComment class]};
}

@end
