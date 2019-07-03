//
//  MRTVideoTransition.m
//  Webo
//
//  Created by mrtanis on 2017/10/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTVideoTransition.h"
#import "MRTVideoPlayer.h"

@implementation MRTVideoTransition

- (instancetype)initWithVideoView:(MRTVideoPlayer *)videoView transionType:(MRTVideoTransitionType)type
{
    self = [super init];
    
    if (self) {
        _videoView = videoView;
        _transitionType = type;
    }
    
    return self;
}


- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    if (_transitionType == MRTVideoTransitionTypeEnter) {
        [self enterTransitionWithContext:transitionContext];
    } else {
        [self exitTransitionWithContext:transitionContext];
    }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 2;
}

- (void)enterTransitionWithContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = nil;
    if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0) {
        toView = toViewController.view;
    } else {
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }
    
    //CGRect smallVideoFrame = [transitionContext.containerView convertRect:_videoView.bounds fromView:_videoView];
    CGRect smallVideoFrame = _videoView.beginningFrame;
    NSLog(@"smallVideoFrame:(%f, %f, %f, %f)", smallVideoFrame.origin.x, smallVideoFrame.origin.y, smallVideoFrame.size.width, smallVideoFrame.size.height);
    NSLog(@"_video.bounds:(%f, %f, %f, %f)", _videoView.bounds.origin.x, _videoView.bounds.origin.y, _videoView.bounds.size.width, _videoView.bounds.size.height);
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    NSLog(@"toViewFinalFrame:(%f, %f, %f, %f)", toViewFinalFrame.origin.x, toViewFinalFrame.origin.y, toViewFinalFrame.size.width, toViewFinalFrame.size.height);
    toView.bounds = CGRectMake(0, 0, smallVideoFrame.size.width, smallVideoFrame.size.height);
    //toView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    toView.center = CGPointMake(MRTScreen_Width - CGRectGetMidY(smallVideoFrame),MRTScreen_Height - CGRectGetMidX(smallVideoFrame));
    NSLog(@"toView.center:(%f, %f)", toView.center.x, toView.center.y);
    //CGAffineTransform transform = CGAffineTransformMakeScale(_videoView.bounds.size.width / toViewFinalFrame.size.width, _videoView.bounds.size.height / toViewFinalFrame.size.height);
    
    [transitionContext.containerView addSubview:toView];
    
    [_videoView removeFromSuperview];
    _videoView.frame = toView.bounds;
    [toView addSubview:_videoView];
    
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //toView.transform = CGAffineTransformIdentity;
        //toView.frame = toViewFinalFrame;
        //self.videoView.frame = toView.bounds;
    } completion:^(BOOL finished) {
        
        //必须通知系统是否完成transition，此处是最佳位置
        [transitionContext completeTransition:YES];
    }];
}

- (void)exitTransitionWithContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = nil;
    if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0) {
        fromView = fromViewController.view;
    } else {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    }
    
    CGRect smallVideoFrame = [transitionContext.containerView convertRect:_videoView.beginningFrame fromView:_videoView.fatherView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.transform = CGAffineTransformIdentity;
        fromView.frame = smallVideoFrame;
        self.videoView.frame = fromView.bounds;
    } completion:^(BOOL finished) {
        self.videoView.frame = self.videoView.beginningFrame;
        [self.videoView.fatherView addSubview:self.videoView];
        [fromView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
