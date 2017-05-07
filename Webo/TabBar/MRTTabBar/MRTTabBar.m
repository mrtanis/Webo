//
//  MRTTabBar.m
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTabBar.h"

@interface MRTTabBar ()
@property (nonatomic, weak) UIButton *plusButton;
@end

@implementation MRTTabBar

//添加➕号按钮
- (UIButton *)plusButton
{
    if (!self.plusButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"tabbar_compose_icon_add"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"tabbar_copose_background_icon_add"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button_highlighted"] forState:UIControlStateHighlighted];
        //根据按钮的图片和文字调整按钮的合适尺寸，应该在将按钮加入父视图之前调用此方法
        [button sizeToFit];
        
        self.plusButton = button;
        
        [self addSubview:self.plusButton];
    }
    
    return  self.plusButton;
}

//覆盖layoutSubviews方法，设置各按钮位置
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat barWidth = self.bounds.size.width;
    CGFloat barHeight = self.bounds.size.height;
    
    CGFloat btnWidth = barWidth / (self.items.count + 1);
    CGFloat btnHeight = barHeight;
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    int i = 0;
    for (UIView *tabBarButton in self.subviews) {
        //判断是否为UITabBarButton（UITabBarButton是UITabBarController中各个子控制器在工具条中对应的按钮的称呼，可通过打印self.tabbar.subViews查看）
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (i == 2) {
                i = 3;
            }
            btnX = i * btnWidth;
            tabBarButton.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
            i++;
        }
    }
    //设置➕按钮的位置
    self.plusButton.center = CGPointMake(barWidth * 0.5, barHeight * 0.5);
}

    

@end
