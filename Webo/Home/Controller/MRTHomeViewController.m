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

@interface MRTHomeViewController () <MRTCoverDelegate>

@property (nonatomic, weak) MRTHomeTitle *titleButton;
@property (nonatomic, strong) MRTMenuViewController *menu;

@end

@implementation MRTHomeViewController

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
    NSLog(@"%s", __func__);
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
