//
//  UIImage+MRTImage.h
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MRTImage)

+ (instancetype)imageWithOriginalName:(NSString *)imageName;
+ (instancetype)imageWithStretchableName:(NSString *)imageName;
+ (UIImage *)getImageFromURL:(NSURL *)url;
@end
