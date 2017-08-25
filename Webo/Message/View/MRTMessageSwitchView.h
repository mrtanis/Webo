//
//  MRTMessageSwitchView.h
//  Webo
//
//  Created by mrtanis on 2017/7/25.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTCommentViewController.h"


@protocol MRTMessageSwitchViewDelegate <NSObject>

@optional
- (void)messageSwitchViewDidSendVC:(UIViewController *)VC present:(BOOL)present;

@end

@interface MRTMessageSwitchView : UIView
@property (nonatomic, weak) id <MRTMessageSwitchViewDelegate> delegate;
@end
