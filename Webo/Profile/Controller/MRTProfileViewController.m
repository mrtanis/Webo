//
//  MRTProfileViewController.m
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTProfileViewController.h"
#import "MRTOAuthViewController.h"
#import "MRTNavigationController.h"
#import "MRTProfileCell.h"
#import "UIImageView+WebCache.h"
#import "MRTUser.h"
#import "MRTUserInfoTool.h"
#import "Masonry.h"
#import "MRTMyStatusesController.h"
#import "MRTFriendsListController.h"


@interface MRTProfileViewController () <UINavigationControllerDelegate>
@property (nonatomic, strong) MRTUser *user;

@property (nonatomic, weak) UIImageView *headerView;
@property (nonatomic, weak) UIVisualEffectView *blurView;
@property (nonatomic, strong) CADisplayLink *link;

@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat speed;
@property (nonatomic) CGFloat offset2;
@property (nonatomic) CGFloat speed2;
@property (nonatomic) CGFloat waveHeight;
@property (nonatomic) CGFloat waveWidth;
@property (nonatomic) CGFloat h;
@property (nonatomic, strong) CAShapeLayer *layer;
@property (nonatomic, strong) CAShapeLayer *layer2;
@end

@implementation MRTProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    //取消分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //自适应高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 250;

    //-20让tableView与屏幕顶部齐平，200留出空间给headerView
    self.tableView.contentInset = UIEdgeInsetsMake(-20 + 200, 0, 0, 0);
    _user = [MRTUserInfoTool userInfo];
    [self setUpHeaderView];
    [self prepareForWave];
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
}

- (void)setUpHeaderView
{
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -200, self.tableView.width, 200)];
    //以用户头像为背景图
    [headerView sd_setImageWithURL:_user.avatar_hd placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    headerView.contentMode = UIViewContentModeScaleToFill;
    headerView.clipsToBounds = YES;
    [self.tableView addSubview:headerView];
    _headerView = headerView;

    //添加模糊视图
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [headerView addSubview:blurView];
    _blurView = blurView;

    //添加圆形头像
    UIImageView *iconView = [[UIImageView alloc] init];
    [iconView sd_setImageWithURL:_user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    iconView.layer.cornerRadius = 35;
    iconView.clipsToBounds = YES;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [blurView.contentView addSubview:iconView];
    
    //添加昵称
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont boldSystemFontOfSize:20];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = _user.name;
    [nameLabel sizeToFit];
    [blurView.contentView addSubview:nameLabel];
    
    //添加个人简介
    UILabel *introLabel = [[UILabel alloc] init];
    introLabel.font = [UIFont systemFontOfSize:12];
    introLabel.textColor = [UIColor lightGrayColor];
    if (_user.introduction.length) {
        introLabel.text = [NSString stringWithFormat:@"简介:%@", _user.introduction];
    } else {
        introLabel.text = @"简介:暂无介绍";
    }
    
    [introLabel sizeToFit];
    [blurView.contentView addSubview:introLabel];
    
    //添加约束
    [_blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_headerView);
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_blurView.mas_bottom).mas_offset(-61);
        make.left.equalTo(_blurView.mas_left).mas_offset(30);
        make.width.equalTo(@70);
        make.height.equalTo(@70);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconView.mas_top).offset(10);
        make.left.equalTo(iconView.mas_right).offset(10);
    }];
    [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(iconView.mas_bottom).offset(-10);
        make.left.equalTo(iconView.mas_right).offset(10);
    }];
}

- (void)prepareForWave
{
    _offset = 0;
    _speed = 2;
    _offset2 = 0;
    _speed2 = 2;
    _waveWidth = MRTScreen_Width;
    _waveHeight = 6;
    _h = 6;
    _layer = [CAShapeLayer layer];
    _layer.fillColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.6].CGColor;//一定要先设置颜色，如果在绘制波浪时设置颜色打开app时会先显示黑色
    _layer2 = [CAShapeLayer layer];
    _layer2.fillColor = [UIColor whiteColor].CGColor;
    [self.tableView.layer addSublayer:_layer];
    [self.tableView.layer addSublayer:_layer2];
    
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(beginWave)];
    [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)beginWave
{
    _offset += _speed;
    _offset2 += _speed2;
    CGFloat totallHeight = 0;
    //设置第一条波曲线的路径
    CGMutablePathRef pathRef = CGPathCreateMutable();
    //起始点
    CGFloat startY = totallHeight - (_waveHeight*sinf(2.5*M_PI/_waveWidth * 0 + _offset * 2.5*M_PI / _waveWidth) + _h);
    CGPathMoveToPoint(pathRef, NULL, 0, startY);
    //第一个波的公式
    for (CGFloat i = 0.0; i <= _waveWidth; i ++) {
        CGFloat y = totallHeight - (_waveHeight*sinf(2.5*M_PI*i/_waveWidth - (_offset + 10) * 2.5*M_PI / _waveWidth) + _h);
        CGPathAddLineToPoint(pathRef, NULL, i, y);
    }
    CGPathAddLineToPoint(pathRef, NULL, _waveWidth, totallHeight - 0);
    CGPathAddLineToPoint(pathRef, NULL, 0, totallHeight);
    CGPathCloseSubpath(pathRef);
    //设置第一个波layer的path
    
    //_layer.fillColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.6].CGColor;
    _layer.path = pathRef;
    
    CGPathRelease(pathRef);
    
    //设置第二条波曲线的路径
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGFloat startY2 = totallHeight - (_waveHeight*sinf(M_PI) + _h);
    CGPathMoveToPoint(pathRef2, NULL, 0, startY2);
    //第二个波曲线的公式
    for (CGFloat i = 0.0; i <= _waveWidth; i ++) {
        CGFloat y = totallHeight - (_waveHeight*sinf(2.5*M_PI*i/_waveWidth - _offset2 * 2.5*M_PI / _waveWidth + M_PI) + _h);
        CGPathAddLineToPoint(pathRef2, NULL, i, y);
    }
    CGPathAddLineToPoint(pathRef2, NULL, _waveWidth, totallHeight);
    CGPathAddLineToPoint(pathRef2, NULL, 0, totallHeight);
    CGPathCloseSubpath(pathRef2);
    
    //_layer2.fillColor = [UIColor whiteColor].CGColor;
    _layer2.path = pathRef2;
    
    CGPathRelease(pathRef2);

}


//点击切换登录
- (void)accountSwitch:(UIButton *)button
{
    NSLog(@"%s", __func__);
    //进入授权界面
    MRTOAuthViewController *oauthVC = [[MRTOAuthViewController alloc] init];
    oauthVC.presentedByUser = YES;
    
    //由于采用present，此处可不使用自定义导航栏
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:oauthVC];
    
    [self presentViewController:nav animated:YES completion:^{
        NSLog(@"登录页面presented！");
    }];
}

#pragma mark - 点击按钮
- (void)clickButton:(UIButton *)button
{
    if (button.tag == 0) {
        MRTMyStatusesController *statusesVC = [[MRTMyStatusesController alloc] init];
        statusesVC.leftTitle = @"我";
        statusesVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:statusesVC animated:YES];
        
    }
    if (button.tag == 1) {
        MRTFriendsListController *friendsVC = [[MRTFriendsListController alloc] init];
        friendsVC.type = MRTListControllerTypeFriends;
        friendsVC.leftTitle = @"我";
        friendsVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:friendsVC animated:YES];
    }
    if (button.tag == 2) {
        MRTFriendsListController *followersVC = [[MRTFriendsListController alloc] init];
        followersVC.type = MRTListControllerTypeFollewers;
        followersVC.leftTitle = @"我";
        followersVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:followersVC animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    MRTProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"firstCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MRTProfileCell" owner:nil options:0][0];
    }
    
    NSMutableDictionary *attrTop = [NSMutableDictionary dictionary];
    attrTop[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
    attrTop[NSForegroundColorAttributeName] = [UIColor orangeColor];
    
    NSMutableDictionary *attrBottom = [NSMutableDictionary dictionary];
    attrBottom[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    attrBottom[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    NSMutableAttributedString *statuses = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"微博\n%d", _user.statuses_count]];
    [statuses addAttributes:attrTop range:NSMakeRange(0, 2)];
    [statuses addAttributes:attrBottom range:NSMakeRange(2, statuses.length - 2)];
    [cell.statusesButton setAttributedTitle:statuses forState:UIControlStateNormal];
    cell.statusesButton.tag = 0;
    [cell.statusesButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];

    
    NSMutableAttributedString *friends = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"关注\n%d", _user.friends_count]];
    [friends addAttributes:attrTop range:NSMakeRange(0, 2)];
    [friends addAttributes:attrBottom range:NSMakeRange(2, friends.length - 2)];
    [cell.friendsButton setAttributedTitle:friends forState:UIControlStateNormal];
    cell.friendsButton.tag = 1;
    [cell.friendsButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];

    
    NSMutableAttributedString *followers = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"粉丝\n%d", _user.followers_count]];
    [followers addAttributes:attrTop range:NSMakeRange(0, 2)];
    [followers addAttributes:attrBottom range:NSMakeRange(2, followers.length - 2)];
    [cell.followersButton setAttributedTitle:followers forState:UIControlStateNormal];
    cell.followersButton.tag = 2;
    [cell.followersButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.accountSwitchButton addTarget:self action:@selector(accountSwitch:) forControlEvents:UIControlEventTouchUpInside];

    
    return cell;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {

        _headerView.frame = CGRectMake(0, scrollView.contentOffset.y, MRTScreen_Width, - scrollView.contentOffset.y);
        
    }
}

- (void)dealloc
{
    [_link invalidate];
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
