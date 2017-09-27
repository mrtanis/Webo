//
//  MRTImageViewerCell.m
//  Webo
//
//  Created by mrtanis on 2017/9/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTImageViewerCell.h"

@interface MRTImageViewerCell () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation MRTImageViewerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.contentSize = self.bounds.size;
        //scrollView.backgroundColor = [UIColor orangeColor];
        scrollView.delegate = self;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //添加双击定点缩放方法手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapToZoom:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:doubleTap];
        imageView.userInteractionEnabled = YES;
        
        [scrollView addSubview:imageView];
        _imageView = imageView;
      
        [self.contentView addSubview:scrollView];
        _scrollView = scrollView;
    }
    
    return self;
}

- (void)setPhoto:(UIImage *)photo
{
    _photo = photo;
    
    
    CGFloat photoWidth = photo.size.width;
    CGFloat photoHeight = photo.size.height;
    
    CGFloat scale;
    CGFloat atLeastMaxScale;//保证放到最大时图片能填满scrollView
    if ((photoWidth / photoHeight) > (self.width / self.height)) {
        scale = photoWidth / self.width;
        atLeastMaxScale = self.height / photoHeight * scale; //"self.height / (photoHeight / scale)"
    } else {
        scale = photoHeight / self.height;
        atLeastMaxScale = self.width / photoWidth * scale;
    }
    
    CGRect imageFrame = _imageView.frame;
    imageFrame.size =CGSizeMake(photoWidth / scale, photoHeight / scale);
    _imageView.frame = imageFrame;
    _imageView.center = _scrollView.center;
    
    if (scale < 1) {//图片尺寸小于显示区域
        _scrollView.minimumZoomScale = scale;
        _scrollView.maximumZoomScale = atLeastMaxScale;
    } else if (scale >= 1 && scale <= 2){//图片至少有一边的尺寸超过了显示区域
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 2 > atLeastMaxScale ? 2 : atLeastMaxScale;
    } else if (scale > 2 && scale <= 4){//图片至少有一边的尺寸超过了显示区域
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = scale > atLeastMaxScale ? scale : atLeastMaxScale;
    } else {//图片至少有一边的尺寸超过了显示区域
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 4 > atLeastMaxScale ? 4 : atLeastMaxScale;
    }
    _imageView.image = photo;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)doubleTapToZoom:(UITapGestureRecognizer *)gesture
{
    NSLog(@"双击图片");
    
    CGRect zoomRect;
    CGFloat scale = _scrollView.zoomScale == 1 ? _scrollView.maximumZoomScale : 1;
    CGPoint center = [gesture locationInView:gesture.view];
    NSLog(@"center(%f, %f)", center.x, center.y);
    zoomRect.size.height = _scrollView.height / scale;
    zoomRect.size.width = _scrollView.width / scale;
    //zoomRect.size.height = 100;
    //zoomRect.size.width = 100;
    zoomRect.origin.x = center.x - (zoomRect.size.width * 0.5);
    zoomRect.origin.y = center.y - (zoomRect.size.height * 0.5);
    
    NSLog(@"zoomToRect:(%f, %f, %f, %f)", zoomRect.origin.x, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height);
    
    [_scrollView zoomToRect:zoomRect animated:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //NSLog(@"scrollView.bounds(%f, %f, %f, %f)", scrollView.bounds.origin.x,scrollView.bounds.origin.y,scrollView.bounds.size.width,scrollView.bounds.size.height);
    //NSLog(@"scrollView.contentSize(%f, %f)", scrollView.contentSize.width, scrollView.contentSize.height);
    NSLog(@"imageView.frame(%f, %f, %f, %f)", _imageView.x, _imageView.y, _imageView.width, _imageView.height);
    NSLog(@"maximumZoomScale:%f, minimumZoomScale:%f, currentScale:%f", scrollView.maximumZoomScale, scrollView.minimumZoomScale, scale);
    //NSLog(@"imageSize:(%f, %f)", _photo.size.width, _photo.size.height);
}

@end
