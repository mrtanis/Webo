//
//  MRTOAuthViewController.h
//  Webo
//
//  Created by mrtanis on 2017/5/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTOAuthViewController : UIViewController

//如果是用户主动切换账号，则设置导航栏（方便返回个人设置界面）
//如果是首次登录，登录界面是没有导航栏的，登录完成后跳转到主界面
@property (nonatomic) BOOL presentedByUser;

@end
