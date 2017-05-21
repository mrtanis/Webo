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
#import "AFNetworking.h"
#import "MRTAccountStore.h"
#import "MRTAccount.h"
#import "MRTStatus.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "MRTHttpTool.h"
#import "MRTStatusTool.h"

@interface MRTHomeViewController () <MRTCoverDelegate>

@property (nonatomic, weak) MRTHomeTitle *titleButton;
@property (nonatomic, strong) MRTMenuViewController *menu;
@property (nonatomic, copy) NSMutableArray *statuses;
@end

@implementation MRTHomeViewController

//懒加载statuses数组
- (NSMutableArray *)statuses
{
    if (!_statuses) {
        _statuses = [[NSMutableArray alloc] init];
    }
    
    return _statuses;
}

- (MRTMenuViewController *)menu
{
    if (!_menu) {
        _menu = [[MRTMenuViewController alloc] init];
    }
    
    return _menu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏
    [self setUpNavigationBar];
    
    //添加下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewStatus)];
    [self.tableView.mj_header beginRefreshing];
    
    //添加上拉刷新旧微博控件
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreStatus)];
}

//设置导航栏
- (void)setUpNavigationBar
{
    
    //左边按钮
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_friendsearch"] highLightedImage:[UIImage imageNamed:@"navigationbar_friendsearch_highlighted"] target:self action:@selector(friendSearch)  forControlEvents:UIControlEventTouchUpInside];
    //右边按钮
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_pop"] highLightedImage:[UIImage imageNamed:@"navigationbar_pop_highlighted"] target:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    
    //标题
    MRTHomeTitle *titleButton = [MRTHomeTitle buttonWithType:UIButtonTypeCustom];
    _titleButton = titleButton;
    
    [titleButton setTitle:@"首页" forState:UIControlStateNormal];
    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_up"] forState:UIControlStateSelected];
    
    //高亮时不需要调整图片
    titleButton.adjustsImageWhenHighlighted = NO;
    
    [titleButton addTarget:self action:@selector(menuTitleClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //将titleView设置为titleButton
    self.navigationItem.titleView = titleButton;
}

//左按钮调用方法
- (void)friendSearch
{
    NSLog(@"%s", __func__);
}
//右按钮调用方法
- (void)pop
{
    //创建新的控制
    MRTOneViewController *one = [[MRTOneViewController alloc] init];
    
    //push时隐藏系统自带tabBar
    one.hidesBottomBarWhenPushed = YES;
    
    //push新的控制器
    [self.navigationController pushViewController:one animated:YES];
}
//标题调用方法
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
    //创建一个空sinceId
    NSString *sinceId = nil;
    
    //载入since_id之后的新微博数据
    if (self.statuses.count) {
        //将since_id设置为当前已保存的最新微博的idstr，idstr越大数据越新
        sinceId = [self.statuses[0] idstr];
    }
    
    //发送get请求
    [MRTStatusTool newStatusWithSinceId:sinceId success:^(NSArray *statuses) {
        
        //结束下拉刷新
        [self.tableView.mj_header endRefreshing];
        
        //根据statuses的长度创建一个indexSet
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statuses.count)];
        
        //将最新的微博数据插入最前面
        [self.statuses insertObjects:statuses atIndexes:indexSet];
        
        //刷新表格数据
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        NSLog(@"error:%@", error);
        
    }];
}

#pragma mark 加载更多之前的微博数据
- (void)loadMoreStatus
{
    //新建一个空的maxId
    NSString *maxId = nil;
    
    if (self.statuses.count) {
        //返回小于等于max_id的微博，所以要减一
        long long max_id =[[[self.statuses lastObject] idstr] longLongValue] - 1;
        maxId = [NSString stringWithFormat:@"%lld", max_id];
    }
    
    //发送get请求
    [MRTStatusTool moreStatusWithMaxId:maxId success:^(NSArray *statuses) {
        
        //结束上拉刷新
        [self.tableView.mj_footer endRefreshing];
        
        //加入到statuses
        [self.statuses addObjectsFromArray:statuses];
        
        //刷新表格
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        
        NSLog(@"error:%@", error);
    }];
}

    
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.statuses.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    MRTStatus *status = self.statuses[indexPath.row];
    cell.textLabel.text = status.user.name;
    [cell.imageView sd_setImageWithURL:status.user.profile_image_url placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    cell.detailTextLabel.text = status.text;
    
    return cell;
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
