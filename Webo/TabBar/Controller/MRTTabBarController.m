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
#import "MRTNavigationController.h"

@interface MRTTabBarController () <MRTTabBarDelegate>//遵守MRTTabBar代理协议
@property (nonatomic, copy) NSMutableArray *items;
@end

@implementation MRTTabBarController
/*由于采用完全自定义tabBar（包括badgeView，tabBarButton），所以不需要通过富文本设置文本颜色
 
//Initializes the class before it receives its first message
+ (void)initialize
{
    //获取当前类下所有的tabBarItem
    UITabBarItem *item = [UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[self]];
    //新建富文本字典
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionary];
    //设置文本颜色（还可以设置字体、阴影、阴影颜色等)
    titleAttrs[NSForegroundColorAttributeName] = [UIColor orangeColor];
    //通过富文本设置选中状态下文字颜色
    [item setTitleTextAttributes:titleAttrs forState:UIControlStateSelected];
}
 */

//懒加载items
- (NSMutableArray *)items
{
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    
    return _items;
}

- (void)setUpTabBar
{
    //自定义tabBar
    //MRTTabBar *tabBar = [[MRTTabBar alloc] initWithFrame:self.tabBar.frame];
    //要把自定义tabBar加到系统tabBar上，frame是相对于整个屏幕，而现在需要基于tabBar，所以使用bounds，两者的初始坐标是不一样的
    MRTTabBar *tabBar = [[MRTTabBar alloc] initWithFrame:self.tabBar.bounds];
    tabBar.backgroundColor = [UIColor whiteColor];
    
    //设置代理
    tabBar.delegate = self;
    
    //给tabBar传递tabBarItem模型
    tabBar.items = self.items;
    
    //添加自定义tabBar
    //[self.view addSubview:tabBar];
    //添加自定义tabBar为系统tabBar的子视图
    [self.tabBar addSubview:tabBar];
    
    //移除系统的tabBar
    //[self.tabBar removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //建立子控制器
    [self setUpAllChildVC];
    
    [self setUpTabBar];
    /*
    //使用自定义tabBar
    MRTTabBar *tabBar = [[MRTTabBar alloc] initWithFrame:self.tabBar.frame];
    
    //利用KVC设置tabBar(KVC能在没有存取方法的情况下直接存取实例变量，只对对象有效）
    [self setValue:tabBar forKey:@"tabBar"];
     */
}

/*- (void)viewWillAppear:(BOOL)animated
{
    //移除系统tabBar自带的UITabBarButton
    //因为UITabBarButton并不是在viewDidLoad添加的，在viewWillAppear中可以打印出所有UITabBarButton，所以在此移除系统UITabBarButton
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButton removeFromSuperview];
        }
    }
}*/

//删除系统tabBarButton
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    for (UIView *tabBarButton in self.tabBar.subviews)
    {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButton removeFromSuperview];
        }
    }
}

- (void)tabBar:(MRTTabBar *)tabBar didClickButton:(NSInteger)index
{
    //设置序号选中相应的tabBarItem
    self.selectedIndex = index;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpAllChildVC
{
    //添加首页
    MRTHomeViewController *homeVC = [[MRTHomeViewController alloc] init];
    //UIViewController *homeVC = [[UIViewController alloc] init];
    [self setUpOneChildVC:homeVC image:[UIImage imageNamed:@"tabbar_home"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_home_selected"] title:@"首页"];
    
    //添加信息页
    MRTMessageViewController *messageVC = [[MRTMessageViewController alloc] init];
    //UIViewController *messageVC = [[UIViewController alloc] init];
    [self setUpOneChildVC:messageVC image:[UIImage imageNamed:@"tabbar_message_center"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_message_center_selected"] title:@"消息"];
    
    //添加发现页
    MRTDiscoverViewController *discoverVC = [[MRTDiscoverViewController alloc] init];
    //UIViewController *discoverVC = [[UIViewController alloc] init];
    [self setUpOneChildVC:discoverVC image:[UIImage imageNamed:@"tabbar_discover"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_discover_selected"] title:@"发现"];
    
    //添加个人页面
    MRTProfileViewController *profileVC = [[MRTProfileViewController alloc] init];
    //UIViewController *profileVC = [[UIViewController alloc] init];
    [self setUpOneChildVC:profileVC image:[UIImage imageNamed:@"tabbar_profile"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_profile_selected"] title:@"我"];
}

- (void)setUpOneChildVC:(UIViewController *)vc image:(UIImage *)image selectedImage:(UIImage *)selctedImage title:(NSString *)title
{
    vc.tabBarItem.image = image;
    vc.tabBarItem.selectedImage = selctedImage;
    //vc.tabBarItem.title = title;
    //此方法可同时为tabBarItem和navigationItem设置title
    vc.title = title;
    vc.tabBarItem.badgeColor = [UIColor orangeColor];
    vc.tabBarItem.badgeValue = @"10";
    //将创建的视图控制器的tabBarItem加入items数组
    [self.items addObject:vc.tabBarItem];
    [self addChildViewController:vc];
    
    //创建导航栏并加入tabBarController
    MRTNavigationController *nav = [[MRTNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
    
}


@end
