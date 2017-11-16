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
#import "MRTImagePickerController.h"
#import <Photos/Photos.h>

@interface MRTTabBarController () <MRTTabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MRTImagePickerDelegate>//遵守代理协议
@property (nonatomic, copy) NSMutableArray *items;

@property (nonatomic, weak) MRTHomeViewController *homeVC;
@property (nonatomic, weak) MRTMessageViewController *messageVC;
@property (nonatomic, weak) MRTDiscoverViewController *discoverVC;
@property (nonatomic, weak) MRTProfileViewController *profileVC;

@property (nonatomic, weak) MRTPlusButtonClickView *plusBtnClickView;

@property (nonatomic, weak) UIButton *plusButton;

@property (nonatomic, weak) UIButton *writeButton;//写微博
@property (nonatomic, weak) UIButton *photoButton;//发照片
@property (nonatomic, weak) UIButton *cameraButton;//拍照片


//标注是否从3D touch 进入
@property (nonatomic) MRTQuickLaunchType quickLaunchType;
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

- (instancetype)initFromQuickLaunchType:(MRTQuickLaunchType)type
{
    _quickLaunchType = type;
    NSLog(@"tabBar初始化");
    self = [super init];
 
    return self;
}

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    
    /*
    //移除系统tabBar自带的UITabBarButton
    //因为UITabBarButton并不是在viewDidLoad添加的，在viewWillAppear中可以打印出所有UITabBarButton，所以在此移除系统UITabBarButton
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButton removeFromSuperview];
        }
    }*/
}

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
- (void)tabBarDidClickPlusButton:(UIButton *)button
{
    _plusButton = button;
    if (button.selected) {
        [self showFunctionButtons];
        /*
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            button.imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
            _writeButton.frame = CGRectMake(70, MRTScreen_Height - 120, 60, 60);
            _writeButton.alpha = 1;
        } completion:nil];
        [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _photoButton.frame = CGRectMake(MRTScreen_Width * 0.5 - 30, MRTScreen_Height - 150, 60, 60);
            _photoButton.alpha = 1;
        } completion:nil];
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _cameraButton.frame = CGRectMake(MRTScreen_Width - 130, MRTScreen_Height - 120, 60, 60);
            _cameraButton.alpha = 1;
        } completion:^(BOOL finished) {
            button.enabled = YES;
        }];*/
    } else {
        [self hideFunctionButtons];
    }
    /*
    MRTPlusButtonClickView *plusBtnClickView = [[MRTPlusButtonClickView alloc] initWithFrame:self.view.frame];
    plusBtnClickView.userInteractionEnabled = YES;
    plusBtnClickView.delegate = self;
    [self.view addSubview:plusBtnClickView];
    
    _plusBtnClickView = plusBtnClickView;*/
}

- (void)showFunctionButtons
{
    UIButton *writeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    writeButton.tag = 0;
    [writeButton addTarget:self action:@selector(plusViewDidClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [writeButton setImage:[UIImage imageNamed:@"tabbar_compose_idea_neo"] forState:UIControlStateNormal];
    writeButton.imageView.contentMode = UIViewContentModeRedraw;
    writeButton.frame = CGRectMake(MRTScreen_Width * 0.5, MRTScreen_Height - 22, 0, 0);
    writeButton.alpha = 0;
    writeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    writeButton.layer.shadowOffset = CGSizeMake(2, 2);
    writeButton.layer.shadowOpacity = 1;
    writeButton.layer.shadowRadius = 4;
    [self.view addSubview:writeButton];
    _writeButton = writeButton;
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.tag = 1;
    [photoButton addTarget:self action:@selector(plusViewDidClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [photoButton setImage:[UIImage imageNamed:@"tabbar_compose_picture_neo"] forState:UIControlStateNormal];
    photoButton.imageView.contentMode = UIViewContentModeRedraw;
    photoButton.frame = CGRectMake(MRTScreen_Width * 0.5, MRTScreen_Height - 22, 0, 0);
    photoButton.alpha = 0;
    photoButton.layer.shadowColor = [UIColor blackColor].CGColor;
    photoButton.layer.shadowOffset = CGSizeMake(0, 2);
    photoButton.layer.shadowOpacity = 1;
    photoButton.layer.shadowRadius = 4;
    [self.view addSubview:photoButton];
    _photoButton = photoButton;
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.tag = 2;
    [cameraButton addTarget:self action:@selector(plusViewDidClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [cameraButton setImage:[UIImage imageNamed:@"tabbar_compose_capture_neo"] forState:UIControlStateNormal];
    cameraButton.imageView.contentMode = UIViewContentModeRedraw;
    cameraButton.frame = CGRectMake(MRTScreen_Width * 0.5, MRTScreen_Height - 22, 0, 0);
    cameraButton.alpha = 0;
    cameraButton.layer.shadowColor = [UIColor blackColor].CGColor;
    cameraButton.layer.shadowOffset = CGSizeMake(-2, 2);
    cameraButton.layer.shadowOpacity = 1;
    cameraButton.layer.shadowRadius = 4;
    [self.view addSubview:cameraButton];
    _cameraButton = cameraButton;
    
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _plusButton.imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
        _writeButton.frame = CGRectMake(70, MRTScreen_Height - 120, 60, 60);
        _writeButton.alpha = 1;
    } completion:nil];
    [UIView animateWithDuration:0.2 delay:0.1 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _photoButton.frame = CGRectMake(MRTScreen_Width * 0.5 - 30, MRTScreen_Height - 150, 60, 60);
        _photoButton.alpha = 1;
    } completion:nil];
    [UIView animateWithDuration:0.2 delay:0.2 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _cameraButton.frame = CGRectMake(MRTScreen_Width - 130, MRTScreen_Height - 120, 60, 60);
        _cameraButton.alpha = 1;
    } completion:^(BOOL finished) {
        _plusButton.enabled = YES;
    }];
}

- (void)hideFunctionButtons
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _plusButton.imageView.transform = CGAffineTransformIdentity;
        _cameraButton.frame = CGRectMake(MRTScreen_Width * 0.5, MRTScreen_Height - 22, 0, 0);
        _cameraButton.alpha = 0;
    } completion:^(BOOL finished) {
        [_cameraButton removeFromSuperview];
    }];
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _photoButton.frame = CGRectMake(MRTScreen_Width * 0.5, MRTScreen_Height - 22, 0, 0);
        _photoButton.alpha = 0;
    } completion:^(BOOL finished) {
        [_photoButton removeFromSuperview];
    }];
    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _writeButton.frame = CGRectMake(MRTScreen_Width * 0.5, MRTScreen_Height - 22, 0, 0);
        _writeButton.alpha = 0;
    } completion:^(BOOL finished) {
        [_writeButton removeFromSuperview];
        _plusButton.enabled = YES;
        _plusButton.selected = NO;
    }];
}

#pragma mark 点击加号弹出页面上的按钮时调用
- (void)plusViewDidClickButton:(UIButton *)button
{
    [self hideFunctionButtons];
    
    NSLog(@"执行点击文字按钮代理方法");
    if (button.tag == 0) {
        
        MRTTextViewController *textVC = [[MRTTextViewController alloc] init];
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:textVC];
        //[self.plusBtnClickView removeFromSuperview];
        [self presentViewController:navVC animated:YES completion:nil];
    } else if (button.tag == 1) {
        MRTImagePickerController *imagePicker = [[MRTImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.directEnter = YES;
        MRTNavigationController *nav = [[MRTNavigationController alloc] initWithRootViewController:imagePicker];
        [self presentViewController:nav animated:YES completion:nil];
    } else if (button.tag == 2) {
        UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
        
        //判断摄像头是否可用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        pickerVC.delegate = self;
        [self presentViewController:pickerVC animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //__block PHAsset *assetOfImage;
    typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            typeof(weakSelf) strongSelf = weakSelf;
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //写入图片到相册
                PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"success = %d, error = %@", success, error);
                
                
                //先获取相机胶卷
                //PHFetchResult *collectionsResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[@"相机胶卷"] options:nil];
                //PHAssetCollection *assetCollection = [collectionsResult firstObject];
                //按日期降序排列并过滤掉非照片类型
                PHFetchOptions *fetchAssetOption = [[PHFetchOptions alloc] init];
                fetchAssetOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];//按照日期降序排序
                //fetchAssetOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];//过滤剩下照片类型
                PHFetchResult *assetsResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchAssetOption];
                PHAsset *asset = [assetsResult firstObject];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [picker dismissViewControllerAnimated:NO completion:^{
                        MRTTextViewController *textVC = [[MRTTextViewController alloc] init];
                        textVC.photoAssets = [NSMutableArray arrayWithObject:asset];
                        textVC.originalMode = YES;
                        textVC.shouldSetUpPhotoView = YES;
                        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:textVC];

                        [strongSelf presentViewController:navVC animated:YES completion:nil];
                    }];
                });
                
                
            }];
            }
        }];
    });
}

- (void)shouldPresentCameraVC
{
    UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
    
    //判断摄像头是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    pickerVC.delegate = self;
    
    [self presentViewController:pickerVC animated:YES completion:nil];
    
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
    NSLog(@"tabBar创建首页视图");
    
    homeVC.quickLaunchType = _quickLaunchType;
    
    
    [self setUpOneChildVC:homeVC image:[UIImage imageNamed:@"tabbar_home"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_home_selected"] title:@"首页"];
    
    _homeVC = homeVC;
    
    //添加信息页
    MRTMessageViewController *messageVC = [[MRTMessageViewController alloc] init];
    
    [self setUpOneChildVC:messageVC image:[UIImage imageNamed:@"tabbar_message_center"] selectedImage:[UIImage imageWithOriginalName:@"tabbar_message_center_selected"] title:@"@me"];
    
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
    //return [self.viewControllers.lastObject shouldAutorotate];
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}*/

- (BOOL)shouldAutorotate {
    //NSLog(@"self.selectedViewController:%@", self.selectedViewController);
    //return [self.selectedViewController shouldAutorotate];
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //NSLog(@"self.selectedViewController:%@", self.selectedViewController);
    //return [self.selectedViewController supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}



@end
