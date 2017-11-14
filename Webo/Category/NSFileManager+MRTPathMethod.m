//
//  NSFileManager+MRTPathMethod.m
//  Webo
//
//  Created by mrtanis on 2017/7/10.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "NSFileManager+MRTPathMethod.h"

@implementation NSFileManager (MRTPathMethod)

+(BOOL)isTimeOutWithPath:(NSString *)path timeOut:(NSTimeInterval)time{
    
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    NSDate *current = [info objectForKey:NSFileModificationDate];
    
    NSDate *date = [NSDate date];
    
    NSTimeInterval currentTime = [date timeIntervalSinceDate:current];
    
    if (currentTime>time) {
        
        return YES;
    }else{
        
        return NO;
    }
    
}
@end
