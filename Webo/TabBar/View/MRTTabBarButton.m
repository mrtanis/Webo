//
//  MRTTabBarButton.m
//  Webo
//
//  Created by mrtanis on 2017/5/8.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTabBarButton.h"
#import "MRTBadgeView.h"
#import "UIView+MRTFrame.h"

#define MRTImageRatio 0.7

@interface MRTTabBarButton ()
@property (nonatomic,weak) MRTBadgeView *badgeView;
@end

@implementation MRTTabBarButton
//懒加载badgeView
- (MRTBadgeView *)badgeView
{
    if (!_badgeView) {
        MRTBadgeView *badgeButton = [MRTBadgeView buttonWithType:UIButtonTypeCustom];
        [self addSubview:badgeButton];
        _badgeView = badgeButton;
    }
    
    return _badgeView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //设置字体颜色
        [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateSelected];
        //设置文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        //设置字体
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        //设置图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //设置图片
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageWidth = self.bounds.size.width;
    CGFloat imageHeight = self.bounds.size.height * MRTImageRatio;
    self.imageView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight);
    
    //设置标题
    CGFloat titleX = 0;
    CGFloat titleY = imageHeight - 5;
    CGFloat titleWidth = self.bounds.size.width;
    CGFloat titleHeight = self.bounds.size.height - titleY;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleWidth, titleHeight);
    
    //设置角标
    self.badgeView.x = self.width - self.badgeView.width - 15;
    self.badgeView.y = 0;
}

- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    //利用KVO监听对象属性有无改变
    //还要注意在销毁对象时删除观察者
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
    
    [item addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew context:nil];
}

//实现KVO回调方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self setTitle:_item.title forState:UIControlStateNormal];
    [self setImage:_item.image forState:UIControlStateNormal];
    [self setImage:_item.selectedImage forState:UIControlStateSelected];
    
    self.badgeView.badgeValue = _item.badgeValue;
}

@end
