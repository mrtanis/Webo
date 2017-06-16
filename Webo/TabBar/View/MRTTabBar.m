//
//  MRTTabBar.m
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTabBar.h"
#import "MRTTabBarButton.h"

@interface MRTTabBar ()
@property (nonatomic, weak) UIButton *plusButton;
@property (nonatomic,strong) NSMutableArray *buttons;
@property (nonatomic,weak) UIButton *selectedButton;
@end

@implementation MRTTabBar
//懒加载buttons数组
- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [[NSMutableArray alloc] init];
    }
    return _buttons;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    //遍历模型数组，创建对应tabBarButton
    for (UITabBarItem *item in _items) {
        MRTTabBarButton *button = [MRTTabBarButton buttonWithType:UIButtonTypeCustom];
        
        //给自定义按钮赋值
        button.item = item;
        button.tag = self.buttons.count;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (button.tag == 0) {
            [self buttonClick:button];
        }
        [self addSubview:button];
        [self.buttons addObject:button];
    }
}

- (void)buttonClick:(UIButton *)button
{
    _selectedButton.selected = NO;
    button.selected = YES;
    _selectedButton = button;
    
    //通知MRTTabBarController切换视图控制器
    if ([_delegate respondsToSelector:@selector(tabBar:didClickButton:)]) {
        [_delegate tabBar:self didClickButton:button.tag];
    }
}

//添加➕号按钮，采用懒加载
- (UIButton *)plusButton
{
    if (_plusButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"tabbar_compose_icon_add"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"tabbar_copose_background_icon_add"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button_highlighted"] forState:UIControlStateHighlighted];
        //根据按钮的图片和文字调整按钮的合适尺寸，应该在将按钮加入父视图之前调用此方法
        [button sizeToFit];
        
        [button addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];
        
        _plusButton = button;
        
        [self addSubview:_plusButton];
    }
    
    return  _plusButton;
}

#pragma mark 点击➕号时调用
- (void)plusClick
{
    if ([_delegate respondsToSelector:@selector(tabBarDidClickPlusButton:)]) {
        [_delegate tabBarDidClickPlusButton:self];
    }
}

//覆盖layoutSubviews方法，设置各按钮位置
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat barWidth = self.bounds.size.width;
    CGFloat barHeight = 45;
    
    CGFloat btnWidth = barWidth / (self.items.count + 1);
    CGFloat btnHeight = barHeight;
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    int i = 0;
    for (UIView *tabBarButton in self.buttons) {
        
        if (i == 2) {
            i = 3;
        }
        btnX = i * btnWidth;
        tabBarButton.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
        i++;
  
    }
    //设置➕按钮的位置
    self.plusButton.center = CGPointMake(barWidth * 0.5, barHeight * 0.5);
}

    

@end
