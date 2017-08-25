//
//  MRTMessageOriginalStatusView.h
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTMessageStatusFrame.h"

@protocol MRTMessageOriginalStatusViewDelegate <NSObject>

@optional
- (void)originalTextViewDidTapCell;
- (void)clickReplyButton;

@end
@interface MRTMessageOriginalStatusView : UIImageView
@property (nonatomic, weak) id <MRTMessageOriginalStatusViewDelegate> delegate;

@property (nonatomic, strong) MRTMessageStatusFrame *statusFrame;

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UITextView *textView;

@end
