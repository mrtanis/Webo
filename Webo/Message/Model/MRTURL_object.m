//
//  MRTURL_object.m
//  Webo
//
//  Created by mrtanis on 2017/7/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTURL_object.h"

@implementation MRTURL_object

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_object forKey:@"object"];
    [aCoder encodeInt:_play_count forKey:@"play_count"];
    [aCoder encodeObject:_url_ori forKey:@"url_ori"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _object = [aDecoder decodeObjectForKey:@"object"];
        _play_count = [aDecoder decodeIntForKey:@"play_count"];
        _url_ori = [aDecoder decodeObjectForKey:@"url_ori"];
    }
    
    return self;
}

@end
