//
//  MRTHomeViewController.m
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTHomeViewController.h"
#import "UIBarButtonItem+MRTItem.h"
#import "MRTHomeTitle.h"
#import "MRTCover.h"
#import "MRTPopMenu.h"
#import "MRTMenuViewController.h"
#import "MRTAccountStore.h"
#import "MRTAccount.h"
#import "MRTStatus.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "MRTStatusTool.h"
#import "MRTUserInfoTool.h"
#import "MRTStatusCell.h"
#import "MRTStatusFrame.h"
#import "MRTCommentViewController.h"
#import "MRTNavigationController.h"
#import "MBProgressHUD+MRT.h"
#import "MRTWriteCommentViewController.h"
#import "MRTWriteRepostController.h"
#import "MRTVideoPlayer.h"
#import "AppDelegate.h"
#import "NSString+MRTConvert.h"
#import "MRTTimeLineStore.h"
#import "MRTVideoURL.h"
#import "MRTVideoFullScreenController.h"
#import "MRTVideoTransition.h"
#import "MRTVideoTransition.h"
#import "MRTQRcodeScannerController.h"
#import "MRTWebViewer.h"
#import "MRTTextViewController.h"

@interface MRTHomeViewController () <MRTCoverDelegate, MRTStatusCellDelegate, MRTVideoPlayerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) MRTHomeTitle *titleButton;
@property (nonatomic, strong) MRTMenuViewController *menu;
@property (nonatomic, strong) NSMutableArray *statusFrames;

@property (nonatomic, weak) MRTVideoPlayer *videoView;
@property (nonatomic) BOOL ignoreScrollJudge;
@property (nonatomic) BOOL hideStatusBar;//视频横屏时隐藏，小窗口显示
@property (nonatomic, strong) MRTVideoFullScreenController *videoFullScreenController;//视频全屏时的控制器
@end

@implementation MRTHomeViewController

#pragma mark 懒加载statusFrame数组

- (NSMutableArray *)statusFrames
{
    if (!_statusFrames) {
        _statusFrames = [NSKeyedUnarchiver unarchiveObjectWithFile:[MRTTimeLineStore timelineArchivePath]];
    }
    if (!_statusFrames) {
        _statusFrames = [[NSMutableArray alloc] init];
    }
    
    return _statusFrames;
}

- (MRTMenuViewController *)menu
{
    if (!_menu) {
        _menu = [[MRTMenuViewController alloc] init];
    }
    
    return _menu;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //微博背景颜色
    self.tableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    
    //获取当前用户昵称
    __weak typeof (self) weakSelf = self;
    [MRTUserInfoTool userInfoWithSuccess:^(MRTUser *user) {
        
        [MRTUserInfoTool saveUserInfo:user];
        
        //获取账户
        MRTAccount *account = [MRTAccountStore account];
        
        //为账户昵称赋值
        account.name = user.name;
        
        //保存账户
        [MRTAccountStore saveAccount:account];
        //设置导航栏
        [weakSelf setUpNavigationBar];
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@", error);
    }];
    
    //添加下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewStatus)];

    if (self.statusFrames.count == 0) {
        [self.tableView.mj_header beginRefreshing];
    }
    
    //添加上拉刷新旧微博控件
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreStatus)];
    
    //取消分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
#pragma mark - videoPlayer隐藏状态栏代理方法
- (void)shouldHideStatusBar:(BOOL)hideStatusBar
{
    _hideStatusBar = hideStatusBar;
    //手动更新状态栏
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - 处理video全屏代理方法
- (void)handleFullScreenAndHideStatusBar:(BOOL)hideStatusBar orientationMask:(UIInterfaceOrientationMask)orientationMask
{
    if (_videoView.isLandscape) {
        _videoView.isLandscape = NO;
        [self exitFullScreen];
    } else {
        _videoView.isLandscape = YES;
        [self enterFullScreenWithOrientationMask:orientationMask];
    }
}

- (void)enterFullScreenWithOrientationMask:(UIInterfaceOrientationMask)orientationMask
{
    UITableView *tableView = (UITableView *)self.view;
    CGRect cellRectInTableView = [tableView rectForRowAtIndexPath:_videoView.indexPath];
    CGRect cellRectInWindow = [tableView convertRect:cellRectInTableView toView:[tableView superview]];
    MRTStatusFrame *statusFrame = [self.statusFrames objectAtIndex:_videoView.indexPath.row];
    CGRect rect1;
    CGRect rect2;
    if (_videoView.fromOriginal) {
        rect1 = statusFrame.originalVideoPosterFrame;
        rect2 = statusFrame.originalViewFrame;
    } else {
        rect1 = statusFrame.retweetVideoPosterFrame;
        rect2 = statusFrame.retweetViewFrame;
    }
    
    CGRect videoRectInWindow = CGRectMake(cellRectInWindow.origin.x + rect1.origin.x +rect2.origin.x, cellRectInWindow.origin.y + rect1.origin.y +rect2.origin.y, _videoView.width, _videoView.height);
    /*
    CGRect videoFatherViewRectInSuperView = [_videoView.fatherView convertRect:_videoView.fatherView.frame toView:[_videoView.fatherView superview]];
    CGRect videoRectInCell = [_videoView.fatherView.superview convertRect:videoFatherViewRectInSuperView toView:[_videoView.fatherView.superview superview]];
    CGRect videoRectInWindow = videoRectInCell;
    videoRectInWindow.origin.x = cellRectInWindow.origin.x + videoRectInCell.origin.x;
    videoRectInWindow.origin.y = cellRectInWindow.origin.y + videoRectInCell.origin.y;
    */
    _videoView.beginningFrame = videoRectInWindow;
    NSLog(@"videoRectInWindow:(%f, %f, %f, %f)", videoRectInWindow.origin.x, videoRectInWindow.origin.y, videoRectInWindow.size.width, videoRectInWindow.size.height);
    MRTVideoFullScreenController *fullScreenController = [[MRTVideoFullScreenController alloc] init];
    fullScreenController.orientationMask = orientationMask;
    fullScreenController.hideStatusBar = YES;
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        fullScreenController.modalPresentationStyle = UIModalPresentationFullScreen;
    } else {
        fullScreenController.modalPresentationStyle = UIModalPresentationCustom;
    }
    //fullScreenController.transitioningDelegate = self;
    //传递状态栏控制权，只有UIModalPresentationFullScreen状态会直接将控制权传递给presentedController，此处设为YES，任何情况都传递
    fullScreenController.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:fullScreenController animated:NO completion:nil];
    _videoFullScreenController = fullScreenController;
}

- (void)exitFullScreen
{
    [self.videoFullScreenController dismissViewControllerAnimated:NO completion:nil];
    
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[MRTVideoTransition alloc] initWithVideoView:_videoView transionType:MRTVideoTransitionTypeEnter];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[MRTVideoTransition alloc] initWithVideoView:_videoView transionType:MRTVideoTransitionTypeExit];
}


#pragma mark - 状态栏隐藏
- (BOOL)prefersStatusBarHidden
{
    return _hideStatusBar;
}

#pragma mark - 是否允许控制器旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //从扫描界面返回需要删除导航栏黑色透明背景
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    //[self setUpNavigationBar];
    _ignoreScrollJudge = NO; //还原滚动暂停
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"首页  viewDidAppear");
    [super viewDidAppear:animated];
    if (_quickLaunchType == MRTQuickLaunchTypeScan) {
        NSLog(@"homeView执行scan");
        [self scan];
        
    } else if (_quickLaunchType == MRTQuickLaunchTypeWrite) {
        MRTTextViewController *textVC = [[MRTTextViewController alloc] init];
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:textVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }
    _quickLaunchType = MRTQuickLaunchTypeFinished;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 设置导航栏
- (void)setUpNavigationBar
{
    
    //左边按钮
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_friendsearch"] highLightedImage:[UIImage imageNamed:@"navigationbar_friendsearch_highlighted"] target:self action:@selector(friendSearch)  forControlEvents:UIControlEventTouchUpInside];
    //右边按钮
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_pop"] highLightedImage:[UIImage imageNamed:@"navigationbar_pop_highlighted"] target:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    
    //标题
    MRTHomeTitle *titleButton = [MRTHomeTitle buttonWithType:UIButtonTypeCustom];
    _titleButton = titleButton;
    
    //条件为真会返回[MRTAccountStore account].name
    NSString *title = [MRTAccountStore account].name ? :@"首页";
    [titleButton setTitle:title forState:UIControlStateNormal];
    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_up"] forState:UIControlStateSelected];
    
    //高亮时不需要调整图片
    titleButton.adjustsImageWhenHighlighted = NO;
    
    [titleButton addTarget:self action:@selector(menuTitleClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //将titleView设置为titleButton
    self.navigationItem.titleView = titleButton;
}

#pragma mark 左按钮调用方法
- (void)friendSearch
{
    NSLog(@"%s", __func__);
}

#pragma mark 右按钮调用方法
- (void)scan
{
    MRTQRcodeScannerController *scanner = [[MRTQRcodeScannerController alloc] init];
    
    [self.navigationController pushViewController:scanner animated:YES];
}



#pragma mark 标题调用方法
- (void)menuTitleClick:(UIButton *)button
{
    //巧妙地在选中与被选中的状态中切换
    button.selected = !button.selected;
    
    //弹出蒙板
    MRTCover *cover = [MRTCover show];
    cover.delegate = self;
    
    //弹出菜单
    CGFloat popX = (self.view.width - 200) * 0.5;
    CGFloat popY = 55;
    CGFloat popWidth = 200;
    CGFloat popHeight = popWidth;
    MRTPopMenu *menu = [MRTPopMenu showInRect:CGRectMake(popX, popY, popWidth, popHeight)];
    menu.contentView = self.menu.view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)coverDidClick:(MRTCover *)cover
{
    //隐藏弹出菜单
    [MRTPopMenu hide];
    
    _titleButton.selected = NO;
}


#pragma mark 请求最新的微博

- (void)loadNewStatus
{
    
    NSUInteger count = self.statusFrames.count;
    if (count >= 180) {
        for (NSUInteger i = count; i > count - 20; i--) {
            
            [self.statusFrames removeObjectAtIndex:i - 1];
        }
    }
    //创建一个空sinceId
    NSString *sinceId = nil;
    
    //载入since_id之后的新微博数据
    if (self.statusFrames.count) {
        //将since_id设置为当前已保存的最新微博的idstr，idstr越大数据越新
        MRTStatusFrame *statusFrame = self.statusFrames[0];
        
        sinceId = [statusFrame.status idstr];
    }
    
    //发送get请求
    [MRTStatusTool newStatusWithSinceId:sinceId success:^(NSArray *statuses) {
        
        
        //创建newStatusFrames数组，先借用statuses数组，方便到时候进行替换
        NSMutableArray *newStatusFrames = [statuses mutableCopy];
        //由于并发顺序不定，所以采用替换计数，替换完statuses数组时开始reloadData
        __block NSInteger replaceCount = 0;
        //替换时使用的并发线程
        dispatch_queue_t addDataQueue = dispatch_queue_create("com.mrtanis.addNewDataQueue", DISPATCH_QUEUE_CONCURRENT);
        
        for (int i = 0; i < statuses.count; i++) {
           __weak typeof (self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __strong typeof (weakSelf) strongSelf = weakSelf;
                //创建statusFrame
                MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
                MRTStatus *status = statuses[i];

                NSURL *url = nil;
                if (status.urlStr.length) {
                    url = [NSURL URLWithString:status.urlStr];
                    NSData *htmlData = [NSData dataWithContentsOfURL:url];
                    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                    NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                    status.videoPosterStr = videoPosterStr;
                    MRTVideoURL *video = [MRTVideoURL new];
                    video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                    status.video = video;
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                    //});
 
                } else if (status.retweeted_status.urlStr.length){
                    
                    url = [NSURL URLWithString:status.retweeted_status.urlStr];
                    NSData *htmlData = [NSData dataWithContentsOfURL:url];
                    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                    NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                    status.retweeted_status.videoPosterStr = videoPosterStr;
                    MRTVideoURL *video = [MRTVideoURL new];
                    video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                    status.retweeted_status.video = video;
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                    //});
                } else {
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                    //});
                }
        
                //将statusFrame加入newStatusFrame数组
                dispatch_barrier_async(addDataQueue, ^{
                    [newStatusFrames replaceObjectAtIndex:i withObject:statusFrame];
                    replaceCount ++;
                    if (replaceCount == statuses.count) {
                        //根据statuses的长度创建一个indexSet
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statuses.count)];
                        
                        //将最新的微博数据插入最前面
                        [strongSelf.statusFrames insertObjects:newStatusFrames atIndexes:indexSet];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //结束下拉刷新
                            [self.tableView.mj_header endRefreshing];
                            //显示微博更新数
                            [self showNewStatusCount:(int)statuses.count];
                            //刷新表格数据
                            [strongSelf.tableView reloadData];
                        });
                        [strongSelf saveTimeline];
                    }
                });
                
            });
        }
    } failure:^(NSError *error) {
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        //显示失败提示
        [MBProgressHUD showError:@"刷新失败"];
        
        NSLog(@"error:%@", error);
        
    }];
    
}

#pragma mark 加载更多之前的微博数据
- (void)loadMoreStatus
{
    
    NSUInteger count = self.statusFrames.count;
    NSLog(@"微博数据达到%ld条", count);
    if (count > 180) {
        //结束上拉刷新
        [self.tableView.mj_footer endRefreshing];
    } else {
        //新建一个空的maxId
        NSString *maxId = nil;
        
        if (self.statusFrames.count) {
            //返回小于等于max_id的微博，所以要减一
            MRTStatusFrame *statusFrame = [self.statusFrames lastObject];
            long long max_id =[[statusFrame.status idstr] longLongValue] - 1;
            maxId = [NSString stringWithFormat:@"%lld", max_id];
        }
        NSLog(@"maxId:%@", maxId);
        //发送get请求
        [MRTStatusTool moreStatusWithMaxId:maxId success:^(NSArray *statuses) {
            
            NSLog(@"此次获取旧微博%ld条", statuses.count);
            
            
            //创建oldStatusFrames数组
            NSMutableArray *oldStatusFrames = [statuses mutableCopy];
            
            //由于并发顺序不定，所以采用替换计数，替换完statuses数组时开始reloadData
            __block NSInteger replaceCount = 0;
            //替换时使用的并发线程
            dispatch_queue_t addDataQueue = dispatch_queue_create("com.mrtanis.addPastDataQueue", DISPATCH_QUEUE_CONCURRENT);
            
            for (int i = 0; i < statuses.count; i++) {
                
                __weak typeof (self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    __strong typeof (weakSelf) strongSelf = weakSelf;
                    
                    //创建statusFrame
                    MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
                    MRTStatus *status = statuses[i];
                    
                    NSURL *url = nil;
                    if (status.urlStr.length) {
                        url = [NSURL URLWithString:status.urlStr];
                        NSData *htmlData = [NSData dataWithContentsOfURL:url];
                        NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                        NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                        status.videoPosterStr = videoPosterStr;
                        MRTVideoURL *video = [MRTVideoURL new];
                        video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                        status.video = video;
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                        //});
                        
                    } else if (status.retweeted_status.urlStr.length){
                        
                        url = [NSURL URLWithString:status.retweeted_status.urlStr];
                        NSData *htmlData = [NSData dataWithContentsOfURL:url];
                        NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                        NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                        status.retweeted_status.videoPosterStr = videoPosterStr;
                        MRTVideoURL *video = [MRTVideoURL new];
                        video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                        status.retweeted_status.video = video;
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                        //});
                    } else {
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                        //});
                    }
                    
                    //将statusFrame加入newStatusFrame数组
                    dispatch_barrier_async(addDataQueue, ^{
                        [oldStatusFrames replaceObjectAtIndex:i withObject:statusFrame];
                        replaceCount ++;
                        if (replaceCount == statuses.count) {
                            
                            //将更早的的微博数据插入最后面
                            [strongSelf.statusFrames addObjectsFromArray:oldStatusFrames];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //结束上拉刷新
                                [self.tableView.mj_footer endRefreshing];

                                //刷新表格数据
                                [strongSelf.tableView reloadData];
                            });
                            [strongSelf saveTimeline];
                        }
                    });
                    
                });
            }
            
        } failure:^(NSError *error) {
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"加载失败"];
            
            NSLog(@"error:%@", error);
        }];
    }

}

#pragma mark 点击首页刷新
- (void)refresh
{
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark 显示刷新微博数
- (void)showNewStatusCount:(int)count
{
    
    //没有新微博则不显示
    if (!count) return;
    
    //label初始位置隐藏在导航栏内
    CGFloat width = self.view.width;
    CGFloat height = 35;
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame) - height;
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    countLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]];
    countLabel.text = [NSString stringWithFormat:@"更新了%d条微博", count];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.textColor = [UIColor whiteColor];
    
    //将label插入到导航栏下面
    [self.navigationController.view insertSubview:countLabel belowSubview:self.navigationController.navigationBar];
    //加入动画
    [UIView animateWithDuration:0.25 animations:^{
        
        //向下平移，距离为height
        countLabel.transform = CGAffineTransformMakeTranslation(0, height);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
            //恢复label最初的位置
            countLabel.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            //将label移除
            [countLabel removeFromSuperview];
        }];
    }];
}

#pragma mark - 进入后台
- (void)didEnterBackground
{
    /*
    if (_videoView) {
        [_videoView pause];
        _videoView.disableAutoPlay = YES;
    }*/
    //[self deleteTimeline];
}

#pragma mark - 保存timeline数组到缓存(doc目录)
- (void)saveTimeline
{
    [MRTTimeLineStore saveTimeLine:self.statusFrames];
    
}

- (void)deleteTimeline
{
    [MRTTimeLineStore deleteTimeLine];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.statusFrames.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    MRTStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[MRTStatusCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    MRTStatusFrame *statusFrame = self.statusFrames[indexPath.row];
    
    cell.statusFrame = statusFrame;
    cell.indexPath = indexPath;
    cell.statusToolBar.hidden = NO;
    
    //设置控制器为statusToolBar的代理，以便相应工具栏点击
    cell.delegate = self;
    //cell.textLabel.text = status.user.name;
    //[cell.imageView sd_setImageWithURL:status.user.profile_image_url placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    //cell.detailTextLabel.text = status.text;
    return cell;
}



#pragma mark UITableViewDelegate 方法
//返回cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取statusFrame
    MRTStatusFrame *statusFrame = self.statusFrames[indexPath.row];
    
    //返回cell高度
    return statusFrame.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
    
    commentVC.leftTitle = @"首页";
    //不滚动到评论区
    commentVC.scorllToComment = NO;

    MRTStatusCell *statusCell = [self.tableView cellForRowAtIndexPath:indexPath];

    commentVC.statusFrame = statusCell.statusFrame;
    
    if (_videoView.isPlayerShow && _videoView.indexPath == indexPath) {
        NSLog(@"给子控制器视频属性赋值");
        _ignoreScrollJudge = YES; //忽略滚动暂停
        [_videoView removeFromSuperview];
        _videoView.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        commentVC.videoView = _videoView;
    }
    
    //隐藏系统自带tabBar
    commentVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:commentVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRTStatusFrame *statusFrame = self.statusFrames[indexPath.row];
    if (statusFrame.status.videoPosterStr.length) {
        NSLog(@"index：%ld,情况1", indexPath.row);
        if ([[NSDate date] compare:statusFrame.status.video.expires_date] == NSOrderedAscending) {
            NSLog(@"index：%ld,情况1未过期返回", indexPath.row);
            return;
        } else {
            NSLog(@"index：%ld,情况1加载", indexPath.row);
            __weak typeof (self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:statusFrame.status.urlStr]];
                
                NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                //NSLog(@"htmlStr:%@", htmlStr);
                
                MRTVideoURL *video = [MRTVideoURL new];
                video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                statusFrame.status.video = video;
                
                [weakSelf.statusFrames replaceObjectAtIndex:indexPath.row withObject:statusFrame];
                
            });
        }
        
    } else if (statusFrame.status.retweeted_status.videoPosterStr.length) {
        NSLog(@"index:%ld,情况2", indexPath.row);
        if ([[NSDate date] compare:statusFrame.status.retweeted_status.video.expires_date] == NSOrderedAscending) {
            NSLog(@"index:%ld,情况2未过期返回", indexPath.row);
            return;
        } else {
            NSLog(@"index:%ld,情况2加载", indexPath.row);
            __weak typeof (self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:statusFrame.status.retweeted_status.urlStr]];
                
                NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                //NSLog(@"htmlStr:%@", htmlStr);
                
                MRTVideoURL *video = [MRTVideoURL new];
                video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                statusFrame.status.retweeted_status.video = video;
                
                [weakSelf.statusFrames replaceObjectAtIndex:indexPath.row withObject:statusFrame];
            });
        }
        
    }
}

#pragma mark 执行cell代理方法,点击工具栏
- (void)statusCell:(MRTStatusFrame *)statusFrame didClickButton:(NSInteger)index indexPath:(NSIndexPath *)indexPath
{
    if (index == 0) {
        MRTWriteRepostController *writeRepostVC = [[MRTWriteRepostController alloc] init];
        
        writeRepostVC.statusFrame = statusFrame;
        
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeRepostVC];
        
        [self presentViewController:navVC animated:YES completion:nil];
        
    }
    
    if (index == 1) {
        //如果有评论就进入查看
        if (statusFrame.status.comments_count) {
            MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
            
            commentVC.leftTitle = @"首页";
            commentVC.statusFrame = statusFrame;
            
            //滚动到评论区
            commentVC.scorllToComment = YES;
            
            //隐藏系统自带tabBar
            commentVC.hidesBottomBarWhenPushed = YES;
            
            if (_videoView.isPlayerShow && _videoView.indexPath == indexPath) {
                NSLog(@"给子控制器视频属性赋值");
                _ignoreScrollJudge = YES; //忽略滚动暂停
                [_videoView removeFromSuperview];
                _videoView.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                
                commentVC.videoView = _videoView;
            }
            
            [self.navigationController pushViewController:commentVC animated:YES];
        } else {//没有评论就进入发评论界面
            MRTWriteCommentViewController *writeCommentVC = [[MRTWriteCommentViewController alloc] init];
            writeCommentVC.statusFrame = statusFrame;
            
            MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeCommentVC];
            
            [self presentViewController:navVC animated:YES completion:nil];
        }
    }
}

#pragma mark 执行cell代理方法,点击textView
- (void)textViewDidClickCell:(MRTStatusFrame *)statusFrame indexPath:(NSIndexPath *)indexPath
{
    MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
    
    commentVC.leftTitle = @"首页";
    commentVC.statusFrame = statusFrame;
    
    //滚动到评论区
    commentVC.scorllToComment = NO;
    
    //隐藏系统自带tabBar
    commentVC.hidesBottomBarWhenPushed = YES;
    
    if (_videoView.isPlayerShow && _videoView.indexPath == indexPath) {
        NSLog(@"给子控制器视频属性赋值");
        _ignoreScrollJudge = YES; //忽略滚动暂停
        [_videoView removeFromSuperview];
        _videoView.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        commentVC.videoView = _videoView;
    }
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark 点击视频链接代理方法
- (void)playVideoOnView:(UIView *)fatherView indexPath:(NSIndexPath *)indexPath fromOriginal:(BOOL)fromOriginal
{
    MRTStatusFrame *statusFrame = self.statusFrames[indexPath.row];
    if (fromOriginal) {
        if (statusFrame.status.video.videoUrl.absoluteString.length) {
            NSLog(@"statusFrame.status.video.videoUrl.absoluteString:%@", statusFrame.status.video.videoUrl.absoluteString);
            MRTVideoPlayer *videoView = [MRTVideoPlayer sharedInstance];
            videoView.fromOriginal = YES;
            videoView.delegate = self;
            
            [fatherView addSubview:videoView];
            [videoView playWithUrl: statusFrame.status.video.videoUrl onView:fatherView tableView:(UITableView *)self.view indexPath:indexPath];
            _videoView = videoView;
        } else {
           __weak typeof (self) weakSelf = self; dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               __strong typeof (weakSelf) strongSelf = weakSelf;
                NSURL *url = [NSURL URLWithString:statusFrame.status.urlStr];
                NSData *htmlData = [NSData dataWithContentsOfURL:url];
                NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
               dispatch_async(dispatch_get_main_queue(), ^{
                   MRTVideoPlayer *videoView = [MRTVideoPlayer sharedInstance];
                   videoView.fromOriginal = NO;
                   videoView.delegate = strongSelf;
                   MRTVideoURL *video = [MRTVideoURL new];
                   video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                   statusFrame.status.video = video;
                   [fatherView addSubview:videoView];
                   [videoView playWithUrl:video.videoUrl onView:fatherView tableView:(UITableView *)strongSelf.view indexPath:indexPath];
                   _videoView = videoView;
               });
               [weakSelf.statusFrames replaceObjectAtIndex:indexPath.row withObject:statusFrame];
            });
        }
    } else {
        if (statusFrame.status.retweeted_status.video.videoUrl.absoluteString.length) {
            NSLog(@"statusFrame.status.retweeted_status.video.videoUrl.absoluteString:%@", statusFrame.status.retweeted_status.video.videoUrl.absoluteString);
            MRTVideoPlayer *videoView = [MRTVideoPlayer sharedInstance];
            videoView.delegate = self;
            
            [fatherView addSubview:videoView];
            [videoView playWithUrl:statusFrame.status.retweeted_status.video.videoUrl onView:fatherView tableView:(UITableView *)self.view indexPath:indexPath];
            _videoView = videoView;
        } else {
            __weak typeof (self) weakSelf = self; dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __strong typeof (weakSelf) strongSelf = weakSelf;
                NSURL *url = [NSURL URLWithString:statusFrame.status.retweeted_status.urlStr];
                NSData *htmlData = [NSData dataWithContentsOfURL:url];
                NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    MRTVideoPlayer *videoView = [MRTVideoPlayer sharedInstance];
                    videoView.delegate = strongSelf;
                    MRTVideoURL *video = [MRTVideoURL new];
                    video.videoUrl = [NSURL URLWithString:[NSString videoUrlFromString:htmlStr]];
                    statusFrame.status.retweeted_status.video = video;
                    [fatherView addSubview:videoView];
                    [videoView playWithUrl:video.videoUrl onView:fatherView tableView:(UITableView *)strongSelf.view indexPath:indexPath];
                    _videoView = videoView;
                });
                
                
                [strongSelf.statusFrames replaceObjectAtIndex:indexPath.row withObject:statusFrame];
            });
        }
    }
    
    //_videoViewExist = YES;
    //NSLog(@"播放器设置完成,地址:%@", url);
}

#pragma mark 点击url代理方法
- (void)clickURL:(NSURL *)url
{
    MRTWebViewer *webViewer = [[MRTWebViewer alloc] initWithURL:url];
    
    [self.navigationController pushViewController:webViewer animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UITableView *tableView = (UITableView *)self.view;
    MRTStatusCell *cell = [tableView cellForRowAtIndexPath:_videoView.indexPath];
    if (![tableView.visibleCells containsObject:cell]) {
        if (_videoView.isPlaying && !_ignoreScrollJudge) {
            [_videoView pause];
            NSLog(@"homeVC执行暂停");
        }
        [_videoView removeFromSuperview];
        _videoView.allowRotate = NO;
        
    } else if (_videoView.isPlayerShow) {
        //NSLog(@"homeVC视频cell可见");
        CGRect cellRectInTableView = [tableView rectForRowAtIndexPath:_videoView.indexPath];
        CGRect cellRectInWindow = [tableView convertRect:cellRectInTableView toView:[tableView superview]];
        NSLog(@"cellRectInWindow:(%f, %f, %f, %f)", cellRectInWindow.origin.x, cellRectInWindow.origin.y, cellRectInWindow.size.width, cellRectInWindow.size.height);
        NSLog(@"videoView.fatherView：%@", _videoView.fatherView);
        UIView *fatherView;
        if (cell.statusFrame.status.videoPosterStr) {
            fatherView = cell.originalView.posterView;
        } else {
            fatherView = cell.retweetView.posterView;
        }
        [fatherView addSubview:_videoView];
        _videoView.frame = fatherView.bounds;
        _videoView.fatherView = fatherView;
        _videoView.allowRotate = !_videoView.miniPortrait;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (!_videoView.isPlaying && !_videoView.isReplayShow) {
        NSLog(@"scrollViewDidEndDecelerating");
        UITableView *tableView = (UITableView *)self.view;
        MRTStatusCell *cell = [tableView cellForRowAtIndexPath:_videoView.indexPath];
        if ([tableView.visibleCells containsObject:cell]) {
            NSLog(@"scrollViewDidEndDecelerating_andPlay");
            [_videoView play];
        }
    }
}


/*
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    
    NSLog(@"将要旋转屏幕");
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //
    } completion:nil];
    
}*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
