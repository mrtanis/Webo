//
//  MRTTimeLineStore.h
//  Webo
//
//  Created by mrtanis on 2017/10/19.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTTimeLineStore : NSObject

+ (void)saveTimeLine:(NSMutableArray *)array;
+ (NSString *)timelineArchivePath;
+ (void)deleteTimeLine;

+ (void)saveTimeLineWithAt_status:(NSMutableArray *)at_status at_comment:(NSMutableArray *)at_comment in_comment:(NSMutableArray *)in_comment out_comment:(NSMutableArray *)out_comment;
+ (NSString *)timelineArchivePathWithIndex:(NSInteger)index;
+ (void)deleteTimeLineOfAtMe;
@end
