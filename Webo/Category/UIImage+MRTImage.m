//
//  UIImage+MRTImage.m
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "UIImage+MRTImage.h"

@implementation UIImage (MRTImage)

//返回原始图片
+ (instancetype)imageWithOriginalName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (instancetype)imageWithStretchableName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    //只拉伸中间图片
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)getImageFromURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}


@end
