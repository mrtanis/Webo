//
//  MRTOriginalView.h
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTStatusFrame.h"

@protocol MRTOriginalViewDelegate <NSObject>

@optional
- (void)originalTextViewDidTapCell;

@end

@interface MRTOriginalView : UIImageView

@property (nonatomic, weak) id <MRTOriginalViewDelegate> delegate;

@property (nonatomic, strong) MRTStatusFrame *statusFrame;

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UITextView *textView;

@end
