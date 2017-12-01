//
//  NotificationViewController.m
//  MRTNotificationContentExtension
//
//  Created by mrtanis on 2017/11/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    NSLog(@">>>>>>>didReceiveNotification:");
    self.label.text = notification.request.content.body;
    //self.label.text = @"打开Webo查看最新好友微博，与好友分享你的新鲜事！";
    
    //获取共享文件夹路径
    NSString *sharingPath = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.webo.mrtanis"] path];
    //拼接图片路径
    NSString *imageSharingPath = [sharingPath stringByAppendingPathComponent:@"IMG_0029.jpg"];
    //获取图片
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageSharingPath]];
    
    
    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"IMG_0029" withExtension:@"jpg"];
    //self.imageView.image = [UIImage imageWithContentsOfFile:url.path];
    //UNNotificationContent * content = notification.request.content;
    //UNNotificationAttachment * attachment = content.attachments.firstObject;
    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.image = image;
}

@end
