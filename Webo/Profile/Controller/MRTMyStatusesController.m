//
//  MRTMyStatusesController.m
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMyStatusesController.h"
#import "UIBarButtonItem+MRTItem.h"
#import "MRTHomeTitle.h"
#import "MRTCover.h"
#import "MRTPopMenu.h"
#import "MRTMenuViewController.h"
#import "MRTOneViewController.h"
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
#import "MRTCacheManager.h"
#import "MRTVideoPlayer.h"
#import "AppDelegate.h"
#import "NSString+MRTConvert.h"
#import "MRTCommentTitle.h"
#import "MRTOtherUser.h"
#import "MRTWebViewer.h"

@interface MRTMyStatusesController ()<MRTStatusCellDelegate>



@property (nonatomic, copy) NSMutableArray *statusFrames;
@property (nonatomic, weak) MRTVideoPlayer *videoView;
@property (nonatomic) BOOL ignoreScrollJudge;

@end

@implementation MRTMyStatusesController

#pragma mark 懒加载statusFrame数组

- (NSMutableArray *)statusFrames
{
    if (!_statusFrames) {
        _statusFrames = [[NSMutableArray alloc] init];
    }
    
    return _statusFrames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    //微博背景颜色
    self.tableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 450;
    
    if (_otherUser == nil) {
        //获取自己的用户信息
        _user = [MRTUserInfoTool userInfo];
    }
    
    
    [self setUpNavigationBar];
    
    //添加下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewStatuses)];
    //[self loadNewStatusCheckCache:YES];
    if (self.statusFrames.count == 0) {
        [self loadNewStatuses];
    }
    
    //添加上拉刷新旧微博控件
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreStatuses)];
    
    //取消分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 设置导航栏
- (void)setUpNavigationBar
{
    
    //设置title，显示该条微博用户名和头像
    UIImageView *imageView = [[UIImageView alloc] init];
    if (_otherUser) {
        [imageView sd_setImageWithURL:_otherUser.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    } else {
        [imageView sd_setImageWithURL:_user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
    
    NSString *titleStr = @"微博";
    //先计算title按钮尺寸
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionary];
    titleAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
    CGSize size = [titleStr sizeWithAttributes:titleAttrs];
    CGFloat imageW_H = 26;
    CGFloat margin = 6;
    CGRect frame = CGRectMake(0, 0, imageW_H + margin + ceil(size.width), imageW_H);
    MRTCommentTitle *titleButton = [[MRTCommentTitle alloc] initWithImage:imageView.image title:titleStr frame:frame];
    titleButton.titleFont = [UIFont boldSystemFontOfSize:16];
    
    
    //[titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    //设置左侧按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_leftTitle) {
        [left setTitle:_leftTitle forState:UIControlStateNormal];
    } else {
        [left setTitle:@"返回" forState:UIControlStateNormal];
    }
    
    left.titleLabel.font = [UIFont systemFontOfSize:15];
    [left setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [left setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [left setImage:[UIImage imageNamed:@"navigationbar_back_withtext"] forState:UIControlStateNormal];
    [left setImage:[UIImage imageNamed:@"navigationbar_back_withtext_highlighted"] forState:UIControlStateHighlighted];
    
    [left sizeToFit];
    [left addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left];
    //设置右侧按钮
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [right setImage:[UIImage imageNamed:@"navigationbar_more"] forState:UIControlStateNormal];
    [right setImage:[UIImage imageNamed:@"navigationbar_more_highlighted"] forState:UIControlStateHighlighted];
    [right sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
}

- (void)dismissSelf
{
    NSLog(@"调用dismissSelf");
    //取消三秒后隐藏工具栏，当刚刚点击视频调出工具栏时马上返回上个控制器，如果不取消隐藏工具栏的操作，会发生自动布局错误（布局toolBar）
    [_videoView cancelDelayHideToolBarAndStatusBar];
    _videoView.isPlayerShow = NO;
    _videoView.tableView = nil;
    [_videoView resetPlayer];
    _videoView.allowRotate = NO;
    
    [_videoView removeFromSuperview];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark 请求最新的微博

- (void)loadNewStatuses
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
    
    NSString *idstr = _otherUser ? _otherUser.idstr : _user.idstr;
    
    //发送get请求
    [MRTStatusTool newUserStatusWithUID:idstr SinceId:sinceId success:^(NSArray *statuses) {
        
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        
        //创建newStatusFrames数组
        NSMutableArray *newStatusFrames = [[NSMutableArray alloc] init];
        
        for (MRTStatus *status in statuses) {
            //创建statusFrame
            MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
            
            __weak typeof (self) weakSelf = self;
            NSURL *url = nil;
            if (status.urlStr.length) {
                
                url = [NSURL URLWithString:status.urlStr];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData *htmlData = [NSData dataWithContentsOfURL:url];
                    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                    NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                    status.videoPosterStr = videoPosterStr;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                        [weakSelf.tableView reloadData];
                    });
                    
                });
            } else if (status.retweeted_status.urlStr.length){
                
                url = [NSURL URLWithString:status.retweeted_status.urlStr];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData *htmlData = [NSData dataWithContentsOfURL:url];
                    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                    NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                    status.retweeted_status.videoPosterStr = videoPosterStr;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        statusFrame.status = status;
                        [weakSelf.tableView reloadData];
                    });
                    
                });
            } else {
                statusFrame.status = status;
            }
            
            //将statusFrame加入newStatusFrame数组
            [newStatusFrames addObject:statusFrame];
        }
        
        //根据statuses的长度创建一个indexSet
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statuses.count)];
        
        //将最新的微博数据插入最前面
        [self.statusFrames insertObjects:newStatusFrames atIndexes:indexSet];
        
        //刷新表格数据
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        //显示失败提示
        [MBProgressHUD showError:@"刷新失败"];
        
        NSLog(@"error:%@", error);
        
    }];
}

#pragma mark 加载更多之前的微博数据
- (void)loadMoreStatuses
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
        
        NSString *idstr = _otherUser ? _otherUser.idstr : _user.idstr;
        //发送get请求
        [MRTStatusTool moreUserStatusWithUID:idstr MaxId:maxId success:^(NSArray *statuses) {
            
            NSLog(@"此次获取旧微博%ld条", statuses.count);
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            
            //创建oldStatusFrames数组
            NSMutableArray *oldStatusFrames = [[NSMutableArray alloc] init];
            
            for (MRTStatus *status in statuses) {
                //创建statusFrame
                MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
                
                __weak typeof (self) weakSelf = self;
                NSURL *url = nil;
                if (status.urlStr.length) {
                    url = [NSURL URLWithString:status.urlStr];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSData *htmlData = [NSData dataWithContentsOfURL:url];
                        NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                        NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                        status.videoPosterStr = videoPosterStr;
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            statusFrame.status = status;
                            [weakSelf.tableView reloadData];
                        });
                        
                    });
                } else if (status.retweeted_status.urlStr.length){
                    url = [NSURL URLWithString:status.retweeted_status.urlStr];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSData *htmlData = [NSData dataWithContentsOfURL:url];
                        NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                        NSString *videoPosterStr = [NSString videoPicUrlFromString:htmlStr];
                        status.retweeted_status.videoPosterStr = videoPosterStr;
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            statusFrame.status = status;
                            [weakSelf.tableView reloadData];
                        });
                        
                    });
                } else {
                    statusFrame.status = status;
                }
                
                //将statusFrame加入到oldStatusFrame数组
                [oldStatusFrames addObject:statusFrame];
            }
            
            
            //加入到statusFrame
            [self.statusFrames addObjectsFromArray:oldStatusFrames];
            
            //刷新表格
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"加载失败"];
            
            NSLog(@"error:%@", error);
        }];
    }
    
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
    
    commentVC.leftTitle = @"返回";
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
            
            commentVC.leftTitle = @"返回";
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
    
    commentVC.leftTitle = @"返回";
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
- (void)playVideoWithUrl:(NSURL *)url onView:(UIView *)fatherView indexPath:(NSIndexPath *)indexPath
{
    
    MRTVideoPlayer *videoView = [MRTVideoPlayer sharedInstance];
    
    //UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    //[window addSubview:videoView];
    [fatherView addSubview:videoView];
    
    [videoView playWithUrl:url onView:fatherView tableView:(UITableView *)self.view indexPath:indexPath];
    _videoView = videoView;
    //_videoViewExist = YES;
    NSLog(@"播放器设置完成,地址:%@", url);
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
        NSLog(@"homeVC视频cell可见");
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


@end
