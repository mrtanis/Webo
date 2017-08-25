//
//  MRTMessageCommentCell.h
//  Webo
//
//  Created by mrtanis on 2017/8/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTMessageCommentFrame.h"
#import "MRTMessageCommentView.h"
#import "MRTMessageReplyCommentView.h"
#import "MRTCommentFrame.h"

@protocol  MRTMessageCommentCellDelegate <NSObject>

@optional

- (void)textViewDidClickCell:(MRTMessageCommentFrame *)commentFrame;

- (void)clickReplyButtonWithFrame:(MRTCommentFrame *)commentFrame;

@end

@interface MRTMessageCommentCell : UITableViewCell
@property (nonatomic, weak) id <MRTMessageCommentCellDelegate> delegate;
@property (nonatomic, strong) MRTMessageCommentFrame *commentFrame;
@property (nonatomic, weak) MRTMessageCommentView *commentView;
@property (nonatomic, weak) MRTMessageReplyCommentView *replyCommentView;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
