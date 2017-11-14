//
//  MRTVideoTransition.h
//  Webo
//
//  Created by mrtanis on 2017/10/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MRTVideoPlayer;

//transition类型
typedef NS_ENUM(NSInteger, MRTVideoTransitionType)
{
    MRTVideoTransitionTypeEnter,
    MRTVideoTransitionTypeExit,
};

@interface MRTVideoTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) MRTVideoTransitionType transitionType;

@property (nonatomic, weak) MRTVideoPlayer *videoView;

- (instancetype)initWithVideoView:(MRTVideoPlayer *)videoView transionType:(MRTVideoTransitionType)type;
@end
