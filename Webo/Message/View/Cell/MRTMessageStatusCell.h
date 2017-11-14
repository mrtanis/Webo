//
//  MRTMessageStatusCell.h
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTMessageStatusFrame.h"
#import "MRTMessageOriginalStatusView.h"
#import "MRTMessageRetweetStatusView.h"
#import "MRTPictureView.h"
#import "MRTStatusToolBar.h"
#import "MRTCommentFrame.h"

@protocol MRTMessageStatusCellDelegate <NSObject>

@optional
- (void)statusCell:(MRTStatusFrame *)statusFrame didClickButton:(NSInteger)index;

- (void)textViewDidClickCell:(MRTStatusFrame *)statusFrame onlyOriginal:(BOOL)flag;

- (void)clickReplyButtonWithFrame:(MRTCommentFrame *)commentFrame;
- (void)clickURL:(NSURL *)url;

@end
@interface MRTMessageStatusCell : UITableViewCell
@property (nonatomic, weak) id <MRTMessageStatusCellDelegate> delegate;

@property (nonatomic, strong) MRTMessageStatusFrame *statusFrame;
@property (nonatomic, weak) MRTStatusToolBar *statusToolBar;
@property (nonatomic, weak) MRTMessageOriginalStatusView *originalView;
@property (nonatomic, weak) MRTMessageRetweetStatusView *retweetView;
@property (nonatomic, weak) MRTPictureView *pictureView;

@property (nonatomic, weak) UIButton *retweetBtn;
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *likeBtn;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
