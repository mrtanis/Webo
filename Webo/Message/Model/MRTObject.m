//
//  MRTObject.m
//  Webo
//
//  Created by mrtanis on 2017/7/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTObject.h"

@implementation MRTObject

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_duration forKey:@"duration"];
    [aCoder encodeObject:_image forKey:@"image"];
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_stream forKey:@"stream"];
    [aCoder encodeObject:_object forKey:@"object"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _duration = [aDecoder decodeIntForKey:@"duration"];
        _image = [aDecoder decodeObjectForKey:@"image"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _stream = [aDecoder decodeObjectForKey:@"stream"];
        _object = [aDecoder decodeObjectForKey:@"object"];
    }
    
    return self;
}

@end
