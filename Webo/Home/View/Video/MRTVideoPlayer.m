//
//  MRTVideoPlayer.m
//  Webo
//
//  Created by mrtanis on 2017/8/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "NSString+MRTConvert.h"
#import "AppDelegate.h"
#import "MBProgressHUD+MRT.h"
#import "MRTStatusCell.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface MRTVideoPlayer () <UIGestureRecognizerDelegate>

//播放器相关
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *AVItem;
@property (nonatomic, strong) AVPlayerLayer *AVLayer;
@property (nonatomic, strong) AVAsset *AVAsset;
@property (nonatomic, weak) UIView *playerView;
@property (nonatomic) CGSize videoSize;



//控件相关
@property (nonatomic, strong) UIView *toolBar;   //底部工具栏
@property (nonatomic, weak) UIButton *playButton;  //播放、暂停按钮
@property (nonatomic, weak) UIButton *fullScreenButton;  //全屏按钮
@property (nonatomic, weak) UIButton *replayButton;  //重播按钮
@property (nonatomic, weak) UISlider *playSlider;  //滑动条
@property (nonatomic, weak) UIProgressView *playProgressBottom;  //底部滑动条
@property (nonatomic, weak) UIProgressView *progressView;  //进度条
@property (nonatomic, weak) UIProgressView *progressViewBottom;  //底部进度条
@property (nonatomic, weak) UILabel *currentTimeLabel;  //当前时间
@property (nonatomic, weak) UILabel *totalTimeLabel;  //总时间
@property (nonatomic, weak) UIActivityIndicatorView *loadingIndicator;  //加载时菊花图
@property (nonatomic, weak) UIView *statusBarBackgroundView;    //横屏时状态栏背景（黑色透明）
@property (nonatomic, weak) UILabel *noticeBoard;    //暂停、播放提示

//约束
@property (nonatomic, strong) MASConstraint *toolBarBottom;
@property (nonatomic, strong) MASConstraint *noticeBoardHeight;

//状态相关
@property (nonatomic) BOOL isSliding;   //是否正在拖动slider
@property (nonatomic) BOOL isshowToolBarAndStatusBar;   //toolBar是否处于显示状态
//@property (nonatomic) BOOL isInBackground;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) id timeObserver;  //playback监测



@property (nonatomic) BOOL isBuffering; //是否正在缓冲isPauseByUser
@property (nonatomic) BOOL isPauseByUser;

//滑动手势相关
@property (nonatomic, strong) NSMutableDictionary *locations;   //保存开始触摸时的位置
@property (nonatomic) CGFloat totalDisdance; //滑动累计距离
@property (nonatomic) CGPoint beginPoint;


@end

@implementation MRTVideoPlayer

#pragma mark - 懒加载
- (NSMutableDictionary *)locations
{
    if (!_locations.count) {
        _locations = [NSMutableDictionary dictionary];
    }
    
    return _locations;
}

#pragma mark - 创建实例
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MRTVideoPlayer *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark - 根据传入url播放视频
- (void)playWithUrl:(NSURL *)url onView:(UIView *)fatherView tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    
    //_allowRotate = allowRotate;
    //self.frame = frame;
    
    _fatherView = fatherView;
    self.tableView = tableView;//用self是因为需要使用自定义存方法
    _indexPath = indexPath;
    _isPlayerShow = YES;
    //重置播放器
    [self resetPlayer];
    _AVAsset = [AVAsset assetWithURL:url];
    NSArray *array = _AVAsset.tracks;
    CGSize videoSize = CGSizeZero;
    
    for (AVAssetTrack *track in array) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
            _videoSize = videoSize;
        }
    }
    NSLog(@"videoSize(%f, %f)", videoSize.width, videoSize.height);
    if (videoSize.height >= videoSize.width) {
        NSLog(@"不能旋转");
        self.frame = fatherView.bounds;
        self.allowRotate = NO;
        _miniPortrait = YES;
    } else {
        NSLog(@"可以旋转");
        self.frame = fatherView.bounds;
        self.allowRotate = YES;
        _miniPortrait = NO;
    }
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    
    [self setUpPlayerView:view];
    self.AVItem = [AVPlayerItem playerItemWithURL:url];
    
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:_AVItem];
    } else {
        [_player replaceCurrentItemWithPlayerItem:_AVItem];
    }
    
    //设置静音模式也可播放声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
     
    [self addObserverAndNotification];
}

#pragma mark - 根据AVItem的值来添加、删除观察者
- (void)setAVItem:(AVPlayerItem *)AVItem
{
    if (_AVItem == AVItem) return;
    
    if (_AVItem) {
        [_AVItem removeObserver:self forKeyPath:@"status"];
        [_AVItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_AVItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_AVItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    
    _AVItem = AVItem;
    if (_AVItem) {
        //观察AVItem的属性
        [_AVItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_AVItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [_AVItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        [_AVItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - 根据tableView的值来添加、删除观察者
- (void)setTableView:(UITableView *)tableView
{
    if (_tableView == tableView) return;
    
    if (_tableView) {
        [_tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    _tableView = tableView;
    
    if (_tableView) {
        //观察tableView的滚动
        [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - 设置playerView
- (void)setUpPlayerView:(UIView *)playerView
{
    _playerView = playerView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    pan.maximumNumberOfTouches = 1;
    pan.minimumNumberOfTouches = 1;
    pan.delegate = self;
    
    [tap requireGestureRecognizerToFail:pan];
    [_playerView addGestureRecognizer:pan];
    [_playerView addGestureRecognizer:tap];
    //初始化player
    _player = [[AVPlayer alloc] init];
    //初始化layer
    _AVLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    _AVLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    [_playerView.layer addSublayer:_AVLayer];
    
    //添加控件
    [self setUpControlViews];
    
    [self addSubview:_playerView];
    
    [_playerView bringSubviewToFront:_toolBar];
    [_toolBar bringSubviewToFront:_playSlider];
    
    _isshowToolBarAndStatusBar = NO;
    _isLandscape = NO;
    _miniPortrait = !_allowRotate;//允许转屏则不是微博视频模式
    
    [self setUpConstraints];
    
    [MBProgressHUD showHUDToView:_playerView];
    
    _videoOrientation = MRTVideoOrientationPortrait;
    
    
}

#pragma mark - 设置allowRotate来控制转屏
- (void)setAllowRotate:(BOOL)allowRotate
{
    _allowRotate = allowRotate;
    //设置是否允许转屏
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //appDelegate.allowRotate = _allowRotate;
}

#pragma mark - 横竖屏变换通知
//当view添加到window上时  该方法不会执行，改用通知来实现

/*
 - (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
 {
 [super traitCollectionDidChange:previousTraitCollection];
 
 //CGRect bounds = [UIScreen mainScreen].bounds;
 
 NSLog(@"检测到屏幕旋转");
 //竖屏
 if (self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassCompact) {
 NSLog(@"当前竖屏");
 [self mas_remakeConstraints:^(MASConstraintMaker *make) {
 make.top.left.equalTo(@(0));
 make.width.equalTo(@(MRTScreen_Width));
 make.height.equalTo(@(MRTScreen_Height));
 }];
 [self layoutIfNeeded];
 } else {//横屏
 NSLog(@"当前横屏");
 [self mas_remakeConstraints:^(MASConstraintMaker *make) {
 make.top.left.equalTo(@(0));
 make.width.equalTo(@(MRTScreen_Height));
 make.height.equalTo(@(MRTScreen_Width));
 }];
 _AVLayer.frame = CGRectMake(0, 0, MRTScreen_Height, MRTScreen_Width);
 [self layoutIfNeeded];
 }
 }*/

- (void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    NSLog(@"物理设备方向:%ld", (long)orientation);
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    
    if (_allowRotate) {
        
        switch (orientation) {
            case UIDeviceOrientationPortrait: {
                NSLog(@"当前竖屏Portrait");
                _isLandscape = NO;
                //竖屏将toolBar背景调为透明
                _toolBar.backgroundColor = [UIColor clearColor];
                [_fullScreenButton setImage:[UIImage imageNamed:@"icon_fullscreen"] forState:UIControlStateNormal];
                
                //旋转状态栏
                //NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
                //[[UIApplication sharedApplication] setValue:orientationUnknown forKey:@"statusBarOrientation"];
                NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIApplication sharedApplication] setValue:orientationTarget forKey:@"statusBarOrientation"];
                //隐藏状态栏
                if ([_delegate respondsToSelector:@selector(shouldHideStatusBar:)]) {
                    [_delegate shouldHideStatusBar:NO];
                }
                [UIView animateWithDuration:0.3 animations:^{
                    self.transform = CGAffineTransformIdentity;
                    _toolBar.transform = CGAffineTransformIdentity;
                    [self removeFromSuperview];
                    [_fatherView addSubview:self];
                    self.frame = _fatherView.bounds;
                    //_toolBar.frame = CGRectMake(MRTScreen_Width - 40, 0, 40, MRTScreen_Height);
                } completion:^(BOOL finished) {
                    self.videoOrientation = MRTVideoOrientationPortrait;
                }];
                break;
            }
                
            case UIDeviceOrientationLandscapeLeft: {
                //横屏时下拉通知再关闭会在此调用设备旋转信息，此时若已经是横屏则直接返回，否则再设置视屏frame会出错
                if (_videoOrientation == MRTVideoOrientationLandscapeLeft) {
                    return;
                }
                NSLog(@"当前横屏LandscapeLeft");
                _isLandscape = YES;
                _toolBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                [_fullScreenButton setImage:[UIImage imageNamed:@"icon_window"] forState:UIControlStateNormal];
                //旋转状态栏
                //NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
                //[[UIApplication sharedApplication] setValue:orientationUnknown forKey:@"statusBarOrientation"];
                NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
                [[UIApplication sharedApplication] setValue:orientationTarget forKey:@"statusBarOrientation"];
                //隐藏状态栏
                if ([_delegate respondsToSelector:@selector(shouldHideStatusBar:)]) {
                    [_delegate shouldHideStatusBar:YES];
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    [self removeFromSuperview];
                    UIWindow *window = [UIApplication sharedApplication].delegate.window;
                    NSLog(@"window:%@",window);
                    [window addSubview:self];
                    if (_videoOrientation == MRTVideoOrientationLandscapeRight) {
                        CGAffineTransform transform = CGAffineTransformRotate(self.transform, M_PI);
                        self.transform = transform;
                    } else {
                        //self.frame = _fatherView.frame;
                        self.frame = CGRectMake( (MRTScreen_Height - MRTScreen_Width) * 0.5, - (MRTScreen_Height - MRTScreen_Width) * 0.5, MRTScreen_Width, MRTScreen_Height);
                        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
                        self.transform = transform;
                    }
                } completion:^(BOOL finished) {
                    self.videoOrientation = MRTVideoOrientationLandscapeLeft;
                    NSLog(@"%@", self);
                }];
                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                //横屏时下拉通知再关闭会在此调用设备旋转信息，此时若已经是横屏则直接返回，否则再设置视屏frame会出错
                if (_videoOrientation == MRTVideoOrientationLandscapeRight) {
                    return;
                }
                NSLog(@"当前横屏LandscapeRight");
                _isLandscape = YES;
                _toolBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                [_fullScreenButton setImage:[UIImage imageNamed:@"icon_window"] forState:UIControlStateNormal];
                
                //旋转状态栏
                //NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
                //[[UIApplication sharedApplication] setValue:orientationUnknown forKey:@"statusBarOrientation"];
                NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
                [[UIApplication sharedApplication] setValue:orientationTarget forKey:@"statusBarOrientation"];
                //隐藏状态栏
                if ([_delegate respondsToSelector:@selector(shouldHideStatusBar:)]) {
                    [_delegate shouldHideStatusBar:YES];
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    NSLog(@"%@", self);
                    [self removeFromSuperview];
                    //[[UIApplication sharedApplication].windows lastObject]以及keyWindow都不一定准确
                    UIWindow *window = [UIApplication sharedApplication].delegate.window;
                    NSLog(@"window:%@",window);
                    [window addSubview:self];
                    
                    if (_videoOrientation == MRTVideoOrientationLandscapeLeft) {
                        CGAffineTransform transform = CGAffineTransformRotate(self.transform, M_PI);
                        self.transform = transform;
                    } else {
                        //self.frame = _fatherView.frame;
                        self.frame = CGRectMake( (MRTScreen_Height - MRTScreen_Width) * 0.5, - (MRTScreen_Height - MRTScreen_Width) * 0.5, MRTScreen_Width, MRTScreen_Height);
                        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, - M_PI_2);
                        self.transform = transform;
                    }
                    
                } completion:^(BOOL finished) {
                    self.videoOrientation = MRTVideoOrientationLandscapeRight;
                    NSLog(@"%@", self);
                }];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - 全屏按钮切换
- (void)rotationScreen:(UIButton *)button
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBarAndStatusBar) object:nil];
    [self performSelector:@selector(hideToolBarAndStatusBar) withObject:nil afterDelay:3];
    if (_allowRotate) {//允许旋转表明是秒拍视频
        //如果开启转屏，强制旋转设备方向导致首页布局出现问题，所以此处采用单独transform视频view，kvo旋转状态栏，viewController控制状态栏的隐藏和显示
        /*
        UIInterfaceOrientation orientation;
        //如果是竖屏
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            orientation = UIInterfaceOrientationLandscapeRight;
        } else {
            orientation = UIInterfaceOrientationPortrait;
        }
        //使用NSInvocation调用UIDevice的私有方法setOrientation:强制转换
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSMethodSignature *signature = [UIDevice instanceMethodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int argu = orientation;
            [invocation setArgument:&argu atIndex:2];
            [invocation invoke];
        }*/
        
        
        //通过transform视图和旋转状态栏来旋转方向
        
        if (_isLandscape) {
            _isLandscape = NO;
            _toolBar.backgroundColor = [UIColor clearColor];
            [_fullScreenButton setImage:[UIImage imageNamed:@"icon_fullscreen"] forState:UIControlStateNormal];
        } else {
            _isLandscape = YES;
            _toolBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            [_fullScreenButton setImage:[UIImage imageNamed:@"icon_window"] forState:UIControlStateNormal];
        }
        
        
        //旋转状态栏
        //NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        //[[UIApplication sharedApplication] setValue:orientationUnknown forKey:@"statusBarOrientation"];
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIApplication sharedApplication] setValue:orientationTarget forKey:@"statusBarOrientation"];
        //隐藏状态栏,此处可不隐藏，设置为与toolBar一起显示、隐藏
        /*
        if ([_delegate respondsToSelector:@selector(shouldHideStatusBar:)]) {
            [_delegate shouldHideStatusBar:YES];
        }*/
        
        [self removeFromSuperview];
        //[[UIApplication sharedApplication].windows lastObject]以及keyWindow都不一定准确
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        //NSLog(@"window:%@",window);
        [window addSubview:self];
        [UIView animateWithDuration:0.3 animations:^{

            if (!_isLandscape) {
                CGAffineTransform transform = CGAffineTransformRotate(self.transform, M_PI);
                self.transform = transform;
            } else {
                //self.frame = _fatherView.frame;
                self.frame = CGRectMake( (MRTScreen_Height - MRTScreen_Width) * 0.5, - (MRTScreen_Height - MRTScreen_Width) * 0.5, MRTScreen_Width, MRTScreen_Height);
                CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, - M_PI_2);
                self.transform = transform;
            }
            
        } completion:^(BOOL finished) {
            if (_isLandscape) {
                self.videoOrientation = MRTVideoOrientationLandscapeLeft;
            }
            //NSLog(@"%@", self);
        }];
        
        //模态present控制器来旋转方向
        /*
        if (!_isLandscape) {
            if ([_delegate respondsToSelector:@selector(handleFullScreenAndHideStatusBar:orientationMask:)]) {
                _toolBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                [_fullScreenButton setImage:[UIImage imageNamed:@"icon_window"] forState:UIControlStateNormal];
                [_delegate handleFullScreenAndHideStatusBar:YES orientationMask:UIInterfaceOrientationMaskLandscapeLeft];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(handleFullScreenAndHideStatusBar:orientationMask:)]) {
                _toolBar.backgroundColor = [UIColor clearColor];
                [_fullScreenButton setImage:[UIImage imageNamed:@"icon_fullscreen"] forState:UIControlStateNormal];
                [_delegate handleFullScreenAndHideStatusBar:NO orientationMask:UIInterfaceOrientationMaskPortrait];
            }
        }*/
        
        
    } else {//微博视频
        if (_miniPortrait) {

            _miniPortrait = NO;
            //若为方形视频，则调整显示模式
            //if (_videoSize.width == _videoSize.height) {
            _AVLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            //}
            //竖屏将toolBar背景调为半透明
            _toolBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            [self removeFromSuperview];
            [window addSubview:self];
            self.frame = CGRectMake(0, 0, MRTScreen_Width, MRTScreen_Height);
            [_fullScreenButton setImage:[UIImage imageNamed:@"icon_window"] forState:UIControlStateNormal];
        } else {
            _miniPortrait = YES;
            //小窗口始终采用AspectFill
            _AVLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            //竖屏将toolBar背景调为透明
            _toolBar.backgroundColor = [UIColor clearColor];
            [self removeFromSuperview];
            [_fatherView addSubview:self];
            self.frame = _fatherView.bounds;
            //self.frame = CGRectMake(MRTScreen_Width * 0.1, 64, MRTScreen_Width * 0.8, MRTScreen_Height * 0.8);
            [_fullScreenButton setImage:[UIImage imageNamed:@"icon_fullscreen"] forState:UIControlStateNormal];
        }
    }
    
}

#pragma mark - 设置控件
- (void)setUpControlViews
{
    //toolBar
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 10, MRTScreen_Width, 40)];
    toolBar.backgroundColor = [UIColor clearColor];
    toolBar.userInteractionEnabled = YES;
    [_playerView addSubview:toolBar];
    _toolBar = toolBar;
    
    //播放按钮
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:playButton];
    _playButton = playButton;
    
    //当前播放时间
    UILabel *currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    currentTimeLabel.text = @"00:00";
    currentTimeLabel.font = [UIFont systemFontOfSize:13];
    currentTimeLabel.textColor = [UIColor whiteColor];
    [toolBar addSubview:currentTimeLabel];
    _currentTimeLabel = currentTimeLabel;
    
    //滑动条
    UISlider *playSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [playSlider setThumbImage:[UIImage imageNamed:@"icon_thumb_light"] forState:UIControlStateNormal];
    playSlider.value = 0;
    playSlider.minimumTrackTintColor = [UIColor orangeColor];
    playSlider.maximumTrackTintColor = [UIColor clearColor];
    [playSlider addTarget:self action:@selector(playerSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [playSlider addTarget:self action:@selector(playerSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [playSlider addTarget:self action:@selector(playerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [toolBar addSubview:playSlider];
    _playSlider = playSlider;
    
    //底部滑动条
    UIProgressView *playProgressBottom = [[UIProgressView alloc] initWithFrame:CGRectZero];
    playProgressBottom.hidden = YES;
    playProgressBottom.progress = 0;
    playProgressBottom.progressTintColor = [UIColor orangeColor];
    playProgressBottom.backgroundColor = [UIColor clearColor];
    
    [_playerView addSubview:playProgressBottom];
    _playProgressBottom = playProgressBottom;
    
    //进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    progressView.progressTintColor = [UIColor grayColor];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.progress = 0;
    [toolBar addSubview:progressView];
    _progressView = progressView;
    
    //底部进度条
    UIProgressView *progressViewBottom = [[UIProgressView alloc] initWithFrame:CGRectZero];
    progressViewBottom.hidden = YES;
    progressViewBottom.progressTintColor = [UIColor grayColor];
    progressViewBottom.backgroundColor = [UIColor clearColor];
    progressViewBottom.progress = 0;
    [_playerView addSubview:progressViewBottom];
    _progressViewBottom = progressViewBottom;
    
    [_playerView bringSubviewToFront:_playProgressBottom];

    
    //总时间
    UILabel *totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    totalTimeLabel.text = @"00:00";
    totalTimeLabel.font = [UIFont systemFontOfSize:13];
    totalTimeLabel.textColor = [UIColor whiteColor];
    [toolBar addSubview:totalTimeLabel];
    _totalTimeLabel = totalTimeLabel;
    
    //全屏按钮
    UIButton *fullscreenButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [fullscreenButton setImage:[UIImage imageNamed:@"icon_fullscreen"] forState:UIControlStateNormal];
    [fullscreenButton addTarget:self action:@selector(rotationScreen:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:fullscreenButton];
    _fullScreenButton = fullscreenButton;
    
    
    //暂停、播放提示栏
    UILabel *noticeBoard = [[UILabel alloc] initWithFrame:CGRectZero];
    noticeBoard.font = [UIFont systemFontOfSize:11];
    noticeBoard.textAlignment = NSTextAlignmentCenter;
    noticeBoard.backgroundColor = [UIColor colorWithRed:(203 / 255.0) green:(201 / 255.0) blue:(204 / 255.0) alpha:0.5];
    //noticeBoard.hidden = YES;
    [_playerView addSubview:noticeBoard];
    _noticeBoard = noticeBoard;
    
    //重播按钮
    UIButton *replayButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [replayButton setImage:[UIImage imageNamed:@"icon_replay_video"] forState:UIControlStateNormal];
    replayButton.hidden = YES;
    [replayButton addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView addSubview:replayButton];
    _replayButton = replayButton;

}

#pragma mark - 初始化约束
- (void)setUpConstraints
{
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_playerView.mas_left);
        make.bottom.mas_equalTo(_playerView.mas_bottom);
        make.right.mas_equalTo(_playerView.mas_right);
        make.height.mas_equalTo(40);
    }];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_toolBar.mas_left).mas_offset(12);
        make.centerY.mas_equalTo(_toolBar);
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_playButton.mas_right).offset(12);
        make.centerY.mas_equalTo(_playButton);
        make.width.mas_equalTo(37);
    }];
    
    
    [_fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_toolBar);
        make.right.mas_equalTo(_toolBar.mas_right).mas_offset(-12);
    }];
    
    [_totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_fullScreenButton.mas_left).mas_offset(-12);
        make.centerY.mas_equalTo(_toolBar);
        make.width.mas_equalTo(37);
    }];
    
    [_playSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_totalTimeLabel.mas_left).offset(-12);
        make.left.mas_equalTo(_currentTimeLabel.mas_right).offset(12);
        make.centerY.mas_equalTo(_currentTimeLabel);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_currentTimeLabel.mas_right).offset(12);
        make.right.mas_equalTo(_totalTimeLabel.mas_left).offset(-12);
        make.centerY.mas_equalTo(_playSlider).offset(1);
    }];
    
    [_replayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_playerView);
        make.centerX.mas_equalTo(_playerView);
    }];
    
    [_noticeBoard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_playerView.mas_top).mas_offset(40);
        make.left.mas_equalTo(_playerView);
        make.right.mas_equalTo(_playerView);
        make.height.mas_equalTo(0);
    }];
    
    [_progressViewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playerView);
        make.right.equalTo(_playerView);
        make.bottom.equalTo(_playerView).offset(0.5);
    }];
    
    [_playProgressBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playerView);
        make.right.equalTo(_playerView);
        make.bottom.equalTo(_playerView).offset(0.5);
    }];
}

#pragma mark - 播放、暂停
- (void)playOrPause:(UIButton *)button
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBarAndStatusBar) object:nil];
    [self performSelector:@selector(hideToolBarAndStatusBar) withObject:nil afterDelay:3];
    if (_isPlaying) {
        [self pause];
        _isPauseByUser = YES;
    } else {
        [self play];
    }
    
    [self showNoticeBoard];
}

- (void)play
{
    _isPlaying = YES;
    _isPauseByUser = NO;
    _isBuffering = NO;
    _disableAutoPlay = NO;
    [_player play];
    [_playButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
    
}

- (void)pause
{
    _isPlaying = NO;
    [_player pause];
    [_playButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
}

#pragma mark - 提示板的显示和隐藏
- (void)showNoticeBoard
{
    //避免连续点击时动画响应不及时，如果当前动画还没完成则删除当前动画执行新动画
    [_noticeBoard.layer removeAllAnimations];
    _noticeBoard.text = _isPlaying ? @"继续播放" : @"暂停播放";
    [_noticeBoard mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self hideNoticeBoard];
    }];
}

- (void)hideNoticeBoard
{
    [_noticeBoard mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
        [self layoutIfNeeded];
    } completion:nil];

}

#pragma mark - 滑动条相关
- (void)playerSliderTouchDown:(UISlider *)slider
{
    
    [self pause];
    [self cancelDelayHideToolBarAndStatusBar];
    
    [_playButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
}

- (void)playerSliderValueChanged:(UISlider *)slider
{
    _isSliding = YES;
    [self pause];
    
    if (_isReplayShow) {
        _isReplayShow = NO;
        _replayButton.hidden = YES;
    }
    
    CMTime newTime = CMTimeMakeWithSeconds(_playSlider.value, 1);
    //__weak typeof (self) weakSelf = self;
    [_AVItem seekToTime:newTime completionHandler:^(BOOL finished) {
        //[weakSelf play];
        //_isSliding = NO;
    }];
    _currentTimeLabel.text = [NSString convertTime:_playSlider.value];
}

- (void)playerSliderTouchUpInside:(UISlider *)slider
{
    _isSliding = NO;
    [self play];
    [self performSelector:@selector(hideToolBarAndStatusBar) withObject:nil afterDelay:3];
    //[_playButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
}


#pragma mark - 重播
- (void)replay:(UIButton *)button
{
    //隐藏按钮
    _replayButton.hidden = YES;
    _isReplayShow = NO;
    //跳转到起点
    CMTime begin = CMTimeMakeWithSeconds(0, 1);
    [_AVItem seekToTime:begin completionHandler:^(BOOL finished) {
        [self play];
    }];
}



#pragma mark - 添加observer和通知
- (void)addObserverAndNotification
{
    
    
    
    //观察播放进度
    [self monitoringPlayback:_AVItem];
    
    
    //添加通知
    //播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //添加进入后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    //添加屏幕旋转通知
    //要发送设备物理方向信息需要手动调用以下方法
    //并且在不需要时要手动停止
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

#pragma mark - 监测playback
- (void)monitoringPlayback:(AVPlayerItem *)item
{
    __weak typeof (self) weakSelf = self;
    
    //每秒执行1次
    NSLog(@"timeObserver地址:%p", _timeObserver);
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        float currentTime = CMTimeGetSeconds(item.currentTime);
        float totalTime = CMTimeGetSeconds(item.duration);
        //如果slider正在滑动则不更新
        if (!strongSelf.isSliding) {
            strongSelf.playSlider.value = currentTime;
            strongSelf.playProgressBottom.progress = currentTime / totalTime;
            strongSelf.currentTimeLabel.text = [NSString convertTime:currentTime];
        }
    }];
}

#pragma mark - 进入后台
- (void)didEnterBackground
{
    [self pause];
    self.disableAutoPlay = YES;
    //停止发送设备物理方向
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark - 从后台恢复
- (void)didBecomeActive
{
    //开始发送设备物理方向
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

#pragma mark - 播放完毕通知
- (void)playToEnd:(NSNotification *)notificaiton
{
    //显示重播按钮
    _replayButton.hidden = NO;
    _isReplayShow = YES;
}

#pragma mark - KVO观测
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == _AVItem) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if ([keyPath isEqualToString:@"status"]) {
            //获取当前status状态
            AVPlayerItemStatus status = [[change valueForKey:@"new"] integerValue];
            if (status == AVPlayerStatusReadyToPlay) {
                NSLog(@"ready to play!");
                //获取总帧数
                CMTime duration = item.duration;
                //转换成秒(value/scale)
                float totalTime = CMTimeGetSeconds(duration);
                //设置滑动条的最大值
                _playSlider.maximumValue = totalTime - 1;
                
                //设置总时间
                _totalTimeLabel.text = [NSString convertTime:totalTime];
                [MBProgressHUD hideHUDForView:_playerView];
                [self performSelector:@selector(hideToolBarAndStatusBar) withObject:nil afterDelay:3];
                if (!_disableAutoPlay) {
                    [self play];
                }
                
            } else if (status == AVPlayerStatusFailed) {
                NSLog(@"AVPlayerStatusFailed");
                [MBProgressHUD hideHUDForView:_playerView];
                [MBProgressHUD showMessage:@"播放失败，请重试！" toView:_playerView];
                __weak typeof (self) weakSelf = self;
                [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    __strong typeof (weakSelf) strongSelf = weakSelf;
                    [MBProgressHUD hideHUDForView:_playerView];
                    [strongSelf resetPlayer];
                    _isPlayerShow = NO;
                    [strongSelf removeFromSuperview];
                    
                }];
                
            } else if (status == AVPlayerStatusUnknown) {
                NSLog(@"AVPlayerStatusUnknown");
                [MBProgressHUD hideHUDForView:_playerView];
                [MBProgressHUD showMessage:@"播放失败，请重试！" toView:_playerView];
                __weak typeof (self) weakSelf = self;
                [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    __strong typeof (weakSelf) strongSelf = weakSelf;
                    [MBProgressHUD hideHUDForView:_playerView];
                    [strongSelf resetPlayer];
                    _isPlayerShow = NO;
                    [strongSelf removeFromSuperview];
                    
                }];
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            //获取缓冲数组
            NSArray *loadedTimeRanges = [_AVItem loadedTimeRanges];
            
            //  typedef struct {
            //    CMTime start;
            //    CMTime duration;
            //  } CMTimeRange;
            
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            //缓冲时间
            NSTimeInterval loadedSeconds = startSeconds + durationSeconds;
            //总时间
            float totalTime = CMTimeGetSeconds(_AVItem.duration);
            [_progressView setProgress:loadedSeconds / totalTime animated:YES];
            [_progressViewBottom setProgress:loadedSeconds / totalTime animated:YES];
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (_AVItem.playbackBufferEmpty) {
                NSLog(@"正在缓冲");
                _isBuffering = YES;
                [self bufferingSomeSecond];
                [MBProgressHUD showHUDToView:_playerView];
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
            if (_AVItem.playbackLikelyToKeepUp && _isBuffering){
                NSLog(@"缓冲完成");
                _isBuffering = NO;
                [MBProgressHUD hideHUDForView:_playerView];
            }
        }
    } else if (object == _tableView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            if (_isLandscape) return;
            //当tableView滚动时处理视频的播放和暂停
            [self handleVideoWithScrollOffset];
        }
    }
    
    
}

#pragma mark - 隐藏、显示toolBar
- (void)hideToolBarAndStatusBar
{
    _isshowToolBarAndStatusBar = NO;
    [_toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_playerView.mas_bottom).offset(_toolBar.height);
    }];
    
    [UIView animateWithDuration:0.1 animations:^{
        [self layoutIfNeeded];
        _toolBar.alpha = 0;
        _progressViewBottom.hidden = NO;
        _playProgressBottom.hidden = NO;
        if (_isLandscape) {
            //隐藏状态栏
            if ([_delegate respondsToSelector:@selector(shouldHideStatusBar:)]) {
                [_delegate shouldHideStatusBar:YES];
            }
        }
    }];
    
}

- (void)showToolBarAndStatusBar
{
    _isshowToolBarAndStatusBar = YES;
    
    [_toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_playerView.mas_bottom);
    }];
    
    
    [UIView animateWithDuration:0.1 animations:^{
        [self layoutIfNeeded];
        self.toolBar.alpha = 1;
        _progressViewBottom.hidden = YES;
        _playProgressBottom.hidden = YES;
        if (_isLandscape) {
            //隐藏状态栏
            if ([_delegate respondsToSelector:@selector(shouldHideStatusBar:)]) {
                [_delegate shouldHideStatusBar:NO];
            }
        }
    }];
}

//取消三秒后隐藏工具栏
- (void)cancelDelayHideToolBarAndStatusBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBarAndStatusBar) object:nil];
}

#pragma mark - 当tableView滚动时处理视频是否允许旋转和设置缓冲
- (void)handleVideoWithScrollOffset
{
    MRTStatusCell *cell = [_tableView cellForRowAtIndexPath:_indexPath];
    //NSLog(@"videoView_indexPath:%@", _indexPath);
    //NSLog(@"videoView_tableView:%@", _tableView);
    if (![_tableView.visibleCells containsObject:cell]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
            NSTimeInterval interval = 1; // set to  0 for default duration.
            _player.currentItem.preferredForwardBufferDuration = interval;
        }
        //[self pause];
        //NSLog(@"videoView滚动监测不允许旋转");
        //self.allowRotate = NO;
        //[self removeFromSuperview];
    } else if (_isPlayerShow){
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
            NSTimeInterval interval = 30; // set to  0 for default duration.
            _player.currentItem.preferredForwardBufferDuration = interval;
        }
        /*
        if (cell.statusFrame.status.videoPosterStr.length) {
            [cell.originalView.posterView addSubview:self];
            self.frame = cell.originalView.posterView.bounds;
        } else {
            [cell.retweetView.posterView addSubview:self];
            self.frame = cell.retweetView.posterView.bounds;
        }*/
        //NSLog(@"videoView滚动监测允许旋转");
        //self.allowRotate = !_miniPortrait;
        //[self play];
        
        
    }
}

#pragma mark - 缓冲时暂停一下载播放，如果还是不能播放，接着暂停，如此循环直到能播放
- (void)bufferingSomeSecond {
    _isBuffering = YES;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;//__block用于修饰要在block中使用并改变值的局部变量
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [_player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!_AVItem.isPlaybackLikelyToKeepUp) { [self bufferingSomeSecond]; }
    });
}

#pragma mark - layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    _AVLayer.frame = self.bounds;
}

#pragma mark - 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
    
}


#pragma mark - 触摸点击事件
/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1 && _isLandscape == NO) {
        UITouch *t = [touches anyObject];
        CGPoint location = [t locationInView:_playerView];
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.locations[key] = [NSValue valueWithCGPoint:location];
        
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1 && _isLandscape == NO) {
        UITouch *t = [touches anyObject];
        CGPoint newLocation = [t locationInView:_playerView];
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        NSValue *oldValue = self.locations[key];
        CGPoint oldLocation = oldValue.CGPointValue;
        _disdance = newLocation.x - oldLocation.x;
        CGPoint center = self.center;
        center.x += _disdance;
        self.center = center;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    
    NSLog(@"self.center.x:%f", self.center.x);
    if (fabs(self.center.x) > MRTScreen_Width) {
        [self resetPlayer];
        self.allowRotate = NO;
        _isPlayerShow = NO;
        [self removeFromSuperview];
        
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            CGPoint center = self.center;
            center.x = MRTScreen_Width * 0.5;
            self.center = center;
        }];
    }
}
*/
- (void)singleTap:(UIGestureRecognizer *)gesture
{
    NSLog(@"单击操作！");
    if (_isshowToolBarAndStatusBar) {
        [self cancelDelayHideToolBarAndStatusBar];
        [self hideToolBarAndStatusBar];
    } else {
        [self showToolBarAndStatusBar];
        [self performSelector:@selector(hideToolBarAndStatusBar) withObject:nil afterDelay:3];
    }
}

- (void)panGesture:(UIGestureRecognizer *)gesture
{
    //全屏时禁用滑动删除手势
    if (_isLandscape) return;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gesture locationInView:_playerView];
        _beginPoint = location;
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [gesture locationInView:_playerView];
        CGFloat disdance = location.x - _beginPoint.x;
        CGPoint center = self.center;
        center.x += disdance;
        self.center = center;
        /*
        _totalDisdance += disdance;
        CGFloat positiveTotalDistance = fabs(_totalDisdance);
        CGRect rect = self.fatherView.bounds;
        
        rect.size.width = (self.fatherView.bounds.size.width - positiveTotalDistance) / self.fatherView.bounds.size.width * self.fatherView.bounds.size.width;
        rect.size.height = (self.fatherView.bounds.size.width - positiveTotalDistance) / self.fatherView.bounds.size.width * self.fatherView.bounds.size.height;
        rect.origin.x = center.x - rect.size.width * 0.5;
        rect.origin.y = center.y - rect.size.height * 0.5;
        NSLog(@"positiveDistance:%f, 变化width:%f, 变化height:%f", positiveTotalDistance, rect.size.width, rect.size.height);
        self.frame = rect;
         */
        
        //CGAffineTransform transform = CGAffineTransformMakeTranslation(_disdance, 0);
        //CGFloat positiveDistance = fabs(_disdance);
        //self.transform = CGAffineTransformScale(transform, positiveDistance / MRTScreen_Width, positiveDistance / MRTScreen_Width);
        
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (fabs(self.center.x) > MRTScreen_Width) {
            [self cancelDelayHideToolBarAndStatusBar];
            [self resetPlayer];
            self.allowRotate = NO;
            _isPlayerShow = NO;
            [self removeFromSuperview];
            
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                //CGPoint center = self.center;
                //center.x = (MRTScreen_Width - MRTStatusCellMargin * 2) * 0.5;
                self.frame = self.fatherView.bounds;
                //self.center = center;
                
            }];
        }
    }
}


#pragma mark - 删除observer和通知
- (void)resetPlayer
{
    
    
    
    
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    //停止发送设备物理方向
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    //从通知中心删除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[_AVItem cancelPendingSeeks];
    //[_AVItem.asset cancelLoading];
    //_AVItem = nil;
    [_player pause];
    _isReplayShow = NO;
    [_AVLayer removeFromSuperlayer];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    
    _playSlider.value = 0;
    //_progressView.progress = 0;
    _currentTimeLabel.text = @"00:00";
    _totalTimeLabel.text = @"00:00";
    [_playSlider removeFromSuperview];
    [_currentTimeLabel removeFromSuperview];
    [_totalTimeLabel removeFromSuperview];
    [_playButton removeFromSuperview];
    [_progressView removeFromSuperview];
    [_fullScreenButton removeFromSuperview];
    [_toolBar removeFromSuperview];
    [_replayButton removeFromSuperview];
    [_playerView removeFromSuperview];
    
    
}

#pragma mark - dealloc
- (void)dealloc
{
    self.AVItem = nil;
    self.tableView = nil;
    [self resetPlayer];
}
@end
