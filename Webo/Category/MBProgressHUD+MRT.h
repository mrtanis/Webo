//
//  MBProgressHUD+MRT.h
//  Webo
//
//  Created by mrtanis on 2017/5/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (MRT)

+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message;
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showHUDToView:(UIView *)view;

+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;


@end
