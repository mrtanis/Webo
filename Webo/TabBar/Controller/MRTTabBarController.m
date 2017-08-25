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
#import "MRTUnreadTool.h"
#import "MRTPlusButtonClickView.h"
#import "MRTTextViewController.h"

@interface MRTTabBarController () <MRTTabBarDelegate, MRTPlusButtonClickViewDelegate>//遵守代理协议
@property (nonatomic, copy) NSMutableArray *items;

@property (nonatomic, weak) MRTHomeViewController *homeVC;
@property (nonatomic, weak) MRTMessageViewController *messageVC;
@property (nonatomic, weak) MRTDiscoverViewController *discoverVC;
@property (nonatomic, weak) MRTProfileViewController *profileVC;

@property (nonatomic, weak) MRTPlusButtonClickView *plusBtnClickView;

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

#pragma mark 懒加载items
- (NSMutableArray *)items
{
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    
    return _items;
}

#pragma mark 设置tabBar
- (void)setUpTabBar
{
    //自定义tabBar
    //MRTTabBar *tabBar = [[MRTTabBar alloc] initWithFrame:self.tabBar.frame];
    //要把自定义tabBar加到系统tabBar上，frame是相对于整个屏幕，而现在需要基于tabBar，所以使用bounds，两者的初始坐标是不一样的
    //CGRect tabBarFrame = CGRectMake(0, MRTScreen_Height - 50, MRTScreen_Width, 50);
    MRTTabBar *tabBar = [[MRTTabBar alloc] initWithFrame:self.tabBar.bounds];
    tabBar.backgroundColor = [UIColor clearColor];
    
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
    
    //设置未读消息数
    //[self getUnreadNumber];
    
    //设置每隔两秒请求未读数
    //[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getUnreadNumber) userInfo:nil repeats:YES];
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

#pragma mark 删除系统tabBarButton
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //调整tabBar高度
    CGRect tabBarFrame = self.tabBar.frame;
    tabBarFrame.size.height = 45;
    tabBarFrame.origin.y = MRTScreen_Height - tabBarFrame.size.height;
    self.tabBar.frame = tabBarFrame;
    
    for (UIView *tabBarButton in self.tabBar.subviews)
    {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButton removeFromSuperview];
        }
    }
}

#pragma mark tabBar按钮点击时调用
- (void)tabBar:(MRTTabBar *)tabBar didClickButton:(NSInteger)index
{
    //在首页的时候点击首页图标刷新
    if (index == 0 && self.selectedIndex == index) {
        [_homeVC refresh];
    }
    
    //设置序号选中相应的tabBarItem
    self.selectedIndex = index;
}

#pragma mark tabBar➕号点击时调用
- (void)tabBarDidClickPlusButton:(MRTTabBar *)tabBar
{
    MRTPlusButtonClickView *plusBtnClickView = [[MRTPlusButtonClickView alloc] initWithFrame:self.view.frame];
    plusBtnClickView.userInteractionEnabled = YES;
    plusBtnClickView.delegate = self;
    [self.view addSubview:plusBtnClickView];
    
    _plusBtnClickView = plusBtnClickView;
}

#pragma mark 点击加号弹出页面上的按钮时调用
- (void)plusViewDidClickButton:(NSInteger)index
{
    NSLog(@"执行点击文字按钮代理方法");
    if (index == 1) {
        
        MRTTextViewController *textVC = [[MRTTextViewController alloc] init];
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:textVC];
        [self.plusBtnClickView removeFromSuperview];
        [self presentViewController:navVC animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 设置子控制器
- (void)setUpAllChildVC
{
    //添加首页
    MRTHomeViewController *homeVC = [[MRTHomeViewController alloc] init];
    //UIViewController *homeVC = [[UIViewController alloc] init];
    [self setUpOneChildVC:homeVC image:[UIImage imageNamed:@"tabbar_home"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_home_selected"] title:@"首页"];
    
    _homeVC = homeVC;
    
    //添加信息页
    MRTMessageViewController *messageVC = [[MRTMessageViewController alloc] init];
    
    [self setUpOneChildVC:messageVC image:[UIImage imageNamed:@"tabbar_message_center"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_message_center_selected"] title:@"消息"];
    
    _messageVC = messageVC;
    
    //添加发现页
    MRTDiscoverViewController *discoverVC = [[MRTDiscoverViewController alloc] init];
    
    [self setUpOneChildVC:discoverVC image:[UIImage imageNamed:@"tabbar_discover"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_discover_selected"] title:@"发现"];
    
    _discoverVC = discoverVC;
    
    //添加个人页面
    MRTProfileViewController *profileVC = [[MRTProfileViewController alloc] init];
    
    [self setUpOneChildVC:profileVC image:[UIImage imageNamed:@"tabbar_profile"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_profile_selected"] title:@"我"];
    
    _profileVC = profileVC;
}

- (void)setUpOneChildVC:(UIViewController *)vc image:(UIImage *)image selectedImage:(UIImage *)selctedImage title:(NSString *)title
{
    vc.tabBarItem.image = image;
    vc.tabBarItem.selectedImage = selctedImage;
    //vc.tabBarItem.title = title;
    //此方法可同时为tabBarItem和navigationItem设置title
    vc.title = title;
    vc.tabBarItem.badgeColor = [UIColor orangeColor];
    
    //将创建的视图控制器的tabBarItem加入items数组
    [self.items addObject:vc.tabBarItem];
    [self addChildViewController:vc];
    
    //创建导航栏并加入tabBarController
    MRTNavigationController *nav = [[MRTNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
    
}

#pragma mark 获取未读消息数
- (void)getUnreadNumber
{
    [MRTUnreadTool unreadWithSuccess:^(MRTUnreadResult *result) {
        //设置首页微博未读数
        _homeVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", result.status];
        
        //设置消息页未读数
        _messageVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", result.messageCount];
        
        //设置个人页未读数
        _profileVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", result.follower];
        
        //设置应用图标未读数（只显示消息数和个人页未读数，微博未读数太多了）
        [UIApplication sharedApplication].applicationIconBadgeNumber = result.totalCount;
        
    } failure:^(NSError *error) {
        
        NSLog(@"error:%@", error);
        
    }];
}

#pragma mark - 判断屏幕是否可以旋转
/*
- (BOOL)shouldAutorotate {
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}
*/
@end
