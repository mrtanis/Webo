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


@protocol MRTStatusCellDelegate <NSObject>

@optional
- (void)statusCell:(MRTStatusFrame *)statusFrame didClickButton:(NSInteger)index indexPath:(NSIndexPath *)indexPath;

- (void)textViewDidClickCell:(MRTStatusFrame *)statusFrame indexPath:(NSIndexPath *)indexPath;

- (void)playVideoOnView:(UIView *)superView indexPath:(NSIndexPath *)indexPath fromOriginal:(BOOL)fromOriginal;
- (void)clickURL:(NSURL *)url;

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

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) BOOL ignoreOriginalViewTap;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
