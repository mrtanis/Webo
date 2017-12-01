//
//  MRTCommentTitle.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentTitle.h"

@interface MRTCommentTitle ()
@property (nonatomic, weak) UIImageView *imageV;
@property (nonatomic, weak) UILabel *title;

@end

@implementation MRTCommentTitle

//指定初始化方法
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //添加图片
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 13;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        _imageV = imageView;
        
        //添加title
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.userInteractionEnabled = YES;
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        _title = titleLabel;
        
    }
    
    return  self;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    _title.font = titleFont;
    [_title sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //图片和文字间距
    CGFloat margin = 6;
    
    _imageV.frame = CGRectMake(0, 0, 26, 26);
    
    _title.center = CGPointMake(_imageV.width + margin + _title.width / 2.0, _imageV.height / 2.0);
}

        

@end
