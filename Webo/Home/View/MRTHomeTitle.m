//
//  MRTHomeTitle.m
//  Webo
//
//  Created by mrtanis on 2017/5/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTHomeTitle.h"
#import "UIView+MRTFrame.h"

@implementation MRTHomeTitle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //if (self.currentImage == nil) return;此语句不会起作用，会导致titleView不居中，点击后才居中
    if (self.imageView.x) return;
    
    NSLog(@"First titleLabel.x = %f, imageView.x = %f", self.titleLabel.x, self.imageView.x);
    //设置title位置
    self.titleLabel.x = self.imageView.x;//和采用self.titleLabel.x = 0;有什么区别？
    
    //设置image位置，在title右边
    self.imageView.x = CGRectGetMaxX(self.titleLabel.frame);
    NSLog(@"Second titleLabel.x = %f, imageView.x = %f", self.titleLabel.x, self.imageView.x);
}

//重写setTitle方法，扩展计算尺寸功能
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    //让按钮大小随文字调整
    [self sizeToFit];
    
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    //让按钮大小随图片调整
    [self sizeToFit];
}

@end
