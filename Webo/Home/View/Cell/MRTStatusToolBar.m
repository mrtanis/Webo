//
//  MRTStatusToolBar.m
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusToolBar.h"

@interface MRTStatusToolBar()

@property (nonatomic, weak) UIButton *retweetBtn;
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *likeBtn;

@property (nonatomic, copy) NSMutableArray *buttons;
@property (nonatomic, copy) NSMutableArray *divideViews;

@end

@implementation MRTStatusToolBar

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

- (void)setUpAllChildView
{
    //转发按钮
    UIButton *retweetBtn = [self addButtonWithTitle:@"转发" image:[UIImage imageNamed:@"timeline_icon_retweet"]];
    
    _retweetBtn = retweetBtn;
    
    //评论按钮
    UIButton *commentBtn = [self addButtonWithTitle:@"评论" image:[UIImage imageNamed:@"timeline_icon_comment"]];
    
    _commentBtn = commentBtn;
    
    //点赞按钮
    UIButton *likeBtn = [self addButtonWithTitle:@"点赞" image:[UIImage imageNamed:@"timeline_icon_unlike"]];
    
    _likeBtn = likeBtn;
    
    //分割线图片
    for (int i = 0; i < 2; i++) {
        UIImageView *divideView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timeline_card_bottom_line"]];
        
        [self addSubview:divideView];
        
        [self.divideViews addObject:divideView];
    }
    

}

//根据图片和标题生成工具栏的按钮
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = MRTScreen_Width / self.buttons.count;
    CGFloat y = 0;
    CGFloat width = MRTScreen_Width / self.buttons.count;
    CGFloat height = 35;
    
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

- (void)setStatusFrame:(MRTStatusFrame *)statusFrame
{
    _statusFrame = statusFrame;
    
    _retweetBtn.tag = 1;
    _commentBtn.tag = 2;
    _likeBtn.tag = 3;
    
    [self setButton:_retweetBtn withNumber:statusFrame.status.reposts_count];
    [self setButton:_commentBtn withNumber:statusFrame.status.comments_count];
    [self setButton:_likeBtn withNumber:statusFrame.status.attitudes_count];
    
}

//设置按钮标题
- (void)setButton:(UIButton *)button withNumber:(int)count
{
    
    NSString *title = nil;
    //数字超过10000显示为1.x万
    if (count > 10000) {
        CGFloat m = count / 10000.0;
        title = [NSString stringWithFormat:@"%.1f万", m];
        //1.0W显示为1W
        title = [title stringByReplacingOccurrencesOfString:@".0" withString:@""];
    } else if (count == 0) {//数字为零时显示相应文字标题
        
        switch (button.tag) {
            case 1:
                title = @"转发";
                break;
            case 2:
                title = @"评论";
                break;
            case 3:
                title = @"赞";
                break;
                
            default:
                break;
        }
    } else {
    
        title = [NSString stringWithFormat:@"%d", count];
    }
    
    [button setTitle:title forState:UIControlStateNormal];
}

@end
