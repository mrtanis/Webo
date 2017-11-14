//
//  MRTTimeLineStore.m
//  Webo
//
//  Created by mrtanis on 2017/10/19.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTimeLineStore.h"

@implementation MRTTimeLineStore

+ (void)saveTimeLine:(NSMutableArray *)array
{
    NSString *path = [self timelineArchivePath];
    //[self.statusFrames removeAllObjects];
    [NSKeyedArchiver archiveRootObject:array toFile:path];
}

+ (void)deleteTimeLine
{
    NSData *data = [NSData data];
    [data writeToFile:[self timelineArchivePath] atomically:YES];
}

+ (NSString *)timelineArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //从documentDirectories数组获取第一个，也是唯一文档目录路径
    NSString *documentDirectory = [documentDirectories firstObject];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"timeline.data"];
    
    return path;
}



+ (void)saveTimeLineWithAt_status:(NSMutableArray *)at_status at_comment:(NSMutableArray *)at_comment in_comment:(NSMutableArray *)in_comment out_comment:(NSMutableArray *)out_comment
{
    for (int i = 0; i < 4; i++) {
        NSString *path = [self timelineArchivePathWithIndex:i];

        if (i == 0) {
            [NSKeyedArchiver archiveRootObject:at_status toFile:path];
        }
        if (i == 1) {
            [NSKeyedArchiver archiveRootObject:at_comment toFile:path];
        }
        if (i == 2) {
            [NSKeyedArchiver archiveRootObject:in_comment toFile:path];
        }
        if (i == 3) {
            [NSKeyedArchiver archiveRootObject:out_comment toFile:path];
        }
        
    }
}

+ (NSString *)timelineArchivePathWithIndex:(NSInteger)index
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //从documentDirectories数组获取第一个，也是唯一文档目录路径
    NSString *documentDirectory = [documentDirectories firstObject];
    NSString *path = @"";
    if (index == 0) {
        path = [documentDirectory stringByAppendingPathComponent:@"at_statusTimeline.data"];
    }
    if (index == 1) {
        path = [documentDirectory stringByAppendingPathComponent:@"at_commentTimeline.data"];
    }
    if (index == 2) {
        path = [documentDirectory stringByAppendingPathComponent:@"in_commentTimeline.data"];
    }
    if (index == 3) {
        path = [documentDirectory stringByAppendingPathComponent:@"out_commentTimeline.data"];
    }
    
    return path;
}

+ (void)deleteTimeLineOfAtMe
{
    for (int i = 0; i < 4; i++) {
        NSString *path = [self timelineArchivePathWithIndex:i];
        
        NSData *data = [NSData data];
        [data writeToFile:path atomically:YES];
    }
}
@end
