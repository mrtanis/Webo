//
//  MRTTabBarController.m
//  Webo
//
//  Created by mrtanis on 2017/5/6.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTabBarController.h"
#import "MRTTabBar.h"
#import "UIImage+MRTImage.h"
#import "MRTHomeViewController.h"
#import "MRTMessageViewController.h"
#import "MRTDiscoverViewController.h"
#import "MRTProfileViewController.h"

@interface MRTTabBarController ()

@end

@implementation MRTTabBarController

+ (void)initialize
{
    //获取当前类下所有的tabBarItem
    UITabBarItem *item = [UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[[self class]]];
    //新建富文本字典
    NSMutableDictionary *tta = [NSMutableDictionary dictionary];
    //设置文本颜色（还可以设置字体、阴影、阴影颜色等)
    tta[NSForegroundColorAttributeName] = [UIColor orangeColor];
    //通过富文本设置选中状态下文字颜色
    [item setTitleTextAttributes:tta forState:UIControlStateSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //建立子控制器
    [self setUpAllChildVC];
    
    //使用自定义tabBar
    MRTTabBar *tabBar = [[MRTTabBar alloc] initWithFrame:self.tabBar.frame];
    
    //利用KVC设置tabBar(KVC能在没有存取方法的情况下直接存取实例变量，只对对象有效）
    [self setValue:tabBar forKey:@"tabBar"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpAllChildVC
{
    //添加首页
    MRTHomeViewController *homeVC = [[MRTHomeViewController alloc] init];
    [self setUpOneChildVC:homeVC image:[UIImage imageNamed:@"tabbar_home"] selectedImage:[UIImage imageNamed:@"tabbar_home_selected"] title:@"首页"];
    
    //添加信息页
    MRTMessageViewController *messageVC = [[MRTMessageViewController alloc] init];
    [self setUpOneChildVC:messageVC image:[UIImage imageNamed:@"tabbar_message_center"] selectedImage:[UIImage imageNamed:@"tabbar_message_center_selected"] title:@"消息"];
    
    //添加发现页
    MRTDiscoverViewController *discoverVC = [[MRTDiscoverViewController alloc] init];
    [self setUpOneChildVC:discoverVC image:[UIImage imageNamed:@"tabbar_discover"] selectedImage:[UIImage imageNamed:@"tabbar_discover_selected"] title:@"发现"];
    
    //添加个人页面
    MRTProfileViewController *profileVC = [[MRTProfileViewController alloc] init];
    [self setUpOneChildVC:profileVC image:[UIImage imageNamed:@"tabbar_profile"] selectedImage:[UIImage imageNamed:@"tabbar_profile_selected"] title:@"我"];
}

- (void)setUpOneChildVC:(UIViewController *)vc image:(UIImage *)image selectedImage:(UIImage *)selctedImage title:(NSString *)title
{
    vc.tabBarItem.image = image;
    vc.tabBarItem.selectedImage = selctedImage;
    vc.tabBarItem.title = title;
    vc.tabBarItem.badgeValue = @"10";
    
    [self addChildViewController:vc];
}


@end
