//
//  MRTMessageCommentView.h
//  Webo
//
//  Created by mrtanis on 2017/8/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTMessageCommentFrame.h"

@protocol MRTMessageCommentViewDelegate <NSObject>

@optional
- (void)commentTextViewDidTapCell;
- (void)clickReplyButton;

@end

@interface MRTMessageCommentView : UIImageView

@property (nonatomic, weak) id <MRTMessageCommentViewDelegate> delegate;

@property (nonatomic, strong) MRTMessageCommentFrame *commentFrame;

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UITextView *textView;
@end
