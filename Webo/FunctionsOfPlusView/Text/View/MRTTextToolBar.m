//
//  MRTTextToolBar.m
//  Webo
//
//  Created by mrtanis on 2017/6/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextToolBar.h"

@implementation MRTTextToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //添加子控件
        [self setUpAllChildView];
    }
    
    return self;
}

#pragma mark 添加子控件
- (void)setUpAllChildView
{
    //相册
    [self setUpButtonWithImage:[UIImage imageNamed:@"compose_toolbar_picture"] highlightedImage:[UIImage imageNamed:@"compose_toolbar_picture_highlighted"] target:self action:@selector(buttonClick:)];
    //@
    [self setUpButtonWithImage:[UIImage imageNamed:@"compose_mentionbutton_background"] highlightedImage:[UIImage imageNamed:@"compose_mentionbutton_background_highlighted"] target:self action:@selector(buttonClick:)];
    //话题
    [self setUpButtonWithImage:[UIImage imageNamed:@"compose_trendbutton_background"] highlightedImage:[UIImage imageNamed:@"compose_trendbutton_background_highlighted"] target:self action:@selector(buttonClick:)];
    //表情
    [self setUpButtonWithImage:[UIImage imageNamed:@"compose_emoticonbutton_background"] highlightedImage:[UIImage imageNamed:@"compose_emoticonbutton_background_highlighted"] target:self action:@selector(buttonClick:)];
    //键盘
    [self setUpButtonWithImage:[UIImage imageNamed:@"compose_keyboardbutton_background"] highlightedImage:[UIImage imageNamed:@"compose_keyboardbutton_background_highlighted"] target:self action:@selector(buttonClick:)];
}

- (void)setUpButtonWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    button.tag = self.subviews.count;
    
    [self addSubview:button];
}

-(void)buttonClick:(UIButton *)button
{
    //点击工具栏上的按钮时
    if ([_delegate respondsToSelector:@selector(textToolBar:didClickButton:)]) {
        [_delegate textToolBar:self didClickButton:button.tag];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSUInteger count = self.subviews.count;
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.width / count;
    CGFloat height = self.height;
    
    for (int i = 0; i < count; i++) {
        UIButton *button = self.subviews[i];
        x = i * width;
        button.frame = CGRectMake(x, y, width, height);
    }
}

@end
