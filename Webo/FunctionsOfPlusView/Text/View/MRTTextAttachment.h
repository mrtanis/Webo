//
//  MRTTextAttachment.h
//  Webo
//
//  Created by mrtanis on 2017/9/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTTextAttachment : NSTextAttachment

//用于记录表情的chs对应的值，方便表情转字符串
@property (nonatomic, copy) NSString *emoChs;

@end
