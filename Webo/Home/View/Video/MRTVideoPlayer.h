//
//  MRTVideoPlayer.h
//  Webo
//
//  Created by mrtanis on 2017/8/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MRTVideoPlayer : UIView

// 播放状态
@property (nonatomic) BOOL isPlaying;

// 是否横屏
@property (nonatomic) BOOL isLandscape;

// 是否锁屏
@property (nonatomic) BOOL isLock;

+ (instancetype)sharedInstance;
- (void)setPlayerView:(UIView *)playerView;
- (void)playWithUrl:(NSURL *)url allowRotate:(BOOL)allowRotate frame:(CGRect)frame;

@end
