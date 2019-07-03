//
//  MRTHomeViewController.h
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTRootVCPicker.h"

@interface MRTHomeViewController : UITableViewController
//标注是否从3D touch 进入
@property (nonatomic) MRTQuickLaunchType quickLaunchType;
- (void)refresh;

@end
