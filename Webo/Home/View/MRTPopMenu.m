//
//  MRTPopMenu.m
//  Webo
//
//  Created by mrtanis on 2017/5/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTPopMenu.h"

@implementation MRTPopMenu

+ (instancetype)showInRect:(CGRect)rect
{
    MRTPopMenu *menu = [[MRTPopMenu alloc] initWithFrame:rect];
    menu.userInteractionEnabled = YES;
    menu.image = [UIImage imageWithStretchableName:@"popover_backround"];
    
    [MRTKeyWindow addSubview:menu];
    
    return menu;
}

//隐藏弹出菜单
+ (void)hide
{
    for (UIView *popMenu in MRTKeyWindow.subviews) {
        if ([popMenu isKindOfClass:self]) {
            [popMenu removeFromSuperview];
        }
    }
}

//设置内容视图
- (void)setContentView:(UIView *)contentView
{
    //先移除之前内容视图
    [_contentView removeFromSuperview];
    
    _contentView = contentView;
    contentView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:contentView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //计算内容视图尺寸
    CGFloat y = 9;
    CGFloat margin = 5;
    CGFloat x = margin;
    CGFloat width = self.width - 2 * margin;
    CGFloat height = self.height - y - margin;
    
    _contentView.frame = CGRectMake(x, y, width, height);
}

@end
