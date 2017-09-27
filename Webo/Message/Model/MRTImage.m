//
//  MRTImage.m
//  Webo
//
//  Created by mrtanis on 2017/7/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTImage.h"

@implementation MRTImage

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_height forKey:@"height"];
    [aCoder encodeInt:_width forKey:@"width"];
    [aCoder encodeObject:_url forKey:@"url"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _height = [aDecoder decodeIntForKey:@"height"];
        _width = [aDecoder decodeIntForKey:@"width"];
        _url = [aDecoder decodeObjectForKey:@"url"];
    }
    
    return self;
}

@end
