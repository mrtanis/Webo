//
//  MRTMessageSwitchView.m
//  Webo
//
//  Created by mrtanis on 2017/7/25.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageSwitchView.h"
#import "MRTMessageSwitchBar.h"
#import "MRTMessageStatusCell.h"
#import "MRTMessageCommentCell.h"
#import "MJRefresh.h"
#import "MRTStatusTool.h"
#import "MBProgressHUD+MRT.h"
#import "MRTCommentTool.h"
#import "MRTComment.h"
#import "MRTCommentViewController.h"
#import "MRTWriteRepostController.h"
#import "MRTNavigationController.h"
#import "MRTWriteCommentViewController.h"
#import "MRTTimeLineStore.h"


@interface MRTMessageSwitchView()<UITableViewDelegate, UITableViewDataSource, MRTMessageStatusCellDelegate, MRTMessageCommentCellDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *tableViews;
@property (nonatomic, strong) NSMutableArray *widthOfButtons;
@property (nonatomic) float totalWidth;
@property (nonatomic, weak) UIView *switchBar;
@property (nonatomic, weak) UIView *indicatorBar;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic) int selectedIndex;

@property (nonatomic) float lastContentOffset;

@property (nonatomic, strong) NSMutableArray *at_statusFrames;
@property (nonatomic, strong) NSMutableArray *at_commentFrames;
@property (nonatomic, strong) NSMutableArray *in_commentFrames;
@property (nonatomic, strong) NSMutableArray *out_commentFrames;
@end

@implementation MRTMessageSwitchView

#pragma mark 数组懒加载

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    
    return _buttons;
}

- (NSMutableArray *)widthOfButtons
{
    if(!_widthOfButtons) {
        _widthOfButtons = [NSMutableArray array];
    }
    
    return _widthOfButtons;
}

- (NSMutableArray *)at_statusFrames
{
    if (!_at_statusFrames) {
        _at_statusFrames = [NSKeyedUnarchiver unarchiveObjectWithFile:[MRTTimeLineStore timelineArchivePathWithIndex:0]];
    }
    if (!_at_statusFrames) {
        _at_statusFrames = [NSMutableArray array];
    }
    
    return _at_statusFrames;
}

- (NSMutableArray *)at_commentFrames
{
    if (!_at_commentFrames) {
        _at_commentFrames = [NSKeyedUnarchiver unarchiveObjectWithFile:[MRTTimeLineStore timelineArchivePathWithIndex:1]];
    }
    if (!_at_commentFrames) {
        _at_commentFrames = [NSMutableArray array];
    }
    
    return _at_commentFrames;
}

- (NSMutableArray *)in_commentFrames
{
    if (!_in_commentFrames) {
        _in_commentFrames = [NSKeyedUnarchiver unarchiveObjectWithFile:[MRTTimeLineStore timelineArchivePathWithIndex:2]];
    }
    if (!_in_commentFrames) {
        _in_commentFrames = [NSMutableArray array];
    }
    
    return _in_commentFrames;
}

- (NSMutableArray *)out_commentFrames
{
    if (!_out_commentFrames) {
        _out_commentFrames = [NSKeyedUnarchiver unarchiveObjectWithFile:[MRTTimeLineStore timelineArchivePathWithIndex:3]];
    }
    if (!_out_commentFrames) {
        _out_commentFrames = [NSMutableArray array];
    }
    
    return _out_commentFrames;
}

- (NSMutableArray *)tableViews
{
    if (!_tableViews) {
        _tableViews = [NSMutableArray array];
    }
    
    return _tableViews;
}

#pragma mark 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSwitchBar];
        [self setUpScrollView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimeline) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark 设置scrollView和tableView
- (void)setUpScrollView
{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, MRTScreen_Width, self.height - 40)];
    scrollView.contentSize = CGSizeMake(MRTScreen_Width * 4.0, 0);
    scrollView.pagingEnabled = YES;
    scrollView.alwaysBounceVertical = NO;
    scrollView.delegate = self;
    scrollView.tag = 0;
    
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
    for (int i = 0; i < 4; i++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(MRTScreen_Width * i, 0, MRTScreen_Width, scrollView.height) style:UITableViewStylePlain];
        tableView.tag = i;
        tableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
        //添加下拉刷新控件
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        //[self loadNewDataCheckCache:YES];
        
        
        //添加上拉刷新旧微博控件
        tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        
        //取消分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;

        [self.scrollView addSubview:tableView];
        [self.tableViews addObject:tableView];
    }
    if (self.at_statusFrames.count == 0) {
        [self loadNewData];
    }
}

#pragma mark 请求最新的微博或评论

- (void)loadNewData
{
    if (_selectedIndex == 0) {
        NSUInteger count = self.at_statusFrames.count;
        if (count >= 180) {
            for (NSUInteger i = count; i > count - 20; i--) {
                [self.at_statusFrames removeObjectAtIndex:i - 1];
            }
        }
        //创建一个空sinceId
        NSString *sinceId = nil;
        
        //载入since_id之后的新微博数据
        if (self.at_statusFrames.count) {
            //将since_id设置为当前已保存的最新微博的idstr，idstr越大数据越新
            sinceId = [[self.at_statusFrames[0] status] idstr];
        }
        //获取当前tableView
        UITableView *tableView = _tableViews[0];
        //发送get请求
        [MRTStatusTool newAt_StatusWithSinceId:sinceId success:^(NSArray *statuses) {
            
            //结束下拉刷新
            
            [tableView.mj_header endRefreshing];
            
            //创建newStatusFrames数组
            NSMutableArray *newStatusFrames = [[NSMutableArray alloc] init];
            
            for (MRTStatus *status in statuses) {
                //创建statusFrame
                MRTMessageStatusFrame *statusFrame = [[MRTMessageStatusFrame alloc] init];
                //给statusFrame的status属性赋值
                statusFrame.status = status;
                //将statusFrame加入newStatusFrame数组
                [newStatusFrames addObject:statusFrame];
            }
            
            //根据statuses的长度创建一个indexSet
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statuses.count)];
            
            //将最新的微博数据插入最前面
            [self.at_statusFrames insertObjects:newStatusFrames atIndexes:indexSet];
            
            //刷新表格数据
            [tableView reloadData];
            [self saveTimeline];
            
        } failure:^(NSError *error) {
            //结束下拉刷新
            [tableView.mj_header endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"刷新失败"];
            
            NSLog(@"error:%@", error);
            
        }];
    } else if (_selectedIndex == 1) {
        NSUInteger count = self.at_commentFrames.count;
        if (count >= 180) {
            for (NSUInteger i = count; i > count - 20; i--) {
                [self.at_commentFrames removeObjectAtIndex:i - 1];
            }
        }
        //创建一个空sinceId
        NSString *sinceId = nil;
        
        //载入since_id之后的新@我的评论数据
        if (self.at_commentFrames.count) {
            //将since_id设置为当前已保存的最新微博的idstr，idstr越大数据越新
            MRTMessageStatusFrame *frame = self.at_commentFrames[0];
            sinceId = frame.comment.idstr;
        }
        //获取当前tableView
        UITableView *tableView = _tableViews[1];
        //发送get请求
        [MRTCommentTool newAt_CommentWithSinceId:sinceId success:^(NSArray *comments) {

            //结束下拉刷新
            [tableView.mj_header endRefreshing];
            
            //创建newStatusFrames数组
            NSMutableArray *newCommentFrames = [[NSMutableArray alloc] init];
            
            for (MRTComment *comment in comments) {
                //创建statusFrame
                MRTMessageStatusFrame *statusFrame = [[MRTMessageStatusFrame alloc] init];
                //给statusFrame的status属性赋值
                statusFrame.comment = comment;
                //将statusFrame加入newStatusFrame数组
                [newCommentFrames addObject:statusFrame];
            }
            
            //根据statuses的长度创建一个indexSet
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, comments.count)];
            
            //将最新的微博数据插入最前面
            [self.at_commentFrames insertObjects:newCommentFrames atIndexes:indexSet];
            
            //刷新表格数据
            [tableView reloadData];
            [self saveTimeline];
            
        } failure:^(NSError *error) {
            //结束下拉刷新
            [tableView.mj_header endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"刷新失败"];
            
            NSLog(@"error:%@", error);
            
        }];
    } else if (_selectedIndex == 2) {
        NSUInteger count = self.in_commentFrames.count;
        if (count >= 180) {
            for (NSUInteger i = count; i > count - 20; i--) {
                [self.in_commentFrames removeObjectAtIndex:i - 1];
            }
        }
        //创建一个空sinceId
        NSString *sinceId = nil;
        
        //载入since_id之后的新@我的评论数据
        if (self.in_commentFrames.count) {
            //将since_id设置为当前已保存的最新微博的idstr，idstr越大数据越新
            MRTMessageCommentFrame *frame = self.in_commentFrames[0];
            sinceId = frame.comment.idstr;
        }
        //获取当前tableView
        UITableView *tableView = _tableViews[2];
        //发送get请求
        [MRTCommentTool newIn_CommentWithSinceId:sinceId success:^(NSArray *comments) {
            NSLog(@"获取的comments:%d", (int)comments.count);
            //结束下拉刷新
            [tableView.mj_header endRefreshing];
            
            //创建newStatusFrames数组
            NSMutableArray *newCommentFrames = [[NSMutableArray alloc] init];
            
            for (MRTComment *comment in comments) {
                //创建statusFrame
                MRTMessageCommentFrame *commentFrame = [[MRTMessageCommentFrame alloc] init];
                //给statusFrame的status属性赋值
                commentFrame.comment = comment;
                //将statusFrame加入newStatusFrame数组
                [newCommentFrames addObject:commentFrame];
            }
            
            //根据statuses的长度创建一个indexSet
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, comments.count)];
            
            //将最新的微博数据插入最前面
            [self.in_commentFrames insertObjects:newCommentFrames atIndexes:indexSet];
            NSLog(@"我收到的评论个数：%d", (int)self.in_commentFrames.count);
            
            //刷新表格数据
            [tableView reloadData];
            [self saveTimeline];
            
        } failure:^(NSError *error) {
            //结束下拉刷新
            [tableView.mj_header endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"刷新失败"];
            
            NSLog(@"error:%@", error);
            
        }];
    } else {
        NSUInteger count = self.out_commentFrames.count;
        if (count >= 180) {
            for (NSUInteger i = count; i > count - 20; i--) {
                [self.out_commentFrames removeObjectAtIndex:i - 1];
            }
        }
        //创建一个空sinceId
        NSString *sinceId = nil;
        
        //载入since_id之后的新@我的评论数据
        if (self.out_commentFrames.count) {
            //将since_id设置为当前已保存的最新微博的idstr，idstr越大数据越新
            MRTMessageStatusFrame *frame = self.out_commentFrames[0];
            sinceId = frame.comment.idstr;
        }
        //获取当前tableView
        UITableView *tableView = _tableViews[3];
        //发送get请求
        [MRTCommentTool newOut_CommentWithSinceId:sinceId success:^(NSArray *comments) {
            
            //结束下拉刷新
            [tableView.mj_header endRefreshing];
            
            //创建newStatusFrames数组
            NSMutableArray *newCommentFrames = [[NSMutableArray alloc] init];
            
            for (MRTComment *comment in comments) {
                //创建statusFrame
                MRTMessageCommentFrame *commentFrame = [[MRTMessageCommentFrame alloc] init];
                //给statusFrame的status属性赋值
                commentFrame.comment = comment;
                //将statusFrame加入newStatusFrame数组
                [newCommentFrames addObject:commentFrame];
            }
            
            //根据statuses的长度创建一个indexSet
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, comments.count)];
            
            //将最新的微博数据插入最前面
            [self.out_commentFrames insertObjects:newCommentFrames atIndexes:indexSet];
            NSLog(@"我发出的的评论个数：%d", (int)self.out_commentFrames.count);
            //刷新表格数据
            [tableView reloadData];
            [self saveTimeline];
            
        } failure:^(NSError *error) {
            //结束下拉刷新
            [tableView.mj_header endRefreshing];
            //显示失败提示
            [MBProgressHUD showError:@"刷新失败"];
            
            NSLog(@"error:%@", error);
            
        }];
    }
}

#pragma mark 加载更多之前的微博数据
- (void)loadMoreData
{
    if (_selectedIndex == 0) {
        //获取当前tableView
        UITableView *tableView = _tableViews[0];
        
        NSUInteger count = self.at_statusFrames.count;
        if (count > 180) {
            //结束上拉刷新
            [tableView.mj_footer endRefreshing];
        } else {
            //新建一个空的maxId
            NSString *maxId = nil;
            
            if (self.at_statusFrames.count) {
                //返回小于等于max_id的微博，所以要减一
                long long max_id =[[[[self.at_statusFrames lastObject] status] idstr] longLongValue] - 1;
                maxId = [NSString stringWithFormat:@"%lld", max_id];
            }
            
            //发送get请求
            [MRTStatusTool moreAt_StatusWithMaxId:maxId success:^(NSArray *statuses) {
                
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                
                //创建oldStatusFrames数组
                NSMutableArray *oldStatusFrames = [[NSMutableArray alloc] init];
                
                for (MRTStatus *status in statuses) {
                    //创建statusFrame
                    MRTMessageStatusFrame *statusFrame = [[MRTMessageStatusFrame alloc] init];
                    //给statusFrame的status属性赋值
                    statusFrame.status = status;
                    //将statusFrame加入到oldStatusFrame数组
                    [oldStatusFrames addObject:statusFrame];
                }
                
                
                //加入到statusFrame
                [self.at_statusFrames addObjectsFromArray:oldStatusFrames];
                
                //刷新表格
                [tableView reloadData];
                [self saveTimeline];
                
            } failure:^(NSError *error) {
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                //显示失败提示
                [MBProgressHUD showError:@"加载失败"];
                
                NSLog(@"error:%@", error);
            }];
        }
    }else if (_selectedIndex == 1) {
        //获取当前tableView
        UITableView *tableView = _tableViews[1];
        
        NSUInteger count = self.at_commentFrames.count;
        if (count > 180) {
            //结束上拉刷新
            [tableView.mj_footer endRefreshing];
        } else {
            //新建一个空的maxId
            NSString *maxId = nil;
            
            if (self.at_commentFrames.count) {
                //返回小于等于max_id的微博，所以要减一
                MRTMessageStatusFrame *frame = self.at_commentFrames.lastObject;
                long long max_id =[[frame.comment idstr] longLongValue] - 1;
                maxId = [NSString stringWithFormat:@"%lld", max_id];
            }
            
            //发送get请求
            [MRTCommentTool moreAt_CommentWithMaxId:maxId success:^(NSArray *comments) {
                
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                
                //创建oldStatusFrames数组
                NSMutableArray *oldCommentFrames = [[NSMutableArray alloc] init];
                
                for (MRTComment *comment in comments) {
                    //创建statusFrame
                    MRTMessageStatusFrame *statusFrame = [[MRTMessageStatusFrame alloc] init];
                    //给statusFrame的status属性赋值
                    statusFrame.comment = comment;
                    //将statusFrame加入到oldStatusFrame数组
                    [oldCommentFrames addObject:statusFrame];
                }
                
                
                //加入到statusFrame
                [self.at_commentFrames addObjectsFromArray:oldCommentFrames];
                
                //刷新表格
                [tableView reloadData];
                [self saveTimeline];
                
            } failure:^(NSError *error) {
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                //显示失败提示
                [MBProgressHUD showError:@"加载失败"];
                
                NSLog(@"error:%@", error);
            }];
        }
    } else if (_selectedIndex == 2) {
        //获取当前tableView
        UITableView *tableView = _tableViews[2];
        
        NSUInteger count = self.in_commentFrames.count;
        if (count > 180) {
            //结束上拉刷新
            [tableView.mj_footer endRefreshing];
        } else {
            //新建一个空的maxId
            NSString *maxId = nil;
            
            if (self.in_commentFrames.count) {
                //返回小于等于max_id的微博，所以要减一
                MRTMessageCommentFrame *frame = self.in_commentFrames.lastObject;
                long long max_id =[[frame.comment idstr] longLongValue] - 1;
                maxId = [NSString stringWithFormat:@"%lld", max_id];
            }
        
            //发送get请求
            [MRTCommentTool moreIn_CommentWithMaxId:maxId success:^(NSArray *comments) {
                
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                
                //创建oldStatusFrames数组
                NSMutableArray *oldCommentFrames = [[NSMutableArray alloc] init];
                
                for (MRTComment *comment in comments) {
                    //创建statusFrame
                    MRTMessageCommentFrame *commentFrame = [[MRTMessageCommentFrame alloc] init];
                    //给statusFrame的status属性赋值
                    commentFrame.comment = comment;
                    //将statusFrame加入到oldStatusFrame数组
                    [oldCommentFrames addObject:commentFrame];
                }
                
                
                //加入到statusFrame
                [self.in_commentFrames addObjectsFromArray:oldCommentFrames];
                
                //刷新表格
                [tableView reloadData];
                [self saveTimeline];
                
            } failure:^(NSError *error) {
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                //显示失败提示
                [MBProgressHUD showError:@"加载失败"];
                
                NSLog(@"error:%@", error);
            }];
        }
    } else {
        //获取当前tableView
        UITableView *tableView = _tableViews[3];
        
        NSUInteger count = self.out_commentFrames.count;
        if (count > 180) {
            //结束上拉刷新
            [tableView.mj_footer endRefreshing];
        } else {
            //新建一个空的maxId
            NSString *maxId = nil;
            
            if (self.out_commentFrames.count) {
                //返回小于等于max_id的微博，所以要减一
                MRTMessageCommentFrame *frame = self.out_commentFrames.lastObject;
                long long max_id =[[frame.comment idstr] longLongValue] - 1;
                maxId = [NSString stringWithFormat:@"%lld", max_id];
            }
            
            //发送get请求
            [MRTCommentTool moreOut_CommentWithMaxId:maxId success:^(NSArray *comments) {
                
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                
                //创建oldStatusFrames数组
                NSMutableArray *oldCommentFrames = [[NSMutableArray alloc] init];
                
                for (MRTComment *comment in comments) {
                    //创建statusFrame
                    MRTMessageCommentFrame *commentFrame = [[MRTMessageCommentFrame alloc] init];
                    //给statusFrame的status属性赋值
                    commentFrame.comment = comment;
                    //将statusFrame加入到oldStatusFrame数组
                    [oldCommentFrames addObject:commentFrame];
                }
                
                
                //加入到statusFrame
                [self.out_commentFrames addObjectsFromArray:oldCommentFrames];
                
                //刷新表格
                [tableView reloadData];
                [self saveTimeline];
                
            } failure:^(NSError *error) {
                //结束上拉刷新
                [tableView.mj_footer endRefreshing];
                //显示失败提示
                [MBProgressHUD showError:@"加载失败"];
                
                NSLog(@"error:%@", error);
            }];
        }
    }
}


#pragma mark 添加switchBar
- (void)addSwitchBar
{
    UIView *switchBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MRTScreen_Width, 40)];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 39.5, MRTScreen_Width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
    [switchBar addSubview:bottomLine];
    [self addSubview:switchBar];
    _switchBar = switchBar;
    [self setUpButtons];
    [self setUpIndicatorBar];
    
}

#pragma mark 添加切换按钮
- (void)setUpButtons
{
    NSArray *buttonTitles = @[@"@我的微博", @"@我的评论", @"收到的评论", @"发出的评论"];
    
    int i = 0;
    _totalWidth = 0;
    for (NSString *title in buttonTitles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [button sizeToFit];
        NSNumber *width = [NSNumber numberWithFloat:button.frame.size.width];
        [self.widthOfButtons addObject:width];
        _totalWidth += button.frame.size.width;
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        button.tag = i;
        if (i == 0) {
            button.selected = YES;
            _selectedIndex = i;
        }
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.switchBar addSubview:button];
        [self.buttons addObject:button];
        
        i++;
    }
    
    //计算button frame
    CGFloat space = (MRTScreen_Width - _totalWidth) / 4.0;
    CGFloat halfSpace = space / 2.0;
    for (UIButton *button in _buttons) {
        NSUInteger index = [_buttons indexOfObject:button];
        CGFloat x = halfSpace + (button.width + space) * index;
        CGFloat y = (self.switchBar.height - button.height) / 2.0;
        
        button.frame = CGRectMake(x, y, button.width, button.height);
    }
}

#pragma mark 添加指示条
- (void)setUpIndicatorBar
{
    UIButton *button = _buttons[0];
    
    UIView *indicatorBar = [[UIView alloc] initWithFrame:CGRectMake(button.x + button.width * 0.25, self.switchBar.height - 5, button.width * 0.5, 4)];
    indicatorBar.backgroundColor = [UIColor orangeColor];
    indicatorBar.layer.cornerRadius = 2;
    indicatorBar.clipsToBounds = YES;
    
    [self.switchBar addSubview:indicatorBar];
    _indicatorBar = indicatorBar;
    
}

#pragma mark 点击工具栏时执行
- (void)statusCell:(MRTStatusFrame *)statusFrame didClickButton:(NSInteger)index
{
    if (index == 0) {
        MRTWriteRepostController *writeRepostVC = [[MRTWriteRepostController alloc] init];
        
        writeRepostVC.statusFrame = statusFrame;
        
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeRepostVC];
        
        if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
            [_delegate messageSwitchViewDidSendVC:navVC present:YES];
        }
    }
    
    if (index == 1) {
        //如果有评论就进入查看
        if (statusFrame.status.comments_count) {
            MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
            commentVC.statusFrame = statusFrame;
            
            //滚动到评论区
            commentVC.scorllToComment = YES;
            //只显示主微博
            commentVC.onlyOriginal = YES;
            
            //隐藏系统自带tabBar
            commentVC.hidesBottomBarWhenPushed = YES;
            
            if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
                [_delegate messageSwitchViewDidSendVC:commentVC present:NO];
            }
        } else {//没有评论就进入发评论界面
            MRTWriteCommentViewController *writeCommentVC = [[MRTWriteCommentViewController alloc] init];
            writeCommentVC.statusFrame = statusFrame;
            
            MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeCommentVC];
            
            if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
                [_delegate messageSwitchViewDidSendVC:navVC present:YES];
            }
        }
    }
}

- (void)textViewDidClickCell:(MRTStatusFrame *)statusFrame onlyOriginal:(BOOL)flag
{
    
    MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
    
    commentVC.leftTitle = @"@me";
    statusFrame.isAtStatus = YES;//直接设置视频地址，不用从网页中抓取
    //不滚动到评论区
    commentVC.scorllToComment = NO;
    //是否只显示主微博
    
    commentVC.onlyOriginal = flag;
    
    
    commentVC.statusFrame = statusFrame;
    
    //隐藏系统自带tabBar
    commentVC.hidesBottomBarWhenPushed = YES;
    
    
    if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
        [_delegate messageSwitchViewDidSendVC:commentVC present:NO];
    }
    
    
    
}

#pragma mark cell点击回复按钮代理方法
- (void)clickReplyButtonWithFrame:(MRTCommentFrame *)commentFrame
{
    MRTWriteCommentViewController *writeCommentVC = [[MRTWriteCommentViewController alloc] init];
    writeCommentVC.commentFrame = commentFrame;
    writeCommentVC.replyToComment = YES;
    
    MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:writeCommentVC];
    
    if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
        NSLog(@"clickReplyButton3");
        [_delegate messageSwitchViewDidSendVC:navVC present:YES];
    }
}

#pragma mark 点击按钮时执行
- (void)buttonClick:(UIButton *)button
{
    if (button.selected == YES) {
        UITableView *tableView = _tableViews[button.tag];
        [tableView.mj_header beginRefreshing];
    } else {
        button.selected = YES;
        _selectedIndex = (int)button.tag;
        for (UIButton *otherButton in _buttons) {
            if (otherButton.tag != button.tag) {
                otherButton.selected = NO;
            }
        }
    }
    
    
    [_scrollView setContentOffset:CGPointMake(MRTScreen_Width * button.tag, 0) animated:YES];
    
    [self autoRefreshTableView];
}

#pragma mark - 点击按钮或者滑动切换页面后，页面无数据自动刷新
- (void)autoRefreshTableView
{
    if (_selectedIndex == 0 && _at_statusFrames.count == 0) {
        [self loadNewData];
    }
    if (_selectedIndex == 1 && _at_commentFrames.count == 0) {
        [self loadNewData];
    }
    if (_selectedIndex == 2 && _in_commentFrames.count == 0) {
        [self loadNewData];
    }
    if (_selectedIndex == 3 && _out_commentFrames.count == 0) {
        [self loadNewData];
    }
}

#pragma mark - 保存timeline数组到缓存(doc目录)
- (void)saveTimeline
{
    
    //[MRTTimeLineStore deleteTimeLineOfAtMe];
    [MRTTimeLineStore saveTimeLineWithAt_status:self.at_statusFrames at_comment:self.at_commentFrames in_comment:self.in_commentFrames out_comment:self.out_commentFrames];
    
}


#pragma mark 执行scrollView代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentPage = _selectedIndex;
    //避免下拉tableView时调用该方法，判断是否为主scrollView
    if (scrollView.tag == 0) {
        currentPage = (int)(scrollView.contentOffset.x / MRTScreen_Width + 0.5);
    }
    
    for (UIButton *button in _buttons) {
        if (button.tag == currentPage) {
            
            button.selected = YES;
            _selectedIndex = (int)button.tag;
            //[_tableViews[_selectedIndex] reloadData];
        } else {
            button.selected = NO;
        }
    }
    
    float width0 = [_widthOfButtons[0] floatValue];
    float width1 = [_widthOfButtons[1] floatValue];
    float width2 = [_widthOfButtons[2] floatValue];
    float width3 = [_widthOfButtons[3] floatValue];
    UIButton *button0 = _buttons[0];
    UIButton *button1 = _buttons[1];
    UIButton *button2 = _buttons[2];
    UIButton *button3 = _buttons[3];
    float ratio;
    //向左滑动
    if (scrollView.contentOffset.x > _lastContentOffset) {
        if (0 < scrollView.contentOffset.x && scrollView.contentOffset.x <= MRTScreen_Width) {
            ratio = scrollView.contentOffset.x / MRTScreen_Width;
            
            float space = button1.x - button0.x;
            float x = button0.x + button0.width * 0.25 + space * ratio;
            
            float difference = width1 - width0;
            float width = width0 * 0.5 + difference * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        } else if (MRTScreen_Width < scrollView.contentOffset.x && scrollView.contentOffset.x <= MRTScreen_Width * 2) {
            ratio = (scrollView.contentOffset.x - MRTScreen_Width) / MRTScreen_Width;

            float space = button2.x - button1.x;
            float x = button1.x + button1.width * 0.25 + space * ratio;
            
            float difference = width2 - width1;
            float width = width1 * 0.5 + difference * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        } else if (MRTScreen_Width * 2 < scrollView.contentOffset.x && scrollView.contentOffset.x <= MRTScreen_Width * 3) {
            ratio = (scrollView.contentOffset.x - MRTScreen_Width * 2) / MRTScreen_Width;
            
            float space = button3.x - button2.x;
            float x = button2.x + button2.width * 0.25 + space * ratio;
            
            float difference = width3 - width2;
            float width = width2 * 0.5 + difference * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        } else if (MRTScreen_Width * 3 < scrollView.contentOffset.x) {
            ratio = (scrollView.contentOffset.x - MRTScreen_Width * 3) / MRTScreen_Width;
            float x = button3.x + button3.width * 0.25 + button3.width * ratio;
            float width = button3.width * 0.5 - button3.width * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        }
    } else if (scrollView.contentOffset.x < _lastContentOffset) {
        if (scrollView.contentOffset.x < 0) {
            ratio = (- scrollView.contentOffset.x) / MRTScreen_Width;
            float x = button0.x;
            float width = button0.width - button0.width * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        } else if (0 <= scrollView.contentOffset.x && scrollView.contentOffset.x < MRTScreen_Width) {
            ratio = scrollView.contentOffset.x / MRTScreen_Width;
            
            float space = button1.frame.origin.x - button0.frame.origin.x;
            float x = button0.x + button0.width * 0.25 + space * ratio;
            
            float difference = width1 - width0;
            float width = width0 * 0.5 + difference * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        } else if (MRTScreen_Width <= scrollView.contentOffset.x && scrollView.contentOffset.x < MRTScreen_Width * 2) {
            ratio = (scrollView.contentOffset.x - MRTScreen_Width) / MRTScreen_Width;
            
            float space = button2.frame.origin.x - button1.frame.origin.x;
            float x = button1.frame.origin.x  + button1.width * 0.25 + space * ratio;
            
            float difference = width2 - width1;
            float width = width1 * 0.5 + difference * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        } else if (MRTScreen_Width * 2 <= scrollView.contentOffset.x && scrollView.contentOffset.x < MRTScreen_Width * 3) {
            ratio = (scrollView.contentOffset.x - MRTScreen_Width * 2) / MRTScreen_Width;
            
            float space = button3.frame.origin.x - button2.frame.origin.x;
            float x = button2.frame.origin.x + button2.width * 0.25 + space * ratio;
            
            float difference = width3 - width2;
            float width = width2 * 0.5 + difference * ratio;
            _indicatorBar.frame = CGRectMake(x, _indicatorBar.y, width, _indicatorBar.height);
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self autoRefreshTableView];
}

#pragma mark UITableViewDelegate 方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0) {
        MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
        
        commentVC.leftTitle = @"@me";
        commentVC.isFromAt_status = YES;
        //不滚动到评论区
        commentVC.scorllToComment = NO;
        //只显示主微博
        commentVC.onlyOriginal = YES;
        
        MRTMessageStatusCell *statusCell = [tableView cellForRowAtIndexPath:indexPath];
        
        MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
        
        statusFrame.status = statusCell.statusFrame.status;
        commentVC.statusFrame = statusFrame;
        
        //隐藏系统自带tabBar
        commentVC.hidesBottomBarWhenPushed = YES;
        
        
        if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
            [_delegate messageSwitchViewDidSendVC:commentVC present:NO];
        }
    }
    if (tableView.tag == 1) {
        MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
        
        commentVC.leftTitle = @"@me";
        commentVC.isFromAt_status = YES;
        //不滚动到评论区
        commentVC.scorllToComment = NO;
        //是否只显示主微博
        
        commentVC.onlyOriginal = NO;
        
        MRTMessageStatusCell *statusCell = [tableView cellForRowAtIndexPath:indexPath];
        
        MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
        statusFrame.isAtStatus = YES;//直接设置视频地址，不用从网页中抓取
        statusFrame.status = statusCell.statusFrame.comment.status;
        commentVC.statusFrame = statusFrame;
        
        //隐藏系统自带tabBar
        commentVC.hidesBottomBarWhenPushed = YES;
        
        
        if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
            [_delegate messageSwitchViewDidSendVC:commentVC present:NO];
        }
    }
    if (tableView.tag == 2 || tableView.tag == 3) {
        MRTCommentViewController *commentVC = [[MRTCommentViewController alloc] init];
        
        commentVC.leftTitle = @"@me";
        commentVC.isFromAt_status = YES;
        //不滚动到评论区
        commentVC.scorllToComment = NO;
        //是否只显示主微博
        
        commentVC.onlyOriginal = NO;
        
        MRTMessageCommentCell *commentCell = [tableView cellForRowAtIndexPath:indexPath];
        
        MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
        statusFrame.isAtStatus = YES;//直接设置视频地址，不用从网页中抓取
        statusFrame.status = commentCell.commentFrame.comment.status;
        commentVC.statusFrame = statusFrame;
        
        //隐藏系统自带tabBar
        commentVC.hidesBottomBarWhenPushed = YES;
        
        
        if ([_delegate respondsToSelector:@selector(messageSwitchViewDidSendVC:present:)]) {
            [_delegate messageSwitchViewDidSendVC:commentVC present:NO];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return self.at_statusFrames.count;
    } else if (tableView.tag == 1) {
        return self.at_commentFrames.count;
    } else if (tableView.tag == 2) {
        return self.in_commentFrames.count;
    } else if (tableView.tag == 3) {
        return self.out_commentFrames.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableview.tag:%ld", (long)tableView.tag);
    if (tableView.tag == 0) {
        static NSString *ID = @"cell0";
        MRTMessageStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        if (cell == nil) {
            cell = [[MRTMessageStatusCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        
        MRTMessageStatusFrame *statusFrame = self.at_statusFrames[indexPath.row];
        cell.statusFrame = statusFrame;
        cell.statusToolBar.hidden = NO;
        cell.delegate = self;
        
        return cell;
    } else if (tableView.tag == 1) {
        static NSString *ID = @"cell1";
        MRTMessageStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        if (cell == nil) {
            cell = [[MRTMessageStatusCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        MRTMessageStatusFrame *statusFrame = self.at_commentFrames[indexPath.row];
        cell.statusFrame = statusFrame;
        cell.statusToolBar.hidden = YES;
        cell.delegate = self;
        
        return cell;
    } else if (tableView.tag == 2) {
        static NSString *ID = @"cell2";
        MRTMessageCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        if (cell == nil) {
            cell = [[MRTMessageCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        MRTMessageCommentFrame *commentFrame = self.in_commentFrames[indexPath.row];
        cell.commentFrame = commentFrame;
        cell.delegate = self;
        
        return cell;
    } else if (tableView.tag == 3) {
        static NSString *ID = @"cell3";
        MRTMessageCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        if (cell == nil) {
            cell = [[MRTMessageCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        
        MRTMessageCommentFrame *commentFrame = self.out_commentFrames[indexPath.row];
        cell.commentFrame = commentFrame;
        cell.delegate = self;
        
        return cell;
    }
    return nil;
}

//返回cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0) {
        //获取statusFrame
        MRTMessageStatusFrame *statusFrame = self.at_statusFrames[indexPath.row];
        
        //返回cell高度
        return statusFrame.cellHeight;
    } else if (tableView.tag == 1) {
        //获取statusFrame
        MRTMessageStatusFrame *statusFrame = self.at_commentFrames[indexPath.row];
        
        //返回cell高度
        return statusFrame.noBarCellHeight;
    } else if (tableView.tag == 2) {
        MRTMessageCommentFrame *commentFrame = self.in_commentFrames[indexPath.row];
        return commentFrame.cellHeight;
    } else {
        MRTMessageCommentFrame *commentFrame = self.out_commentFrames[indexPath.row];
        return commentFrame.cellHeight;
    }
}

@end
