//
//  MRTTabBarController.h
//  Webo
//
//  Created by mrtanis on 2017/5/6.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTRootVCPicker.h"

@interface MRTTabBarController : UITabBarController


- (instancetype)initFromQuickLaunchType:(MRTQuickLaunchType)type;
@end
