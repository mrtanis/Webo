//
//  MRTPlusButtonClickView.m
//  Webo
//
//  Created by mrtanis on 2017/6/8.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTPlusButtonClickView.h"
#import "MRTPlusClickViewButton.h"

@interface MRTPlusButtonClickView () <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollview;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, weak) UIButton *textButton;

@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation MRTPlusButtonClickView

//懒加载buttons数组
- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    
    return _buttons;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //添加子控件
        [self setUpAllChildView];
        
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToClose:)];
        
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

# pragma mark设置子控件
- (void)setUpAllChildView
{
    //首先添加高斯模糊
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithFrame:self.frame];
    blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [self addSubview:blurView];
    
    //然后创建一个UIScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, MRTScreen_Height * 0.5, MRTScreen_Width, MRTScreen_Height * 0.5 - 45)];
    //设置内容尺寸
    scrollView.contentSize = CGSizeMake(MRTScreen_Width * 2, MRTScreen_Height * 0.5 - 45);
    //设置分页
    scrollView.pagingEnabled = YES;
    //禁止回弹
    scrollView.bounces = NO;
    //隐藏横向指示条
    scrollView.showsHorizontalScrollIndicator = NO;
    
    //为scrollView添加按钮
    [self addButtonsToScrollView:scrollView];
    
    //设置scrollView的代理
    scrollView.delegate = self;
    
    [blurView.contentView addSubview:scrollView];
    _scrollview = scrollView;
    
    //添加pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = (scrollView.contentSize.width / MRTScreen_Width);
    pageControl.center = CGPointMake(MRTScreen_Width / 2, CGRectGetMaxY(scrollView.frame) - 10);
    [self addSubview:pageControl];
    _pageControl = pageControl;
    
}

# pragma mark 添加功能按钮
- (void)addButtonsToScrollView:(UIScrollView *)scrollView
{
    //文字
    //MRTPlusClickViewButton *textButton = [[MRTPlusClickViewButton alloc] initWithImage:[UIImage imageNamed:@"tabbar_compose_idea_neo"] title:@"文字"];
    UIButton *textButton = [UIButton buttonWithType:UIButtonTypeCustom];

    //添加图片
    [textButton setImage:[UIImage imageNamed:@"tabbar_compose_idea_neo"] forState:UIControlStateNormal];
    
    //添加文字标题
    [textButton setTitle:@"文字" forState:UIControlStateNormal];
    textButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [textButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [textButton.titleLabel sizeToFit];
    
    //设置左上对齐方便计算insets
    textButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    textButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    //设置insets使图片和文字处于想要的位置
    textButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 30, 0);
    textButton.titleEdgeInsets = UIEdgeInsetsMake(70, (60 - textButton.titleLabel.frame.size.width) / 2.0 - 60, 0, (60 - textButton.titleLabel.frame.size.width) / 2.0);
    
    [textButton addTarget:self action:@selector(ClickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //为按钮设置标签，方便tabBar控制器判断是点击的哪个按钮并创建对应的视图控制器
    textButton.tag = 1;
    //加入buttons数组
    [self.buttons addObject:textButton];
    
    [scrollView addSubview:textButton];
    _textButton = textButton;
}

# pragma mark 点击按钮时执行方法
- (void)ClickButton:(UIButton *)button
{
    NSLog(@"点击文字按钮");
    if ([_delegate respondsToSelector:@selector(plusViewDidClickButton:)]) {
        [_delegate plusViewDidClickButton:button.tag];
    }
}

- (void)tapToClose:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.textButton.frame = CGRectMake(30, MRTScreen_Height * 0.5, 60, 90);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

# pragma mark layoutSubViews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    
    self.textButton.frame = CGRectMake(30, MRTScreen_Height * 0.5, 60, 90);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        int i = 0;
        int cols = 4;
        CGFloat gap = (MRTScreen_Width - 60 * 5) / 3.0;
        CGFloat x = 30;
        CGFloat y = 0;
        CGFloat width = 60;
        CGFloat height = 90;
        for (UIButton *button in self.buttons) {
            if (i < 8) {
                x = 30 + (i % cols) * (width + gap);
                y = (i / cols) * (height + gap);
            } else {
                int m = i - 8;
                x = MRTScreen_Width + 30 + (m % cols) * (width + gap);
                y = (m / cols) * (height + gap);
            }
            button.frame = CGRectMake(x, y, width, height);
            i ++;
        }

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.textButton.frame = CGRectMake(30, 30, 60, 90);
        }];

    }];
    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //计算页码
    int page = scrollView.contentOffset.x / MRTScreen_Width + 0.5;
    self.pageControl.currentPage = page;
}
@end
