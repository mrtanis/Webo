//
//  MRTVideoPlayer.h
//  Webo
//
//  Created by mrtanis on 2017/8/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MRTVideoOrientation) {
    MRTVideoOrientationPortrait,
    MRTVideoOrientationLandscapeLeft,
    MRTVideoOrientationLandscapeRight,
};


@protocol MRTVideoPlayerDelegate <NSObject>
@optional
- (void)shouldHideStatusBar:(BOOL)hideStatusBar;
- (void)handleFullScreenAndHideStatusBar:(BOOL)hideStatusBar orientationMask:(UIInterfaceOrientationMask)orientationMask;
@end

@interface MRTVideoPlayer : UIView
@property (nonatomic, weak) id <MRTVideoPlayerDelegate> delegate;


@property (nonatomic, weak) UIView *fatherView;//播放器附着的view
@property (nonatomic, weak) UITableView *tableView;//当前tableView
@property (nonatomic) CGRect beginningFrame; //记录进入全屏前的frame，仅在进入全屏时对其赋值
@property (nonatomic) BOOL fromOriginal;//记录是在originalView还是retweetedView

// 播放状态
@property (nonatomic) BOOL isPlaying;
//当播放视频时切换到其他应用再切换回来时，设定此值避免自动播放
@property (nonatomic) BOOL disableAutoPlay;

// 是否横屏
@property (nonatomic) BOOL isLandscape;

@property (nonatomic) MRTVideoOrientation videoOrientation;

@property (nonatomic, strong) NSIndexPath *indexPath;//cell所在indexPath
@property (nonatomic) BOOL isReplayShow;    //重播按钮是否显示

@property (nonatomic) BOOL isPlayerShow;    //播放界面是否显示

@property (nonatomic) BOOL allowRotate; //根据视频长宽比判断是否允许转屏
@property (nonatomic) BOOL miniPortrait;    //长形视频的窗口模式

+ (instancetype)sharedInstance;
- (void)setPlayerView:(UIView *)playerView;
- (void)playWithUrl:(NSURL *)url onView:(UIView *)fatherView tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (void)play;
- (void)pause;
- (void)resetPlayer;

//取消三秒后隐藏工具栏，当刚刚点击视频调出工具栏时马上返回上个控制器，如果不取消隐藏工具栏的操作，会发生自动布局错误（布局toolBar）
- (void)cancelDelayHideToolBarAndStatusBar;
@end
