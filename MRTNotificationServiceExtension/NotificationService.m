//
//  NotificationService.m
//  MRTNotificationServiceExtension
//
//  Created by mrtanis on 2017/11/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"IMG_0029" withExtension:@"jpg"];
    
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"image" URL:imageURL options:nil error:nil];
    
    if (attachment ) {
        NSLog(@"图片添加到附件成功");
        self.bestAttemptContent.attachments = @[attachment];
    } else {
        NSLog(@"图片添加到附件失败");
    }
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
