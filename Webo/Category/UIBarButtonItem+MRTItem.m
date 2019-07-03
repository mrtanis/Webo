//
//  UIBarButtonItem+MRTItem.m
//  Webo
//
//  Created by mrtanis on 2017/5/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "UIBarButtonItem+MRTItem.h"

@implementation UIBarButtonItem (MRTItem)

//封装自定义UIBarButtonItem
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highLightedImage:(UIImage *)highLightedImage target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    //设置按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highLightedImage forState:UIControlStateHighlighted];
    [button sizeToFit];
    
    [button addTarget:target action:action forControlEvents:controlEvents];
    
    //通过自定义button生成UIBarButtonItem
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
