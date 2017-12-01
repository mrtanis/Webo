//
//  MRTRootVCPicker.h
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MRTQuickLaunchType) {
    MRTQuickLaunchTypeFinished,
    MRTQuickLaunchTypeScan,
    MRTQuickLaunchTypeWrite,
};
@interface MRTRootVCPicker : NSObject
+ (void)chooseRootVC:(UIWindow *)keyWindow quickLaunchType:(MRTQuickLaunchType)type;

@end
