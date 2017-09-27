//
//  MRTImageViewerController.m
//  Webo
//
//  Created by mrtanis on 2017/9/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTImageViewerController.h"
#import "MRTImageViewerCell.h"

@interface MRTImageViewerController () <UINavigationControllerDelegate>

@end

@implementation MRTImageViewerController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(MRTScreen_Width, MRTScreen_Height - 64);
    //layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"self.collectionView.bounds.size(%f, %f)", self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    self.collectionView.pagingEnabled = YES;
    self.collectionView.frame = CGRectMake(-5, 0, MRTScreen_Width + 10, self.collectionView.height);
    //设置白色背景
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self setUpNavigationBar];
    
    // Register cell classes
    [self.collectionView registerClass:[MRTImageViewerCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 设置导航栏
- (void)setUpNavigationBar
{
    self.title = @"相机胶卷";
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionary];
    titleAttrs[NSForegroundColorAttributeName] = [UIColor darkTextColor];
    self.navigationController.navigationBar.titleTextAttributes = titleAttrs;
    
    //左侧按钮
    //自定义取消按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    
    [leftButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    //右侧按钮
    //自定义发送按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightButton addTarget:self action:@selector(sendWebo) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_white_disable"] forState:UIControlStateDisabled];
    [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange_highlighted"] forState:UIControlStateHighlighted];
    
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightButton setTitle:@"下一步" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [rightButton sizeToFit];
    CGRect rect = rightButton.frame;
    rect.size = CGSizeMake(50, 30);
    rightButton.frame = rect;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    //未输入文字时不可点击
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRTImageViewerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //cell.photo = [UIImage imageNamed:@"new_feature_1"];
    
    PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];//请求选项设置
    options.resizeMode=PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
    
    options.synchronous=NO;   //YES 一定是同步    NO不一定是异步
    
    
    //CGFloat scale = [UIScreen mainScreen].scale;
    //CGSize size =CGSizeMake((MRTScreen_Width - 3) / 4.0 * scale, (MRTScreen_Width - 3) / 4.0 * scale);
    
    [[PHImageManager defaultManager] requestImageForAsset:self.assets[indexPath.item] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.photo = result;
        });
    }];
    
    return cell;
}



#pragma mark <UIScrollViewDelegate>

    


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
