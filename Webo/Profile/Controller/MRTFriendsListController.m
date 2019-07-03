//
//  MRTFriendsListController.m
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTFriendsListController.h"
#import "MRTFriendsListCell.h"
#import "MRTUserInfoTool.h"
#import "UIImageView+WebCache.h"
#import "MRTCommentTitle.h"
#import "MRTFriendsListTool.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MRT.h"
#import "MRTOtherUser.h"
#import "MRTMyStatusesController.h"

@interface MRTFriendsListController ()
@property (nonatomic, strong) MRTUser *user;
@property (nonatomic, strong) MRTOtherUser *otherUser;

@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, strong) NSMutableArray *relationArray;
@property (nonatomic) int cursor;
@end

@implementation MRTFriendsListController

- (NSMutableArray *)lists
{
    if (!_lists) {
        _lists = [NSMutableArray array];
    }
    
    return _lists;
}

- (NSMutableArray *)relationArray
{
    if (!_relationArray) {
        _relationArray = [NSMutableArray array];
    }
    
    return _relationArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _cursor = 0;
    //获取自己的用户信息
    _user = [MRTUserInfoTool userInfo];
    //显示导航栏
    self.navigationController.navigationBarHidden = NO;
    //tableview背景颜色
    self.tableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    //自适应高度（此设置貌似能避免重复上拉刷新）
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 450;
    [self setUpNavigationBar];
    
    //添加下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewList)];
    if (self.lists.count == 0) {
        [self loadNewList];
    }
    //添加上拉刷新旧微博控件
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreList)];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
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
    [imageView sd_setImageWithURL:_user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    NSString *titleStr = _type == MRTListControllerTypeFriends ? @"我的好友" : @"粉丝";
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
   
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - 请求最新列表
- (void)loadNewList
{
    //刷新列表时先清空
    [self.lists removeAllObjects];
    
    if (_type == MRTListControllerTypeFriends) {
        [MRTFriendsListTool newFriendsListWithUID:_user.idstr cursor:0 trim_status:0 success:^(NSArray *users, int next_cursor) {
            //结束下拉刷新
            [self.tableView.mj_header endRefreshing];
            [self.lists addObjectsFromArray:users];
            self.cursor = next_cursor;
            NSLog(@"next_cursor:%d", next_cursor);
            //刷新表格数据
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            //结束下拉刷新
            [self.tableView.mj_header endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"加载失败"];
            NSLog(@"%@", error);
        }];
    } else {
        [MRTFriendsListTool newFollowersListWithUID:_user.idstr cursor:0 trim_status:0 success:^(NSArray *users, int next_cursor) {
            //结束下拉刷新
            [self.tableView.mj_header endRefreshing];
            [self.lists addObjectsFromArray:users];
            self.cursor = next_cursor;
            NSLog(@"next_cursor:%d", next_cursor);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (int i = 0; i < users.count; i++) {
                    MRTOtherUser *otherUser = users[i];
                    [MRTFriendsListTool getRelationWithSource_id:_user.idstr target_id:otherUser.idstr success:^(MRTRelation *relation) {
                        NSLog(@"刷新时ralation.following:%d, relation.followed_by:%d", relation.following, relation.followed_by);
                        [self.relationArray addObject:relation];
                        NSLog(@"relationArray.count:%ld", self.relationArray.count);
                        if (i == users.count - 1) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                            //   [self.tableView reloadData];
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"relationError:%@", error);
                    }];
                }
            });
            
            //刷新表格数据
            //[self.tableView reloadData];
        } failure:^(NSError *error) {
            //结束下拉刷新
            [self.tableView.mj_header endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"加载失败"];
            NSLog(@"%@", error);
        }];
    }
    
    
}

#pragma mark - 请求更多列表
- (void)loadMoreList
{
    int cursor = (int)self.lists.count;
    
    if (_type == MRTListControllerTypeFriends) {
        [MRTFriendsListTool moreFriendsListWithUID:_user.idstr cursor:cursor trim_status:0 success:^(NSArray *users, int next_cursor) {
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            [self.lists addObjectsFromArray:users];
            self.cursor = next_cursor;
            NSLog(@"next_cursor:%d", next_cursor);
            //刷新表格数据
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"加载失败"];
            NSLog(@"%@", error);
        }];
    } else {
        [MRTFriendsListTool moreFollowersListWithUID:_user.idstr cursor:cursor + 1 trim_status:0 success:^(NSArray *users, int next_cursor) {
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            [self.lists addObjectsFromArray:users];
            self.cursor = next_cursor;
            NSLog(@"next_cursor:%d", next_cursor);
            for (int i = 0; i < users.count; i++) {
                MRTOtherUser *otherUser = users[i];
                [MRTFriendsListTool getRelationWithSource_id:_user.idstr target_id:otherUser.idstr success:^(MRTRelation *relation) {
                    [self.relationArray addObject:relation];
                    if (i == users.count - 1) {
                        [self.tableView reloadData];
                    }
                } failure:^(NSError *error) {
                    NSLog(@"relationError:%@", error);
                }];
            }
            
            //刷新表格数据
            //[self.tableView reloadData];
        } failure:^(NSError *error) {
            //结束上拉刷新
            [self.tableView.mj_footer endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"加载失败"];
            NSLog(@"%@", error);
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    MRTFriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MRTFriendsListCell" owner:nil options:nil][0];
    }
    
    MRTOtherUser *otherUser = self.lists[indexPath.row];
    cell.otherUser = otherUser;
    MRTRelation *relation = [[MRTRelation alloc] init];
    if (_type == MRTListControllerTypeFollewers && self.lists.count == self.relationArray.count) {
        relation = self.relationArray[indexPath.row];
        NSLog(@"赋值时relation.following:%d, relation.followed_by:%d", relation.following, relation.followed_by);
    }
    [cell setUpCellWithType:_type User:otherUser relation:relation];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MRTOtherUser *otherUser = self.lists[indexPath.row];
    
    MRTMyStatusesController *statusesVC = [[MRTMyStatusesController alloc] init];
    statusesVC.otherUser = otherUser;
    NSLog(@"otherUser.idstr:%@  otherUser.avatar:%@", otherUser.idstr, otherUser.avatar_large);
    statusesVC.leftTitle = @"返回";
    statusesVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:statusesVC animated:YES];

}

@end
