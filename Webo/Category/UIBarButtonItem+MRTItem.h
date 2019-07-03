//
//  UIBarButtonItem+MRTItem.h
//  Webo
//
//  Created by mrtanis on 2017/5/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (MRTItem)

//封装自定义UIBarButtonItem
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highLightedImage:(UIImage *)highLightedImage target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
