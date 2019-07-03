//
//  MRTRelation.m
//  Webo
//
//  Created by mrtanis on 2017/10/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRelation.h"

@implementation MRTRelation

//因为id是已有关键字，所以要改名
+ (NSDictionary *)replacedKeyFromPropertyName{
    
    return @{@"uid":@"id"};
    
}

@end
