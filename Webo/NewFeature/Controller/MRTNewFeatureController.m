//
//  MRTNewFeatureController.m
//  Webo
//
//  Created by mrtanis on 2017/5/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTNewFeatureController.h"
#import "MRTNewFeatureCell.h"

@interface MRTNewFeatureController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIPageControl *pageControl;


@end

@implementation MRTNewFeatureController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    //设置cell尺寸
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    
    //清空行距
    layout.minimumLineSpacing = 0;
    
    //设置滚动的方向
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[MRTNewFeatureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //分页
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self setUpPageControl];
    
}

- (void)setUpPageControl
{
    //添加pageController，只需要设置位置，不需要管理尺寸
    UIPageControl *control = [[UIPageControl alloc] init];
    
    control.numberOfPages = 4;
    control.pageIndicatorTintColor = [UIColor blackColor];
    control.currentPageIndicatorTintColor = [UIColor redColor];
    
    //设置pageControl的center
    control.center = CGPointMake(self.view.width * 0.5, self.view.height - 5);
    _pageControl = control;
    
    [self.view addSubview:control];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //计算当前页数,加0.5保证在页面滑动到中间时开始切换页面指示点
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5;//int进行了取整运算，舍弃了小数部分
    
    //设置页数
    _pageControl.currentPage = page;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRTNewFeatureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger page = indexPath.item;
    
    switch (page) {
        case 0:
            cell.backgroundColor = [UIColor redColor];
            break;
        case 1:
            cell.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            cell.backgroundColor = [UIColor purpleColor];
            break;
        case 3:
            cell.backgroundColor = [UIColor orangeColor];
            break;
            
        default:
            break;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"new_feature_%ld", indexPath.row + 1];
    NSLog(@"%@", imageName);
    cell.image = [UIImage imageNamed:imageName];
    
    //判断是否需要显示两个按钮
    [cell checkIndexPath:indexPath pageCount:4];
    
    return cell;
}

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
