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
#import "MRTOneViewController.h"
//#import "AFNetworking.h"
#import "MRTAccountStore.h"
#import "MRTAccount.h"
#import "MRTStatus.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
//#import "MRTHttpTool.h"
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

@interface MRTHomeViewController () <MRTCoverDelegate, MRTStatusCellDelegate>

@property (nonatomic, weak) MRTHomeTitle *titleButton;
@property (nonatomic, strong) MRTMenuViewController *menu;
@property (nonatomic, copy) NSMutableArray *statusFrames;
@end

@implementation MRTHomeViewController

#pragma mark 懒加载statusFrame数组
- (NSMutableArray *)statusFrames
{
    if (!_statusFrames) {
        _statusFrames = [NSKeyedUnarchiver unarchiveObjectWithFile:[self timelineArchivePath]];
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
    [MRTUserInfoTool userInfoWithSuccess:^(MRTUser *user) {
        //将导航栏标题设置为用户昵称
        //[self.titleButton setTitle:user.name forState:UIControlStateNormal];
        
        //获取账户
        MRTAccount *account = [MRTAccountStore account];
        
        //为账户昵称赋值
        account.name = user.name;
        
        //保存账户
        [MRTAccountStore saveAccount:account];
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@", error);
    }];
    
    //设置导航栏
    [self setUpNavigationBar];
    
    //添加下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWithOutCacheCheck)];
    //[self loadNewStatusCheckCache:YES];
    if (_statusFrames.count == 0) {
        [self loadNewStatusCheckCache:NO];
    }
    
    //添加上拉刷新旧微博控件
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreStatus)];
    
    //取消分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimeline) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_pop"] highLightedImage:[UIImage imageNamed:@"navigationbar_pop_highlighted"] target:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    
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
- (void)pop
{
    //创建新的控制
    MRTOneViewController *one = [[MRTOneViewController alloc] init];
    
    //push时隐藏系统自带tabBar
    one.hidesBottomBarWhenPushed = YES;
    
    //push新的控制器
    [self.navigationController pushViewController:one animated:YES];
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

#pragma mark 忽略缓存刷新方式

- (void)refreshWithOutCacheCheck
{
    [self loadNewStatusCheckCache:NO];
}

#pragma mark 请求最新的微博

- (void)loadNewStatusCheckCache:(BOOL)checkCache
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
        sinceId = [[self.statusFrames[0] status] idstr];
    }
    
    //发送get请求
    [MRTStatusTool newStatusWithSinceId:sinceId success:^(NSArray *statuses) {
        //显示微博更新数
        if (!checkCache) {
            [self showNewStatusCount:(int)statuses.count];
        }
        
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        
        //创建newStatusFrames数组
        NSMutableArray *newStatusFrames = [[NSMutableArray alloc] init];
        
        for (MRTStatus *status in statuses) {
            //创建statusFrame
            MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
            //给statusFrame的status属性赋值
            statusFrame.status = status;
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
        
    } checkCache:checkCache];
}

#pragma mark 加载更多之前的微博数据
- (void)loadMoreStatus
{
    NSUInteger count = self.statusFrames.count;
    if (count > 180) {
        //结束上拉刷新
        [self.tableView.mj_footer endRefreshing];
    } else {
        //新建一个空的maxId
        NSString *maxId = nil;
        
        if (self.statusFrames.count) {
            //返回小于等于max_id的微博，所以要减一
            long long max_id =[[[[self.statusFrames lastObject] status] idstr] longLongValue] - 1;
            maxId = [NSString stringWithFormat:@"%lld", max_id];
        }
        
        //发送get请求
        [MRTStatusTool moreStatusWithMaxId:maxId success:^(NSArray *statuses) {
            
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            
            //创建oldStatusFrames数组
            NSMutableArray *oldStatusFrames = [[NSMutableArray alloc] init];
            
            for (MRTStatus *status in statuses) {
                //创建statusFrame
                MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
                //给statusFrame的status属性赋值
                statusFrame.status = status;
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

#pragma mark - 保存timeline数组到缓存(doc目录)
- (void)saveTimeline
{
    NSString *path = [self timelineArchivePath];
    //[self.statusFrames removeAllObjects];
    [NSKeyedArchiver archiveRootObject:self.statusFrames toFile:path];
}

- (NSString *)timelineArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //从documentDirectories数组获取第一个，也是唯一文档目录路径
    NSString *documentDirectory = [documentDirectories firstObject];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"timeline.data"];
    
    return path;
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
    cell.statusToolBar.hidden = NO;
    
    //设置控制器为statusToolBar的代理，以便相应工具栏点击
    cell.delegate = self;
    //cell.textLabel.text = status.user.name;
    //[cell.imageView sd_setImageWithURL:status.user.profile_image_url placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    //cell.detailTextLabel.text = status.text;
    return cell;
}

//返回cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取statusFrame
    MRTStatusFrame *statusFrame = self.statusFrames[indexPath.row];
    
    //返回cell高度
    return statusFrame.cellHeight;
}

#pragma mark UITableViewDelegate 方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
    //不滚动到评论区
    commentVC.scorllToComment = NO;
    
    
    MRTStatusCell *statusCell = [self.tableView cellForRowAtIndexPath:indexPath];

    commentVC.statusCell = statusCell;
    
    //隐藏系统自带tabBar
    commentVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark 执行cell代理方法,点击工具栏
- (void)statusCell:(MRTStatusCell *)statusCell didClickButton:(NSInteger)index
{
    if (index == 0) {
        MRTWriteRepostController *writeRepostVC = [[MRTWriteRepostController alloc] init];
        
        writeRepostVC.statusCell = statusCell;
        
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeRepostVC];
        
        [self presentViewController:navVC animated:YES completion:nil];
        
    }
    
    if (index == 1) {
        //如果有评论就进入查看
        if (statusCell.statusFrame.status.comments_count) {
            MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
            commentVC.statusCell = statusCell;
            
            //滚动到评论区
            commentVC.scorllToComment = YES;
            
            //隐藏系统自带tabBar
            commentVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:commentVC animated:YES];
        } else {//没有评论就进入发评论界面
            MRTWriteCommentViewController *writeCommentVC = [[MRTWriteCommentViewController alloc] init];
            writeCommentVC.statusCell = statusCell;
            
            MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeCommentVC];
            
            [self presentViewController:navVC animated:YES completion:nil];
        }
    }
}

#pragma mark 执行cell代理方法,点击textView
- (void)textViewDidClickCell:(MRTStatusCell *)statusCell
{
    MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
    commentVC.statusCell = statusCell;
    
    //滚动到评论区
    commentVC.scorllToComment = NO;
    
    //隐藏系统自带tabBar
    commentVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}


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
