//
//  MRTPictureWithTag.m
//  Webo
//
//  Created by mrtanis on 2017/6/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTPictureWithTag.h"
#import "UIImageView+WebCache.h"

@interface MRTPictureWithTag()

@property (nonatomic, weak) UIImageView *gifTag;

@end

@implementation MRTPictureWithTag

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //设置可交互
        self.userInteractionEnabled = YES;
        //设置图片显示方式
        self.contentMode = UIViewContentModeScaleAspectFill;
        //裁剪图片，超出部分裁减掉
        self.clipsToBounds = YES;
        
        UIImageView *gifTag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_image_gif"]];
        [self addSubview:gifTag];
        _gifTag = gifTag;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.gifTag.x = self.width - self.gifTag.width;
    self.gifTag.y = self.height - self.gifTag.height;
}

- (void)setPicture:(MRTPicture *)picture
{
    _picture = picture;
    
    //赋值
    //赋值
    //先将缩略图地址转换为中等尺寸地址
    NSString *midPic = [picture.thumbnail_pic.absoluteString stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    
    [self sd_setImageWithURL:[NSURL URLWithString:midPic] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    if ([midPic hasSuffix:@".gif"]) {
        self.gifTag.hidden = NO;
    } else {
        self.gifTag.hidden = YES;
    }
}
@end
