//
//  MRTStream.m
//  Webo
//
//  Created by mrtanis on 2017/9/5.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStream.h"

@implementation MRTStream

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_hd_url forKey:@"hd_url"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _hd_url = [aDecoder decodeObjectForKey:@"hd_url"];
    }
    
    return self;
}

@end
