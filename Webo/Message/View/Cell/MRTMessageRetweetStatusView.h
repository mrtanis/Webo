//
//  MRTMessageRetweetStatusView.h
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTMessageStatusFrame.h"

@protocol MRTMessageRetweetStatusViewDelegate <NSObject>
@optional
- (void)retweetTextViewDidTapCell;
@end

@interface MRTMessageRetweetStatusView : UIImageView
@property (nonatomic, weak) id <MRTMessageRetweetStatusViewDelegate> delegate;
@property (nonatomic, strong) MRTMessageStatusFrame *statusFrame;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *textLabel;

@end
