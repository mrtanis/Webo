//
//  MRTBadgeView.m
//  Webo
//
//  Created by mrtanis on 2017/5/8.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTBadgeView.h"
#import "UIView+MRTFrame.h"

#define MRTBadgeViewFont [UIFont systemFontOfSize:11]

@implementation MRTBadgeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //设置字体大小
        self.titleLabel.font = MRTBadgeViewFont;
        //设置角标背景图片
        [self setBackgroundImage:[UIImage imageNamed:@"main_badge"] forState:UIControlStateNormal];
        //不可交互
        self.userInteractionEnabled = NO;
        //根据背景图调整合适尺寸
        [self sizeToFit];
    }
    return self;
}

- (void)setBadgeValue:(NSString *)badgeValue
{
    _badgeValue = badgeValue;
    //根据badgeValue的值判断是否显示角标
    if (badgeValue.length == 0 || [badgeValue isEqualToString:@"0"]) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
    
    NSMutableDictionary *sizeAttrs = [[NSMutableDictionary alloc] init];
    sizeAttrs[NSViewSizeDocumentAttribute] = MRTBadgeViewFont;
    CGSize size = [badgeValue sizeWithAttributes:sizeAttrs];
    //根据文字的尺寸是否大于控件的宽度来角标图像，大于只显示圆点，小于则显示值
    if (size.width > self.width) {
        [self setImage:[UIImage imageNamed:@"new_dot"] forState:UIControlStateNormal];
        [self setTitle:nil forState:UIControlStateNormal];
        [self setBackgroundImage:nil forState:UIControlStateNormal];
    } else {
        [self setBackgroundImage:[UIImage imageNamed:@"main_badge"] forState:UIControlStateNormal];
        [self setTitle:badgeValue forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateNormal];
    }
}

@end
