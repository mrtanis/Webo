//
//  MRTNavigationController.m
//  Webo
//
//  Created by mrtanis on 2017/5/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTNavigationController.h"
#import "UIBarButtonItem+MRTItem.h"

@interface MRTNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) id popDelegate;
@end

@implementation MRTNavigationController

+ (void)initialize
{
    //获取当前类下的UIBarButtonItem
    UIBarButtonItem *item = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[self]];
    
    //设置导航条按钮的文字颜色,同样通过富文本设置
    NSMutableDictionary *titleNormal = [NSMutableDictionary dictionary];
    titleNormal[NSForegroundColorAttributeName] = [UIColor darkTextColor];
    [item setTitleTextAttributes:titleNormal forState:UIControlStateNormal];
    //NSMutableDictionary *titleHighlighted = [NSMutableDictionary dictionary];
    //titleHighlighted[NSForegroundColorAttributeName] = [UIColor orangeColor];
    //[item setTitleTextAttributes:titleHighlighted forState:UIControlStateHighlighted];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _popDelegate = self.interactivePopGestureRecognizer.delegate;
    self.delegate = self;
}

//重写push方法，以满足新建控制器时自动设置导航栏的需求，减少逐个设置的工作量
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //设置非根视图控制器的导航条,判断的原因是最初执行的initWithRootViewController底层会调用push，把根控制器压入栈，如果直接这样设置就会把根控制器，也就是首页的导航条内容也给更改了。
    if (self.viewControllers.count != 0) {
        //设置leftBarButtonItem
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_back"] highLightedImage:[UIImage imageNamed:@"navigationbar_back_highlighted"] target:self action:@selector(backToPre) forControlEvents:UIControlEventTouchUpInside];
        
        //设置rightBarButtonItem
        viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_more"] highLightedImage:[UIImage imageNamed:@"navigationbar_more_highlighted"] target:self action:@selector(backToRoot) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)backToPre
{
    [self popViewControllerAnimated:YES];
}

- (void)backToRoot
{
    [self popToRootViewControllerAnimated:YES];
}

//navigationController代理方法
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self.viewControllers[0]) {
        //还原滑动返回手势
        self.interactivePopGestureRecognizer.delegate = _popDelegate;
    } else {
        //实现滑动返回功能，清空滑动返回手势的代理，就能实现滑动
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}

//当导航控制器即将显示的时候调用
/*- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //获取窗口
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    //获取tabBarViewController
    UITabBarController *tabBarVc = (UITabBarController *)keyWindow.rootViewController;
    //移除系统的UITabBarButton
    for (UIView *tabBarButton in tabBarVc.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButton removeFromSuperview];
        }
    }
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
