//
//  MRTMessageSwitchBar.m
//  Webo
//
//  Created by mrtanis on 2017/7/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageSwitchBar.h"

@interface MRTMessageSwitchBar()
@property (nonatomic, strong) NSMutableArray *widthOfButtons;
@property (nonatomic) float totalWidth;

@end

@implementation MRTMessageSwitchBar

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    
    return _buttons;
}

- (NSMutableArray *)widthOfButtons
{
    if(!_widthOfButtons) {
        _widthOfButtons = [NSMutableArray array];
    }
    
    return _widthOfButtons;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpButtons];
        [self setUpIndicatorBar];
    }
    
    return self;
}

#pragma mark 添加切换按钮
- (void)setUpButtons
{
    NSArray *buttonTitles = @[@"@我的微博", @"@我的评论", @"收到的评论", @"发出的评论"];
    
    int i = 0;
    _totalWidth = 0;
    for (NSString *title in buttonTitles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [button sizeToFit];
        NSNumber *width = [NSNumber numberWithFloat:button.frame.size.width];
        [self.widthOfButtons addObject:width];
        _totalWidth += button.frame.size.width;
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        button.tag = i;
        if (i == 0) button.selected = YES;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttons addObject:button];
        
        i++;
    }
    
    //计算button frame
    CGFloat space = (MRTScreen_Width - _totalWidth) / 4.0;
    CGFloat halfSpace = space / 2.0;
    for (UIButton *button in _buttons) {
        NSUInteger index = [_buttons indexOfObject:button];
        CGFloat x = halfSpace + (button.width + space) * index;
        CGFloat y = (self.height - button.height) / 2.0;
        
        button.frame = CGRectMake(x, y, button.width, button.height);
    }
}

#pragma mark 添加指示条
- (void)setUpIndicatorBar
{
    UIButton *button = _buttons[0];
    
    UIView *indicatorBar = [[UIView alloc] initWithFrame:CGRectMake(button.x, self.height - 5, button.width, 4)];
    indicatorBar.backgroundColor = [UIColor orangeColor];
    indicatorBar.layer.cornerRadius = 2;
    indicatorBar.clipsToBounds = YES;
    
    [self addSubview:indicatorBar];
    _indicatorBar = indicatorBar;
 
}

#pragma mark 点击按钮时执行
- (void)buttonClick:(UIButton *)button
{
    button.selected = YES;
    for (UIButton *otherButton in _buttons) {
        if (otherButton.tag != button.tag) {
            otherButton.selected = NO;
        }
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _indicatorBar.frame = CGRectMake(button.x, self.height - 10, button.width, 4);
    }];
    
    if ([_delegate respondsToSelector:@selector(switchBar:didClickButton:)]) {
        [_delegate switchBar:self didClickButton:button.tag];
    }
}

@end
