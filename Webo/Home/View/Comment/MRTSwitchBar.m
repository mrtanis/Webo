//
//  MRTSwitchBar.m
//  Webo
//
//  Created by mrtanis on 2017/6/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTSwitchBar.h"

@interface MRTSwitchBar()

@end

@implementation MRTSwitchBar

//懒加载buttons数组
- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    
    return _buttons;
}

#pragma mark 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //添加子控件
        [self setUpAllChildView];
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageWithStretchableName:@"timeline_card_bottom_background"];
        //self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

#pragma mark 设置子控件
- (void)setUpAllChildView
{
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            [button setTitle:@"转发" forState:UIControlStateNormal];
            _retweetBtn = button;
        }
        if (i == 1) {
            [button setTitle:@"评论" forState:UIControlStateNormal];
            _commentBtn = button;
        }
        if (i == 2) {
            [button setTitle:@"赞" forState:UIControlStateNormal];
            _likeBtn = button;
        }
        
        [button sizeToFit];
        [self.buttons addObject:button];
        [self addSubview:button];
        
    }
}

#pragma mark 设置转发评论数
- (void)setTitleWithReposts:(int)repostsCount comments:(int)commentsCount attitudes:(int)attitudesCount
{
    
    NSString *repostsStr = nil;
    if (repostsCount >= 10000) {
        repostsCount = repostsCount / 10000;
        repostsStr = [NSString stringWithFormat:@"转发 %d万", repostsCount];
    } else {
        repostsStr = [NSString stringWithFormat:@"转发 %d", repostsCount];
    }
    [_retweetBtn setTitle:repostsStr forState:UIControlStateNormal];
    [_retweetBtn sizeToFit];
    
    NSString *commentsStr = nil;
    if (commentsCount >= 10000) {
        commentsCount = commentsCount / 10000;
        commentsStr = [NSString stringWithFormat:@"评论 %d万", commentsCount];
    } else {
        commentsStr = [NSString stringWithFormat:@"评论 %d", commentsCount];
    }
    [_commentBtn setTitle:commentsStr forState:UIControlStateNormal];
    [_commentBtn sizeToFit];
    
    NSString *attitudesStr = nil;
    if (attitudesCount >= 10000) {
        attitudesCount = attitudesCount / 10000;
        attitudesStr = [NSString stringWithFormat:@"赞 %d万", attitudesCount];
    } else {
        attitudesStr = [NSString stringWithFormat:@"赞 %d", attitudesCount];
    }
    [_likeBtn setTitle:attitudesStr forState:UIControlStateNormal];
    [_likeBtn sizeToFit];
}

#pragma mark 点击按钮时执行
- (void)buttonClick:(UIButton *)button
{
    //button.selected = YES;
    
        if ([_delegate respondsToSelector:@selector(switchBar:didClickButton:)]) {
            [_delegate switchBar:self didClickButton:button.tag];
        }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.retweetBtn.frame = CGRectMake(MRTStatusCellMargin, (self.height - _retweetBtn.height) / 2.0, _retweetBtn.width, _retweetBtn.height);
    
    self.commentBtn.frame = CGRectMake(100, _retweetBtn.y, _commentBtn.width, _commentBtn.height);
    
    self.likeBtn.frame = CGRectMake(290, _retweetBtn.y, _likeBtn.width, _likeBtn.height);
}
@end
