//
//  MRTTextAttachment.m
//  Webo
//
//  Created by mrtanis on 2017/9/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextAttachment.h"

@implementation MRTTextAttachment

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.bounds = CGRectMake(0, -4, 20, 20);
    }
    return self;
}

@end
