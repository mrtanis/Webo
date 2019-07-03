//
//  NSAttributedString+MRTConvert.m
//  Webo
//
//  Created by mrtanis on 2017/9/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "NSAttributedString+MRTConvert.h"
#import "MRTTextAttachment.h"

@implementation NSAttributedString (MRTConvert)

- (NSString *)getPlainEmoString
{
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSInteger offset = 0;
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[MRTTextAttachment class]]) {
            [plainString replaceCharactersInRange:NSMakeRange(range.location + offset, range.length) withString:[(MRTTextAttachment *)value emoChs]];
            offset += ((MRTTextAttachment *)value).emoChs.length - 1;
        }
    }];
    
    return plainString;
}

@end
