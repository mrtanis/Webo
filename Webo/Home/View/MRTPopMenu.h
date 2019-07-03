//
//  MRTPopMenu.h
//  Webo
//
//  Created by mrtanis on 2017/5/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTPopMenu : UIImageView

//内容视图
@property (nonatomic, weak) UIView *contentView;

//显示弹出菜单
+ (instancetype)showInRect:(CGRect)rect;

//隐藏弹出菜单
+ (void)hide;

@end
