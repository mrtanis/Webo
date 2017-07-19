//
//  MRTCommentViewController.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentViewController.h"
#import "UIImageView+WebCache.h"
#import "MRTStatusCell.h"
#import "MRTCommentTitle.h"
#import "MJRefresh.h"
#import "MRTComment.h"
#import "MRTCommentFrame.h"
#import "MRTCommentTool.h"
#import "MRTCommentCell.h"
#import "MRTCommentToolBar.h"
#import "MRTWriteCommentViewController.h"
#import "MRTWriteRepostController.h"
#import "MRTNavigationController.h"
#import "MRTSwitchBar.h"
#import "MBProgressHUD+MRT.h"

@interface MRTCommentViewController ()<UITableViewDataSource,UITableViewDelegate, MRTCommentToolBarDelegate, MRTSwitchBarDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *commentFrames;
@property (nonatomic, copy) NSMutableArray *repostFrames;
@property (nonatomic, weak) MRTCommentToolBar *toolBar;

@property (nonatomic, strong) MRTSwitchBar *switchBarOnTableView;
@property (nonatomic, weak) MRTSwitchBar *switchBarOnMainView;

@property (nonatomic) BOOL switchFlag;


@end

@implementation MRTCommentViewController

//懒加载commentFrames数组
- (NSMutableArray *)commentFrames
{
    if (!_commentFrames) {
        _commentFrames = [NSMutableArray array];
    }
    
    return _commentFrames;
}

//懒加载repostFrames数组
- (NSMutableArray *)repostFrames
{
    if (!_repostFrames) {
        _repostFrames = [NSMutableArray array];
    }
    
    return _repostFrames;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //默认显示评论
    _switchFlag = NO;
    
    CGRect rect = self.view.frame;
    rect.size.height -= 35;
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    
    //微博背景颜色
    tableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    _tableView = tableView;
    
    //设置导航栏
    [self setUpNavigationBar];
    //设置工具栏
    [self setUpToolBar];
    //设置评论转发切换栏
    [self setUpSwitchBar];
    //添加下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewComment)];
    [self loadNewComment];
    self.tableView.mj_header.refreshingAction = @selector(loadNewRepost);
    //添加上拉刷新旧评论控件
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreComment)];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

#pragma mark 设置导航栏
- (void)setUpNavigationBar
{
    //设置title，显示该条微博用户名和头像
    UIImage *image = self.statusCell.originalView.iconView.image;
    NSString *titleStr = self.statusCell.originalView.nameLabel.text;
    //先计算title按钮尺寸
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionary];
    titleAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    CGSize size = [titleStr sizeWithAttributes:titleAttrs];
    CGFloat imageW_H = 26;
    CGFloat margin = 6;
    CGRect frame = CGRectMake(0, 0, imageW_H + margin + size.width, imageW_H);
    MRTCommentTitle *titleButton = [[MRTCommentTitle alloc] initWithImage:image title:titleStr frame:frame];
    
    
    //[titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    //设置左侧按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [left setTitle:@"首页" forState:UIControlStateNormal];
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

#pragma mark 设置工具栏
- (void)setUpToolBar
{
    MRTCommentToolBar *toolBar = [[MRTCommentToolBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 35, MRTScreen_Width, 35)];
    [self.view addSubview:toolBar];
    
    toolBar.delegate = self;
    
    _toolBar = toolBar;
}

#pragma mark 设置评论转发切换栏
- (void)setUpSwitchBar
{
    //主视图上的switchBar
    MRTSwitchBar *mainViewSwitchBar = [[MRTSwitchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.y + self.navigationController.navigationBar.height, MRTScreen_Width, 40)];
    NSLog(@"navigationbarOrigin:%f,Height:%f", self.navigationController.navigationBar.y,self.navigationController.navigationBar.height);
    //首先设为隐藏
    mainViewSwitchBar.hidden = YES;
    mainViewSwitchBar.delegate = self;
    
    //设置评论按钮为选中状态
    mainViewSwitchBar.commentBtn.selected = YES;
    
    [self.view addSubview:mainViewSwitchBar];
    _switchBarOnMainView = mainViewSwitchBar;
    
    
    //tableView上的switchBar,此处只创建，还需将其设置为section1的headerView
    MRTSwitchBar *tableViewSwitchBar = [[MRTSwitchBar alloc] initWithFrame:CGRectMake(0, 0, MRTScreen_Width, 40)];
    
    [tableViewSwitchBar setTitleWithReposts:self.statusCell.statusFrame.status.reposts_count comments:self.statusCell.statusFrame.status.comments_count attitudes:self.statusCell.statusFrame.status.attitudes_count];
    
    tableViewSwitchBar.delegate = self;
    
    //设置评论按钮为选中状态
    tableViewSwitchBar.commentBtn.selected = YES;
    
    _switchBarOnTableView = tableViewSwitchBar;

}

#pragma mark 请求最新评论
- (void)loadNewComment
{
    //创建一个空的sinceId
    NSString *sinceId = nil;
    
    //载入since_id之后的新评论
    if (self.commentFrames.count) {
        //将since_id设置为当前已保存的最新评论的idstr，idstr越大数据越新
        MRTCommentFrame *commentFrame = [self.commentFrames firstObject];
        sinceId = commentFrame.comment.idstr;
    }
    
    //发送get请求
    [MRTCommentTool newCommentWithID:self.statusCell.statusFrame.status.idstr sinceId:sinceId success:^(NSArray *comments) {
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        
        //创建新评论数组
        NSMutableArray *newCommentFrames = [NSMutableArray array];
        
        for (MRTComment *comment in comments) {
            MRTCommentFrame *commentFrame = [[MRTCommentFrame alloc] init];
            commentFrame.comment = comment;
            [newCommentFrames addObject:commentFrame];
        }
        //根据comments的长度创建一个indexSet
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, comments.count)];
        
        //将最新的微博数据插入最前面
        [self.commentFrames insertObjects:newCommentFrames atIndexes:indexSet];
        
        //为switchBar的转发、评论数赋值
       
        [_switchBarOnMainView setTitleWithReposts:self.statusCell.statusFrame.status.reposts_count comments:self.statusCell.statusFrame.status.comments_count attitudes:self.statusCell.statusFrame.status.attitudes_count];
        
        
        
        //刷新表格数据
        [self.tableView reloadData];
        
        //[self.tableView layoutIfNeeded];
        
        NSLog(@"tableViewOrigin:%f, %f", self.tableView.x,self.tableView.y);
         NSLog(@"ContentOffset:%f, %f", self.tableView.contentOffset.x,self.tableView.contentOffset.y);
        
        if (_scorllToComment) {
            [self.tableView setContentOffset:CGPointMake(0, self.statusCell.statusFrame.noBarCellHeight - 64) animated:YES];
        }
        
        
        
    } failure:^(NSError *error) {
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        
        //显示失败提示
        [MBProgressHUD showError:@"刷新失败"];
        NSLog(@"error:%@", error);
    }];
}

#pragma mark 请求更多之前的评论
- (void)loadMoreComment
{
    //创建一个空的maxId
    NSString *maxId = nil;
    //如果评论数组不为空，则将最小的id减1后赋给maxId
    if (self.commentFrames.count) {
        MRTCommentFrame *commentFrame = [self.commentFrames lastObject];
        long long max = [commentFrame.comment.idstr longLongValue] - 1;
        maxId = [NSString stringWithFormat:@"%lld", max];
    }
    [MRTCommentTool moreCommentWithID:self.statusCell.statusFrame.status.idstr maxId:maxId success:^(NSArray *comments) {
        //结束上拉刷新
        [self.tableView.mj_footer endRefreshing];
        //创建旧评论数组
        NSMutableArray *oldCommentFrames = [NSMutableArray array];
        for (MRTComment *comment in comments) {
            MRTCommentFrame *commentFrame = [[MRTCommentFrame alloc] init];
            commentFrame.comment = comment;
            [oldCommentFrames addObject:commentFrame];
        }
        //将旧评论数组加入总评论数组
        [self.commentFrames addObjectsFromArray:oldCommentFrames];
        
        //刷新表格数据
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        //结束上拉刷新
        [self.tableView.mj_footer endRefreshing];
        
        //显示失败提示
        [MBProgressHUD showError:@"加载失败"];
        
        NSLog(@"error:%@", error);
    }];
}

#pragma mark 请求最新转发
- (void)loadNewRepost
{
    NSString *sinceId = nil;
    
    if (self.repostFrames.count) {
        //借用MRTCommentFrame
        MRTCommentFrame *repostFrame = [self.repostFrames firstObject];
        sinceId = repostFrame.comment.idstr;
    }
    
    [MRTCommentTool newRepostWithID:_statusCell.statusFrame.status.idstr sinceId:sinceId success:^(NSArray *reposts) {
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        
        //创建新转发数组
        NSMutableArray *newRepostFrames = [NSMutableArray array];
        
        for (MRTComment *repost in reposts) {
            MRTCommentFrame *repostFrame = [[MRTCommentFrame alloc] init];
            repostFrame.comment = repost;
            [newRepostFrames addObject:repostFrame];
        }
        //根据reposts的长度创建一个indexSet
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, reposts.count)];
        
        //将最新的微博数据插入最前面
        [self.repostFrames insertObjects:newRepostFrames atIndexes:indexSet];
        
        //为switchBar的转发、评论数赋值
        
        //刷新表格数据
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        
        //显示失败提示
        [MBProgressHUD showError:@"刷新失败"];
        
        NSLog(@"%@", error);
    }];
}

#pragma mark 请求更多转发
- (void)loadMoreRepost
{
    NSString *maxId = nil;
    
    if (self.repostFrames.count) {
        //借用MRTCommentFrame
        MRTCommentFrame *repostFrame = [self.repostFrames lastObject];
        maxId = repostFrame.comment.idstr;
        long long max = [maxId longLongValue] - 1;
        maxId = [NSString stringWithFormat:@"%lld", max];
    }
    
    [MRTCommentTool moreRepostWithID:_statusCell.statusFrame.status.idstr maxId:maxId success:^(NSArray *reposts) {
        //结束上拉刷新
        [self.tableView.mj_footer endRefreshing];
        
        //创建新转发数组
        NSMutableArray *oldRepostFrames = [NSMutableArray array];
        
        for (MRTComment *repost in reposts) {
            MRTCommentFrame *repostFrame = [[MRTCommentFrame alloc] init];
            repostFrame.comment = repost;
            [oldRepostFrames addObject:repostFrame];
        }
        
        //加入转发数组
        [self.repostFrames addObjectsFromArray:oldRepostFrames];
        
        //刷新表格数据
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        //结束上拉刷新
        [self.tableView.mj_footer endRefreshing];
        //显示失败提示
        [MBProgressHUD showError:@"加载失败"];
        
        NSLog(@"%@", error);
    }];
}


#pragma mark 执行点击评论工具栏代理方法
- (void)commentToolBar:(MRTCommentToolBar *)toolBar didClickButton:(NSInteger)index
{
    if (index == 0) {
        MRTWriteRepostController *writeRepostVC = [[MRTWriteRepostController alloc] init];
        
        writeRepostVC.statusCell = self.statusCell;
        
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeRepostVC];
        
        [self presentViewController:navVC animated:YES completion:nil];
    }
    
    if (index == 1) {
        MRTWriteCommentViewController *writeCommentVC = [[MRTWriteCommentViewController alloc] init];
        writeCommentVC.statusCell = self.statusCell;
        
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeCommentVC];
        
        [self presentViewController:navVC animated:YES completion:nil];
    }
}

#pragma mark 执行点击switchBar代理方法
- (void)switchBar:(MRTSwitchBar *)switchBar didClickButton:(NSInteger)index
{
    if (index == 0) {
        _switchBarOnTableView.retweetBtn.selected = YES;
        _switchBarOnTableView.commentBtn.selected = NO;
        _switchBarOnTableView.likeBtn.selected = NO;
        
        _switchBarOnMainView.retweetBtn.selected = YES;
        _switchBarOnMainView.commentBtn.selected = NO;
        _switchBarOnMainView.likeBtn.selected = NO;
        
        _switchFlag = YES;
        self.tableView.mj_header.refreshingAction = @selector(loadNewRepost);
        self.tableView.mj_footer.refreshingAction = @selector(loadMoreRepost);
        [self loadNewRepost];
    }
    
    if (index == 1) {
        _switchBarOnTableView.retweetBtn.selected = NO;
        _switchBarOnTableView.commentBtn.selected = YES;
        _switchBarOnTableView.likeBtn.selected = NO;
        
        _switchBarOnMainView.retweetBtn.selected = NO;
        _switchBarOnMainView.commentBtn.selected = YES;
        _switchBarOnMainView.likeBtn.selected = NO;
        
        _switchFlag = NO;
        self.tableView.mj_header.refreshingAction = @selector(loadNewComment);
        self.tableView.mj_footer.refreshingAction = @selector(loadMoreComment);
        [self loadNewComment];
    }
    
    if (index == 2) {
        _switchBarOnTableView.retweetBtn.selected = NO;
        _switchBarOnTableView.commentBtn.selected = NO;
        _switchBarOnTableView.likeBtn.selected = YES;
        
        _switchBarOnMainView.retweetBtn.selected = NO;
        _switchBarOnMainView.commentBtn.selected = NO;
        _switchBarOnMainView.likeBtn.selected = YES;
    }

}

- (void)dismissSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 1;
    } else {
        if (_switchFlag == 0) {
            return self.commentFrames.count;
        } else {
            return self.repostFrames.count;
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *ID = @"statusCell";
        MRTStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
         cell = [[MRTStatusCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
         }
        
        
        cell.statusFrame = self.statusCell.statusFrame;
        cell.statusToolBar.hidden = YES;
        return cell;
    } else {
        
        static NSString *ID = @"commentCell";
        MRTCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[MRTCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        
        if (_switchFlag == NO) {
 
            cell.commentFrame = self.commentFrames[indexPath.row];
        } else {
            //转发cell借用MRTCommentCell
            cell.commentFrame = self.repostFrames[indexPath.row];
        
        }
        return cell;
    }
}

#pragma mark - TableViewDelegata
//返回cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        //返回cell高度
        return self.statusCell.statusFrame.noBarCellHeight;
    } else {
        if (_switchFlag == 0) {
            return [self.commentFrames[indexPath.row] cellHeight];
        } else {
            return [self.repostFrames[indexPath.row] cellHeight];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 40;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return self.switchBarOnTableView;
    }
    
    return nil;
    
}

//根据滚动位置显示或隐藏主视图的switchBar
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView.contentOffset.y < self.statusCell.statusFrame.noBarCellHeight - 64) {
        //隐藏主视图的switchBar
        self.switchBarOnMainView.hidden = YES;
    }
    if (self.tableView.contentOffset.y > self.statusCell.statusFrame.noBarCellHeight - 64) {
        //显示主视图的switchBar
        self.switchBarOnMainView.hidden = NO;
    }
}
@end
