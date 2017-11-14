//
//  MRTVideoURL.m
//  Webo
//
//  Created by mrtanis on 2017/10/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTVideoURL.h"

@implementation MRTVideoURL

- (void)setVideoUrl:(NSURL *)videoUrl
{
    _videoUrl = videoUrl;
    
    //设置过期时间为1小时
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60*60];
    _expires_date = date;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_videoUrl forKey:@"videoUrl"];
    [aCoder encodeObject:_expires_date forKey:@"expires_date"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _videoUrl = [aDecoder decodeObjectForKey:@"videoUrl"];
        _expires_date = [aDecoder decodeObjectForKey:@"expires_date"];
    }
    
    return self;
}

@end
