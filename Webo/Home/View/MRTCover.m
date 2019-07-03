//
//  MRTCover.m
//  Webo
//
//  Created by mrtanis on 2017/5/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCover.h"

@implementation MRTCover

+ (instancetype)show
{
    MRTCover *cover = [[MRTCover alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.backgroundColor = [UIColor clearColor];
    
    [MRTKeyWindow addSubview:cover];
    
    return cover;
}

//点击蒙板调用方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //移除蒙板
    [self removeFromSuperview];
    
    //通知代理移除菜单
    if ([_delegate respondsToSelector:@selector(coverDidClick:)]) {
        [_delegate coverDidClick:self];
    }
}
@end
