//
//  MRTCommentPopMenu.m
//  Webo
//
//  Created by mrtanis on 2017/8/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentPopMenu.h"


#define MRTLineColor [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7]
@interface MRTCommentPopMenu ()
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *retweetBtn;
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, weak) UILabel *commentTextLabel;
@property (nonatomic, weak) UIVisualEffectView *blurView;
@property (nonatomic, copy) NSString *text;

@property (nonatomic, weak) UIView *line1;
@property (nonatomic, weak) UIView *line2;
@property (nonatomic, weak) UIView *line3;

@end
@implementation MRTCommentPopMenu

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _text = text;
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        [self setUpChildViews];
    }
    
    return self;
}


- (void)setUpChildViews
{
    //设置模糊
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    //blurView.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    [self addSubview:blurView];
    _blurView = blurView;
    
    if (self.text) {
        UILabel *commentTextLabel = [[UILabel alloc] init];
        NSLog(@"开始设置commentTextLabel");
        commentTextLabel.backgroundColor = [UIColor clearColor];
        commentTextLabel.numberOfLines = 2;
        commentTextLabel.text = self.text;
        commentTextLabel.textAlignment = NSTextAlignmentCenter;
        commentTextLabel.font = [UIFont systemFontOfSize:14];
        commentTextLabel.textColor = [UIColor grayColor];
        [blurView.contentView addSubview:commentTextLabel];
        _commentTextLabel = commentTextLabel;
        
        //分割线
        UIView *line1 = [UIView new];
        line1.backgroundColor = MRTLineColor;
        [blurView.contentView addSubview:line1];
        _line1 = line1;
    }
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //commentBtn.backgroundColor = [UIColor whiteColor];
    [commentBtn setTitle:@"回复" forState:UIControlStateNormal];
    [commentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    commentBtn.tag = 0;
    [commentBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [blurView.contentView addSubview:commentBtn];
    _commentBtn = commentBtn;
    
    //分割线
    UIView *line2 = [UIView new];
    line2.backgroundColor = MRTLineColor;
    [blurView.contentView addSubview:line2];
    _line2 = line2;
    
    UIButton *retweetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //retweetBtn.backgroundColor = [UIColor whiteColor];
    [retweetBtn setTitle:@"转发" forState:UIControlStateNormal];
    [retweetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    retweetBtn.tag = 1;
    [retweetBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [blurView.contentView addSubview:retweetBtn];
    _retweetBtn = retweetBtn;
    
    //分割线
    UIView *line3 = [UIView new];
    line3.backgroundColor = MRTLineColor;
    [blurView.contentView addSubview:line3];
    _line3 = line3;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.tag = 2;
    [cancelBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [blurView.contentView addSubview:cancelBtn];
    _cancelBtn = cancelBtn;
}

- (void)buttonClick:(UIButton *)button
{
    
        if ([_delegate respondsToSelector:@selector(popMenuDidClickButton:)]) {
            [_delegate popMenuDidClickButton:button.tag];
        }
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    if (self.text) {
        _blurView.frame = self.bounds;
        _commentTextLabel.frame = CGRectMake(MRTStatusCellMargin, MRTStatusCellMargin, MRTScreen_Width - 20, 60);
        NSLog(@"commentTextLabel.frame(%f, %f, %f, %f)", _commentTextLabel.x, _commentTextLabel.y, _commentTextLabel.width, _commentTextLabel.height);
        _line1.frame = CGRectMake(0, CGRectGetMaxY(_commentTextLabel.frame) + MRTStatusCellMargin, MRTScreen_Width, 1);
        _commentBtn.frame = CGRectMake(0, CGRectGetMaxY(_line1.frame), MRTScreen_Width, 50);
        _line2.frame = CGRectMake(0, CGRectGetMaxY(_commentBtn.frame), MRTScreen_Width, 1);
        _retweetBtn.frame = CGRectMake(0, CGRectGetMaxY(_line2.frame), MRTScreen_Width, 50);
        _line3.frame = CGRectMake(0, CGRectGetMaxY(_retweetBtn.frame), MRTScreen_Width, 4);
        _cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(_line3.frame), MRTScreen_Width, 50);

    } else {
        _blurView.frame = self.bounds;
        _commentBtn.frame = CGRectMake(0, 0, MRTScreen_Width, 50);
        _line2.frame = CGRectMake(0, CGRectGetMaxY(_commentBtn.frame), MRTScreen_Width, 1);
        _retweetBtn.frame = CGRectMake(0, CGRectGetMaxY(_line2.frame), MRTScreen_Width, 50);
        _line3.frame = CGRectMake(0, CGRectGetMaxY(_retweetBtn.frame), MRTScreen_Width, 4);
        _cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(_line3.frame), MRTScreen_Width, 50);
       
    }
    
    
}


@end
