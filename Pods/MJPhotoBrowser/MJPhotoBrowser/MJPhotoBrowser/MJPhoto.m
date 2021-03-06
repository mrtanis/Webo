//
//  MJPhoto.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import "MJPhoto.h"
#import "FLAnimatedImage.h"

@implementation MJPhoto

#pragma mark 截图
- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)setSrcImageView:(FLAnimatedImageView *)srcImageView
{
    _srcImageView = srcImageView;
    _placeholder = srcImageView.animatedImage.posterImage;
    if (srcImageView.clipsToBounds) {
        _capture = [self capture:srcImageView];
    }
}

@end
