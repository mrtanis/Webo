//
//  MRTStatusCell.h
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTStatusFrame.h"
#import "MRTRetweetView.h"
#import "MRTStatusToolBar.h"
#import "MRTPictureView.h"
#import "MRTOriginalView.h"
@class MRTStatusCell;

@protocol MRTStatusCellDelegate <NSObject>

@optional
- (void)statusCell:(MRTStatusCell *)statusCell didClickButton:(NSInteger)index;

- (void)textViewDidClickCell:(MRTStatusCell *)statusCell;

@end
@interface MRTStatusCell : UITableViewCell

@property (nonatomic, weak) id <MRTStatusCellDelegate> delegate;

@property (nonatomic, strong) MRTStatusFrame *statusFrame;
@property (nonatomic, weak) MRTStatusToolBar *statusToolBar;
@property (nonatomic, weak) MRTOriginalView *originalView;
@property (nonatomic, weak) MRTRetweetView *retweetView;
@property (nonatomic, weak) MRTPictureView *pictureView;

@property (nonatomic, weak) UIButton *retweetBtn;
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *likeBtn;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
