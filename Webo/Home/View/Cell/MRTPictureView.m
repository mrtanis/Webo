//
//  MRTPictureView.m
//  Webo
//
//  Created by mrtanis on 2017/6/5.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTPictureView.h"
#import "MRTPicture.h"
#import "UIImageView+WebCache.h"
#import "MJPhotoBrowser.h"
#import "MRTPictureWithTag.h"

@implementation MRTPictureView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpAllChildView];
    }
    
    return self;
}

- (void)setUpAllChildView
{
    for (int i = 0; i < 9; i++) {
        MRTPictureWithTag *imageView = [[MRTPictureWithTag alloc] init];
        
        imageView.tag = i;
        //设置可交互
        //imageView.userInteractionEnabled = YES;
        //设置图片显示方式
        //imageView.contentMode = UIViewContentModeScaleAspectFill;
        //裁剪图片，超出部分裁减掉
        //imageView.clipsToBounds = YES;
        //添加点按手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        
        [imageView addGestureRecognizer:tap];
        
        [self addSubview:imageView];
    }
}

#pragma mark 点击图片
- (void)tap:(UITapGestureRecognizer *)tap
{
    UIImageView *tapView = (UIImageView *)tap.view;
    //转化为MJPhoto
    int i = 0;
    NSMutableArray *MJPhotos = [NSMutableArray array];
    for (MRTPicture *picture in _pic_urls) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        NSString *urlStr = picture.thumbnail_pic.absoluteString;
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
        photo.url = [NSURL URLWithString:urlStr];
        photo.index = i;
        photo.srcImageView = tapView;
        [MJPhotos addObject:photo];
        i++;
    }
    
    //创建图片浏览器
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    
    browser.photos = MJPhotos;
    browser.currentPhotoIndex = tapView.tag;
    [browser show];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = (MRTScreen_Width - MRTStatusCellMargin * 3) / 3.0;
    CGFloat height = (MRTScreen_Width - MRTStatusCellMargin * 3) / 3.0;
    if (_pic_urls.count == 1) {
        width = self.onePicSize.width;
        height = self.onePicSize.height;
    }
    
    
    int col = 0;
    int row = 0;
    int cols = _pic_urls.count == 4 ? 2 : 3;
    for (int i = 0; i < _pic_urls.count; i++) {
        col = i % cols;
        row = i / cols;
        UIImageView *imageView = self.subviews[i];
        x = col * (width + 5);
        y = row * (height + 5);
        imageView.frame = CGRectMake(x, y, width, height);
    }
}

- (void)setPic_urls:(NSArray *)pic_urls
{
    _pic_urls = pic_urls;
    int count = (int)self.subviews.count;
    for (int i = 0; i < count; i++) {
        MRTPictureWithTag *imageView = self.subviews[i];
        
        if (i < _pic_urls.count) {
            imageView.hidden = NO;
            
            //赋值
            imageView.picture = _pic_urls[i];
            
        } else {
            imageView.hidden = YES;
        }
    }
}

@end
