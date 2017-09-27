//
//  MRTImagePickerController.m
//  Webo
//
//  Created by mrtanis on 2017/9/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTImagePickerController.h"
#import "MRTImagePickerCell.h"
#import "MRTImageViewerCell.h"
#import <Photos/Photos.h>
#import "MRTImageViewerController.h"
#import "MRTNavigationController.h"
#import "MRTImageViewerLayout.h"

@interface MRTImagePickerController () <UINavigationControllerDelegate, MRTImagePickerCellDelegate>

@property (nonatomic, copy) NSMutableArray *collections;
@property (nonatomic, strong) PHFetchResult *assets;
@property (nonatomic, copy) NSMutableArray *selectedAssets;
@property (nonatomic, copy) NSMutableArray *assetsArray;

@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UIButton *previewButton;
@property (nonatomic, weak) UICollectionView *imageViewer;
@property (nonatomic, weak) UIView *imageViewerNavBar;

@end

@implementation MRTImagePickerController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - 数组懒加载
- (NSMutableArray *)collections
{
    if (!_collections) {
        _collections = [NSMutableArray array];
    }
    
    return _collections;
}

- (NSMutableArray *)selectedAssets
{
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    
    return _selectedAssets;
}

- (NSMutableArray *)assetsArray
{
    if (!_assetsArray) {
        _assetsArray = [NSMutableArray array];
    }
    return _assetsArray;
}

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((MRTScreen_Width - 3) / 4.0, (MRTScreen_Width - 3) / 4.0);
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    //layout.sectionInset = UIEdgeInsetsMake(0, 0, 44, 0); //为下部工具栏预留位置
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏
    [self setUpNavigationBar];
    //设置工具栏
    [self setUpToolBar];
    //设置白色背景
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //取消自动设置scrollViewInsets,改为手动设置collectionView的frame
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGRect rect = self.collectionView.frame;
    rect.origin.y = 64;
    rect.size.height -= 44 + 64;
    self.collectionView.frame = rect;
    //获取assetCollections和assets（此处只获取内容为照片的asset
    [self preparePhotos];
    
    // Register cell classes
    [self.collectionView registerClass:[MRTImagePickerCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHCachingImageManager *manager = [[PHCachingImageManager alloc] init];
        
        [_assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = obj;
            [weakSelf.assetsArray addObject:asset];
        }];
        
        PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];//请求选项设置
        options.resizeMode=PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        
        
        options.synchronous=NO;
        [manager startCachingImagesForAssets:weakSelf.assetsArray targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options];
    });
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
    //自定义返回按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    
    [leftButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    //右侧按钮
    //自定义下一步按钮
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
    _rightButton = rightButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    //未选择照片时不可点击
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark 设置工具栏
- (void)setUpToolBar
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    toolBar.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    [self.view addSubview:toolBar];
    
    UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previewButton.enabled = NO;
    [previewButton setBackgroundImage:[UIImage imageNamed:@"compose_photo_preview_seleted"] forState:UIControlStateNormal];
    [previewButton setBackgroundImage:[UIImage imageNamed:@"compose_photo_preview_disable"] forState:UIControlStateDisabled];
    [previewButton setBackgroundImage:[UIImage imageNamed:@"compose_photo_preview_highlighted"] forState:UIControlStateHighlighted];
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [previewButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    previewButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [previewButton sizeToFit];
    previewButton.center = CGPointMake(previewButton.width * 0.5 + 10, toolBar.height * 0.5);
    [previewButton addTarget:self action:@selector(clickPreview:) forControlEvents:UIControlEventTouchUpInside];
    _previewButton = previewButton;
    [toolBar addSubview:previewButton];
    
    UIButton *originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [originalButton setBackgroundImage:[UIImage imageNamed:@"compose_photo_original_disable"] forState:UIControlStateNormal];
    [originalButton setBackgroundImage:[UIImage imageNamed:@"compose_photo_original_highlighted"] forState:UIControlStateSelected];
    [originalButton setTitle:@"原图" forState:UIControlStateNormal];
    [originalButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    originalButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [originalButton sizeToFit];
    originalButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    originalButton.titleEdgeInsets = UIEdgeInsetsMake(0, originalButton.width * 0.3, 0, 0);
    originalButton.center = CGPointMake(CGRectGetMaxX(previewButton.frame) +originalButton.width * 0.5 + 10, toolBar.height * 0.5);
    [originalButton addTarget:self action:@selector(clickOriginal:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:originalButton];
}

#pragma mark - 获取相册和照片
- (void)preparePhotos
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            //智能相册
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            //按照 PHAssetCollection 的startDate 升序排序
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                PHFetchResult *collectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
                NSLog(@"there are %ld collections", collectionsResult.count);
                
                
                [collectionsResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PHAssetCollection *assetCollection = obj;
                    
                    PHFetchOptions *fetchAssetOption = [[PHFetchOptions alloc] init];
                    fetchAssetOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];//按照日期降序排序
                    fetchAssetOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];//过滤剩下照片类型
                    PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchAssetOption];
                    
                    //只选择有照片的相册，屏蔽“最近删除”和“已隐藏”这两个相册
                    if (assetsResult.count && ![assetCollection.localizedTitle isEqualToString:@"最近删除"] && ![assetCollection.localizedTitle isEqualToString:@"已隐藏"]) {
                        //将符合条件的collection加入数组
                        [self.collections addObject:assetCollection];
                        //保存相机胶卷的assets（默认显示相机胶卷的照片)
                        if ([assetCollection.localizedTitle isEqualToString:@"相机胶卷"]) {
                            NSLog(@"保存相机胶卷");
                            _assets = assetsResult;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.collectionView reloadData];
                            });
                            
                        }
                    }
                    NSLog(@"assetCollection name:%@, there are %ld assets", assetCollection.localizedTitle, assetsResult.count);
                }];
            }
        }];
    });

    
}

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 选择照片
- (void)clickChooseButtton:(UIButton *)button AtIndex:(NSInteger)index
{
    
    if ((!button.selected) && self.selectedAssets.count < 9) {
        button.selected = !button.selected;
        [self.selectedAssets addObject:[self.assets objectAtIndex:index]];
    } else if (button.selected) {
        button.selected = !button.selected;
        [self.selectedAssets removeObject:[self.assets objectAtIndex:index]];
    }
    
    if (self.selectedAssets.count) {

        _previewButton.enabled = YES;
        _rightButton.enabled = YES;
        [_rightButton setTitle:[NSString stringWithFormat:@"下一步(%ld)", self.selectedAssets.count] forState:UIControlStateNormal];
        [_rightButton sizeToFit];
        CGRect rect = _rightButton.frame;
        rect.size = CGSizeMake(80, 30);
        _rightButton.frame = rect;
    } else {
        _previewButton.enabled = NO;
        _rightButton.enabled = NO;
        [_rightButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_rightButton sizeToFit];
        CGRect rect = _rightButton.frame;
        rect.size = CGSizeMake(50, 30);
        _rightButton.frame = rect;
    }
}


#pragma mark 工具栏按钮
- (void)clickPreview:(UIButton *)button
{
    
}

- (void)clickOriginal:(UIButton *)button
{
    button.selected = !button.selected;
    
}

- (void)tapToCloseImageViewer:(UITapGestureRecognizer *)gesture
{
    [_imageViewer removeFromSuperview];
    [_imageViewerNavBar removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 2) {
        return self.assets.count;
    } else {
        NSLog(@"assets.count:%ld", _assets.count);
        return self.assets.count;
    }
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 2) {
        MRTImageViewerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"viewerCell" forIndexPath:indexPath];
        
        //cell.backgroundColor = [UIColor blueColor];
        
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
    } else {
        MRTImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        cell.delegate = self;
        cell.index = indexPath.item;
        cell.backgroundColor = [UIColor orangeColor];
        
        PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];//请求选项设置
        options.resizeMode=PHImageRequestOptionsResizeModeExact;
        options.synchronous=NO;   //YES 一定是同步    NO不一定是异步
        
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size =CGSizeMake((MRTScreen_Width - 3) / 4.0 * scale, (MRTScreen_Width - 3) / 4.0 * scale);
        
        [[PHImageManager defaultManager] requestImageForAsset:self.assets[indexPath.item] targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.photo = result;
            });
        }];
        
        
        
        return cell;
    }
    
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 2) {
        
    } else {
        //点击图片从小图位置放大
        MRTImagePickerCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
        
        CGRect beginRect = [cell convertRect:cell.photoView.frame toView:self.view];
        NSLog(@"collectionView.contentOffset.y:%f", self.collectionView.contentOffset.y);
        beginRect.origin.y += 64;//offset.y为负数
        
        MRTImageViewerLayout *layout = [[MRTImageViewerLayout alloc] initWithItemSize:beginRect.size];
        layout.beginIndex = indexPath.item;
        
        UICollectionView *imageViewer = [[UICollectionView alloc] initWithFrame:beginRect collectionViewLayout:layout];
        
        imageViewer.tag = 2;
        imageViewer.delegate = self;
        imageViewer.dataSource = self;
        imageViewer.pagingEnabled = YES;
        imageViewer.backgroundColor = [UIColor whiteColor];
        [imageViewer registerClass:[MRTImageViewerCell class] forCellWithReuseIdentifier:@"viewerCell"];
        
        [self.view addSubview:imageViewer];
        _imageViewer = imageViewer;
        //隐藏控制器导航栏
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        //自制imageViewer导航栏
        UIView *imageViewerNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MRTScreen_Width, 64)];
        imageViewerNavBar.backgroundColor = [UIColor whiteColor];
        
        
        //设置张数标题
        UILabel *title = [[UILabel alloc] init];
        title.font = [UIFont boldSystemFontOfSize:16];
        title.text = [NSString stringWithFormat:@"%ld/%ld", indexPath.item + 1, _assets.count];
        title.textColor = [UIColor darkTextColor];
        [title sizeToFit];
        title.center = CGPointMake(imageViewerNavBar.width * 0.5, 44 * 0.5 + 20);
        [imageViewerNavBar addSubview:title];
        //设置左侧按钮
        UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
        [left setTitle:@"返回" forState:UIControlStateNormal];
        left.titleLabel.font = [UIFont systemFontOfSize:15];
        [left setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [left setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [left setImage:[UIImage imageNamed:@"navigationbar_back_withtext"] forState:UIControlStateNormal];
        [left setImage:[UIImage imageNamed:@"navigationbar_back_withtext_highlighted"] forState:UIControlStateHighlighted];
        [left sizeToFit];
        left.center = CGPointMake(MRTStatusCellMargin + left.width * 0.5, 44 * 0.5 + 20);
        [left addTarget:self action:@selector(tapToCloseImageViewer:) forControlEvents:UIControlEventTouchUpInside];
        [imageViewerNavBar addSubview:left];
        //右侧按钮
        //自定义下一步按钮
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
        rightButton.center = CGPointMake(imageViewerNavBar.width - rightButton.width * 0.5 - MRTStatusCellMargin, 44 * 0.5 + 20);
        [imageViewerNavBar addSubview:rightButton];
        [self.view addSubview:imageViewerNavBar];
        _imageViewerNavBar = imageViewerNavBar;
        
        
        [UIView animateWithDuration:3 animations:^{
            imageViewer.frame = CGRectMake(-5, 64, MRTScreen_Width + 10, MRTScreen_Height - 64);
            layout.itemSize = CGSizeMake(imageViewer.width - 10, imageViewer.height);
        }];
        
        
        /*
         MRTImageViewerController *imageViewer = [[MRTImageViewerController alloc] init];
         imageViewer.assets = self.assets;
         imageViewer.index = indexPath.item;
         MRTNavigationController *nav = [[MRTNavigationController alloc] initWithRootViewController:imageViewer];
         
         [self presentViewController:nav animated:YES completion:nil];
         */
    }
    
    
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}*/


/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}*/


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
