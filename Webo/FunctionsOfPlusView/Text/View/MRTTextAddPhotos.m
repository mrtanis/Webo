//
//  MRTTextAddPhotos.m
//  Webo
//
//  Created by mrtanis on 2017/6/15.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextAddPhotos.h"
#import "MRTPhotoView.h"

@interface MRTTextAddPhotos() <MRTPhotoViewDelegate>
@end

@implementation MRTTextAddPhotos


- (void)setImages:(NSMutableArray *)images
{
    NSLog(@"setImages");
    _images = images;
    NSLog(@"图片张数：%ld", _images.count);
    for (int i = 0; i < self.images.count; i++) {
        MRTPhotoView *imageView = [[MRTPhotoView alloc] init];
        imageView.image = self.images[i];
        imageView.delegate = self;
        imageView.tag = i;
        [self addSubview:imageView];
    }
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

- (void)deselectPhotoAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(deselectPhotoAtIndex:)]) {
        [_delegate deselectPhotoAtIndex:index];
    }
}

@end
