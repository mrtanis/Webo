//
//  MRTTextAddPhotos.m
//  Webo
//
//  Created by mrtanis on 2017/6/15.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextAddPhotos.h"

@implementation MRTTextAddPhotos

- (void)setImage:(UIImage *)image
{
    _image = image;
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    
    [self addSubview:imageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int cols = 3;
    int col = 0;
    int row = 0;
    CGFloat margin = 5;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width_Height = (MRTScreen_Width - margin * (cols - 1) - 20) / cols;
    
    for (int i = 0; i < self.subviews.count; i++) {
        col = i % cols;
        row = i / cols;
        x = (margin + width_Height) * col;
        y = (margin + width_Height) * row;
        CGRect rect = CGRectMake(x, y, width_Height, width_Height);
        UIImageView *imageView = self.subviews[i];
        imageView.frame = rect;
    }
}

@end
