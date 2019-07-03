//
//  MRTPlusClickViewButton.m
//  Webo
//
//  Created by mrtanis on 2017/6/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTPlusClickViewButton.h"

@interface MRTPlusClickViewButton ()

@property (nonatomic, weak) UIImageView *imageV;
@property (nonatomic, weak) UILabel *title;

@end

@implementation MRTPlusClickViewButton

//指定初始化方法
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        //添加图片
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.layer.cornerRadius = 30;
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        _imageV = imageView;
        
        //添加title
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.userInteractionEnabled = YES;
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        _title = titleLabel;
    }
    
    return  self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageV.frame = CGRectMake(0, 0, 60, 60);
    
    _title.center = CGPointMake(30, 75);
}

@end
