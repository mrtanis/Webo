//
//  MRTMessageReplyCommentView.h
//  Webo
//
//  Created by mrtanis on 2017/8/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTMessageCommentFrame.h"

@protocol MRTMessageReplyCommentViewDelegate <NSObject>

@optional
- (void)replyCommentTextViewDidTapCell;
- (void)clickURL:(NSURL *)url;
@end

@interface MRTMessageReplyCommentView : UIImageView
@property (nonatomic, weak) id <MRTMessageReplyCommentViewDelegate> delegate;

@property (nonatomic, strong) MRTMessageCommentFrame *commentFrame;
@end
