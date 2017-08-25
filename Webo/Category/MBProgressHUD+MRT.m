//
//  MBProgressHUD+MRT.m
//  Webo
//
//  Created by mrtanis on 2017/5/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MBProgressHUD+MRT.h"

@implementation MBProgressHUD (MRT)

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    //快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    //设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    //设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    //隐藏时从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    //0.7秒后再消失
    [hud hideAnimated:YES afterDelay:0.7];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    //快速显示提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    //隐藏时从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    //开启蒙板效果
    hud.backgroundView.style = MBProgressHUDBackgroundStyleBlur;
    
    return hud;
}

+ (MBProgressHUD *)showHUDToView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    //仅仅显示菊花
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];

    //隐藏时从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    //修改为圆环模式
    //hud.mode = MBProgressHUDModeAnnularDeterminate;
    
    //先将背景框改为solid才能直接改未加模糊的背景框颜色
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    //改变背景框颜色
    hud.bezelView.color = [UIColor clearColor];
    //改变动画颜色
    hud.contentColor = [UIColor orangeColor];
    
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

+ (void)showError:(NSString *)error toView:(UIView *)view
{
    [self show:error icon:@"error.png" view:view];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
}

@end
