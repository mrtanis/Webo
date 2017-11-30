//
//  AppDelegate.m
//  Webo
//
//  Created by mrtanis on 2017/4/24.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "AppDelegate.h"
#import "MRTTabBarController.h"
#import "MRTNewFeatureController.h"
#import "MRTOAuthViewController.h"
#import "MRTRootVCPicker.h"

#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>


@interface AppDelegate () <UNUserNotificationCenterDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //改变applicationIconBadgeNumber需要注册通知，ios8~ios9使用
    /*UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [application registerUserNotificationSettings:setting];
    */
    
    //ios10采用新的通知中心，目前这种获取授权可以达到改变applicationIconBadgeNumber的效果
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!error && granted) {
                                  NSLog(@"注册成功");
                              } else {
                                  NSLog(@"注册失败");
                              }
                          }];
    // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置，了解用户对通知权限的设定
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"========%@",settings);
    }];
    
    [MRTRootVCPicker chooseRootVC:self.window quickLaunchType:MRTQuickLaunchTypeFinished];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    UIApplicationShortcutItem *item = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
    if (item != nil) {
        return YES;
    } else {
        return NO;
    }
    
}

/*
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{

    return UIInterfaceOrientationMaskAllButUpsideDown;
 
}*/

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if ([shortcutItem.type isEqualToString:@"com.webo.scan"])
    {
        //MRTQRcodeScannerController *scanner = [[MRTQRcodeScannerController alloc] init];
        //scanner.fromQuickLaunch = YES;
        //UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:scanner];
        
        
        NSLog(@"快捷进入扫描");
        [MRTRootVCPicker chooseRootVC:self.window quickLaunchType:MRTQuickLaunchTypeScan];
        
    }
    else if ([shortcutItem.type isEqualToString:@"com.webo.write"])
    {
        [MRTRootVCPicker chooseRootVC:self.window quickLaunchType:MRTQuickLaunchTypeWrite];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    //开启后台处理多媒体事件
    //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    /*
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    //后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"silence.mp3" withExtension:nil];
    
    if (!_player.isPlaying) {
        
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        [player prepareToPlay];
        
        //无限播放
        player.numberOfLoops = -1;
        
        [player play];
        
        _player = player;
    }*/
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //将通知要显示的图片写入AppGroups共享文件夹
    
    //获取图片data
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"IMG_0029" ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    //获取共享文件夹路径（使用NSFileManager，也可使用NSUserDefaults传递）
    NSString *sharingPath = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.webo.mrtanis"] path];
    NSString *imageSharingPath = [sharingPath stringByAppendingPathComponent:@"IMG_0029.jpg"];
    //将图片写入共享文件夹
    [[NSFileManager defaultManager] createFileAtPath:imageSharingPath contents:imageData attributes:nil];
    
    
    
    
    UNTimeIntervalNotificationTrigger *intervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Webo提醒";
    //content.subtitle = @"Webo查看精彩信息";
    content.body = @"打开Webo查看最新好友微博，与好友分享你的新鲜事！";
    content.badge = @6;
    content.sound = [UNNotificationSound defaultSound];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"IMG_0029" withExtension:@"jpg"];
    UNNotificationAttachment *attchment = [UNNotificationAttachment attachmentWithIdentifier:@"photo" URL:url options:nil error:nil];
    content.attachments = @[attchment];
    content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
    
    content.categoryIdentifier = @"Webo_Category";
    //创建按钮Action
    UNNotificationAction *writeAction = [UNNotificationAction actionWithIdentifier:@"action.write" title:@"发微博" options:UNNotificationActionOptionForeground
];
    
    UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"action.cancel" title:@"取消" options:UNNotificationActionOptionDestructive];
    
    UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"Webo_Category" actions:@[writeAction, cancelAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[NSSet setWithObject:notificationCategory]];
    /*
    // 创建 UNTextInputNotificationAction 比 UNNotificationAction 多了两个参数
    // * buttonTitle 输入框右边的按钮标题
    // * placeholder 输入框占位符
    UNTextInputNotificationAction *inputAction = [UNTextInputNotificationAction actionWithIdentifier:@"action.input" title:@"输入" options:UNNotificationActionOptionForeground textInputButtonTitle:@"发送" textInputPlaceholder:@"tell me loudly"];
    // 注册 category
    UNNotificationCategory *notificationCategory2 = [UNNotificationCategory categoryWithIdentifier:@"Webo_Category" actions:@[inputAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    [center setNotificationCategories:[NSSet setWithObjects:notificationCategory, notificationCategory2, nil]];
    */
    //创建通知标识
    NSString *requestIdentifier = @"mrtanis.webo.timeInterval";
    
    //创建通知请求
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:intervalTrigger];
    
    
    // 将通知请求 add 到 UNUserNotificationCenter
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"推送已添加成功 %@", requestIdentifier);
            
        }
    }];
    
    //开启一个后台任务，优先级较低，假如系统要关闭应用，首先考虑这个任务
    /*
    UIBackgroundTaskIdentifier ID = [application beginBackgroundTaskWithExpirationHandler:^{
        //当后台任务结束时调用
        [application endBackgroundTask:ID];
    }];
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


//App通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSString *actionIdentifierStr = response.actionIdentifier;
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        
    } else {
        if ([actionIdentifierStr isEqualToString:@"action.write"]) {
            self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            
            [MRTRootVCPicker chooseRootVC:self.window quickLaunchType:MRTQuickLaunchTypeWrite];
            
            self.window.backgroundColor = [UIColor whiteColor];
            [self.window makeKeyAndVisible];
        } else if ([actionIdentifierStr isEqualToString:@"action.cancel"]) {
            
        }
    }
    
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Webo"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
