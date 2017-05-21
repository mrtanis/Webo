//
//  MRTRootVCPicker.m
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRootVCPicker.h"
#import "MRTAccountStore.h"
#import "MRTTabBarController.h"
#import "MRTNewFeatureController.h"
#import "MRTOAuthViewController.h"

@implementation MRTRootVCPicker

+ (void)chooseRootVC:(UIWindow *)keyWindow
{
    if ([MRTAccountStore account]) {
        //获取当前版本号
        NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
        //获取上个版本号
        NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"WeboVersion"];
        
        //判断当前版本是否为新版本，如果为新版本则进入新特性介绍界面，否则直接进入tabBarController
        if ([currentVersion isEqualToString:lastVersion]) {
            MRTTabBarController *tabBarVc = [[MRTTabBarController alloc] init];
            
            keyWindow.rootViewController = tabBarVc;
        } else {
            MRTNewFeatureController *newFeatureVc = [[MRTNewFeatureController alloc] init];
            
            //若为新版本则保存最新版本号
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"WeboVersion"];
            
            keyWindow.rootViewController = newFeatureVc;
        }
    } else {
        //进入授权界面
        MRTOAuthViewController *oauthVC = [[MRTOAuthViewController alloc] init];
        
        keyWindow.rootViewController = oauthVC;
    }
}

    
        

@end
