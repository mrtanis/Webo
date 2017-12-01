//
//  MRTCommentToolBar.m
//  Webo
//
//  Created by mrtanis on 2017/6/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentToolBar.h"

@interface MRTCommentToolBar()

@property (nonatomic, weak) UIButton *retweetBtn;
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *likeBtn;

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *divideViews;

@end

@implementation MRTCommentToolBar

//懒加载buttons数组
- (NSMutableArray *)buttons
{
    if (!_buttons) _buttons = [[NSMutableArray alloc] init];
    
    return _buttons;
}

//懒加载divideViews数组
- (NSMutableArray *)divideViews
{
    if (!_divideViews) _divideViews = [[NSMutableArray alloc] init];
    
    return _divideViews;
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
    }
    
    return self;
}

#pragma mark 设置子控件
- (void)setUpAllChildView
{
    //转发按钮
    UIButton *retweetBtn = [self addButtonWithTitle:@"转发" image:[UIImage imageNamed:@"timeline_icon_retweet"]];
    [retweetBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    retweetBtn.tag = 0;
    
    _retweetBtn = retweetBtn;
    
    //评论按钮
    UIButton *commentBtn = [self addButtonWithTitle:@"评论" image:[UIImage imageNamed:@"timeline_icon_comment"]];
    [commentBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    commentBtn.tag = 1;
    
    _commentBtn = commentBtn;
    
    //点赞按钮
    UIButton *likeBtn = [self addButtonWithTitle:@"赞" image:[UIImage imageNamed:@"timeline_icon_unlike"]];
    likeBtn.tag = 2;
    
    _likeBtn = likeBtn;
    
    //分割线图片
    for (int i = 0; i < 2; i++) {
        UIImageView *divideView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timeline_card_bottom_line"]];
        
        [self addSubview:divideView];
        
        [self.divideViews addObject:divideView];
    }
    
    
}

#pragma mark 根据图片和标题生成工具栏的按钮
- (UIButton *)addButtonWithTitle:(NSString* )title image:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = MRTStatusToolBarFont;
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    
    [self addSubview:button];
    
    [self.buttons addObject:button];
    
    return button;
}

#pragma mark 子控件布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = MRTScreen_Width / self.buttons.count;
    CGFloat y = 0;
    CGFloat width = MRTScreen_Width / self.buttons.count;
    CGFloat height = self.frame.size.height;
    
    for (int i = 0; i < self.buttons.count; i++) {
        //设置按钮的frame
        UIButton *button = self.buttons[i];
        button.frame = CGRectMake(x * i, y, width, height);
        
        //设置分割线视图的frame
        if (i > 0) {
            int m = i - 1;
            UIImageView *divideView = self.divideViews[m];
            divideView.x = button.x;
        }
    }
}

#pragma mark 点击按钮时触发
- (void)buttonClick:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(commentToolBar:didClickButton:)]) {
        [_delegate commentToolBar:self didClickButton:button.tag];
    }
}
@end
