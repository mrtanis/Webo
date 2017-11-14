//
//  MRTPhotoView.m
//  Webo
//
//  Created by mrtanis on 2017/10/10.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTPhotoView.h"

@interface MRTPhotoView()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *deselectButton;
@end
@implementation MRTPhotoView

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = image;
    [self addSubview:imageView];
    _imageView = imageView;
    
    UIButton *deselectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deselectButton setImage:[UIImage imageNamed:@"compose_photo_close"] forState:UIControlStateNormal];
    //deselectButton.frame = CGRectMake(self.width - 30, 0, 30, 30);
    deselectButton.imageEdgeInsets = UIEdgeInsetsMake(0, 13, 13, 0);
    [deselectButton addTarget:self action:@selector(deselectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deselectButton];
    _deselectButton = deselectButton;
}

- (void)deselectPhoto:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(deselectPhoto:)]) {
        [_delegate deselectPhoto:self];
    }
    [self removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    _deselectButton.frame = CGRectMake(self.width - 30, 0, 30, 30);
}

@end
