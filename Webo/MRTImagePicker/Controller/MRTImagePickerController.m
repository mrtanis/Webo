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
#import "MRTImagePickerCameraCell.h"
#import <Photos/Photos.h>
#import "MRTNavigationController.h"
#import "MRTImageViewerLayout.h"
#import "MRTTextViewController.h"

@interface MRTImagePickerController () <UINavigationControllerDelegate, MRTImagePickerCellDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSMutableArray *collections;
@property (nonatomic, strong) PHFetchResult *assets;

@property (nonatomic, copy) NSMutableArray *assetsArray;
@property (nonatomic, copy) NSMutableArray *selectedIndexes;
@property (nonatomic, copy) NSMutableArray *previewSelectedIndexes;

@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UIButton *previewRightButton;
@property (nonatomic, weak) UIView *rightButtonBG;
@property (nonatomic, weak) UIButton *previewButton;
@property (nonatomic, weak) UIButton *originalButton;
@property (nonatomic, weak) UILabel *sizeLabel;
@property (nonatomic, weak) UICollectionView *imageViewer;
@property (nonatomic, weak) UIView *imageViewerNavBar;
@property (nonatomic, weak) UILabel *imageViewerTitle;
@property (nonatomic, weak) UIButton *previewSelectButton;
@property (nonatomic, weak) UIImageView *temporaryView;

@property (nonatomic) NSInteger currentPreviewIndex;
@property (nonatomic) BOOL onlySelected;

@end

@implementation MRTImagePickerController
@synthesize selectedAssets = _selectedAssets;

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseIdentifierCamera = @"cameraCell";
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

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets
{
    _selectedAssets = [[NSMutableArray alloc] initWithArray:selectedAssets];
}
/*
- (NSMutableArray *)alreadySelectedPhotoAssets
{
    if (!_alreadySelectedPhotoAssets) {
        _alreadySelectedPhotoAssets = [NSMutableArray array];
    }
    return _alreadySelectedPhotoAssets;
}*/


- (NSMutableArray *)assetsArray
{
    if (!_assetsArray) {
        _assetsArray = [NSMutableArray array];
    }
    return _assetsArray;
}

- (NSMutableArray *)selectedIndexes
{
    if (!_selectedIndexes) {
        _selectedIndexes = [NSMutableArray array];
    }
    return _selectedIndexes;
}

- (NSMutableArray *)previewSelectedIndexes
{
    if (!_previewSelectedIndexes) {
        _previewSelectedIndexes = [NSMutableArray array];
    }
    return _previewSelectedIndexes;
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
    
    //设置collectionView的frame
    CGRect rect = self.collectionView.frame;
    rect.origin.y = 64;
    
    if (!_singleImageMode) {
        rect.size.height -= 44 + 64;
        //设置工具栏
        [self setUpToolBar];
    } else {
        rect.size.height -= 64;
    }
    self.collectionView.frame = rect;
    
    //设置白色背景
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //取消自动设置scrollViewInsets,改为手动设置collectionView的frame
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //获取assetCollections和assets（此处只获取内容为照片的asset
    [self preparePhotos];
    
    // Register cell classes
    [self.collectionView registerClass:[MRTImagePickerCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[MRTImagePickerCameraCell class] forCellWithReuseIdentifier:reuseIdentifierCamera];
    
    // Do any additional setup after loading the view.
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
    if (!_singleImageMode) {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [rightButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
        
        [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_white_disable"] forState:UIControlStateDisabled];
        [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange"] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange_highlighted"] forState:UIControlStateHighlighted];
        
        rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [rightButton setTitle:@"下一步" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [rightButton sizeToFit];
        //rightButton.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        CGRect rect = rightButton.frame;
        rect.size = CGSizeMake(60, 28);
        rightButton.frame = rect;
        //未选择照片时不可点击
        rightButton.enabled = NO;
        _rightButton = rightButton;
        //添加按钮背景（iOS 11直接将uibutton设置为rightButtonItem的customView按钮不能调到最小）
        UIView *rightButtonBG = [[UIView alloc] initWithFrame:rightButton.frame];
        rightButtonBG.backgroundColor = [UIColor clearColor];
        [rightButtonBG addSubview:rightButton];
        _rightButtonBG = rightButtonBG;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonBG];
    }
    
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
    //判断之前是否选择了原图模式
    if (_originalMode) {
        originalButton.selected = YES;
        [self getSizeOfPhotos];
    }
    _originalButton = originalButton;
    
    UILabel *sizeLabel = [[UILabel alloc] init];
    sizeLabel.font = [UIFont systemFontOfSize:14];
    sizeLabel.textColor = [UIColor darkTextColor];
    sizeLabel.backgroundColor = [UIColor clearColor];
    [sizeLabel sizeToFit];
    sizeLabel.center = CGPointMake(CGRectGetMaxX(originalButton.frame) + sizeLabel.width * 0.5 + 10, toolBar.height * 0.5);
    [toolBar addSubview:sizeLabel];
    _sizeLabel = sizeLabel;
}

#pragma mark - 获取相册和照片
- (void)preparePhotos
{
    typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        typeof (weakSelf) strongSelf = weakSelf;
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
                            for (PHAsset *asset in strongSelf.selectedAssets) {
                                for (int i = 0; i < _assets.count; i++) {
                                    if ([asset.localIdentifier isEqual:[_assets[i] localIdentifier]]) {
                                        [strongSelf.selectedIndexes addObject:[NSNumber numberWithInteger:i]];
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf.collectionView reloadData];
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
    if (_photosBlock) {
        
        _photosBlock(NULL, NO);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)nextStep:(UIButton *)button
{
    if (_directEnter) {
        MRTTextViewController *textVC = [[MRTTextViewController alloc] init];
        textVC.photoAssets = self.selectedAssets;
        textVC.originalMode = _originalButton.selected;
        textVC.shouldSetUpPhotoView = YES;
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:textVC];
        
        UIViewController *presentingVC = self.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^{
            [presentingVC presentViewController:navVC animated:YES completion:nil];
        }];
    } else {
        //传递选择的照片
        if (_photosBlock) {
            _photosBlock(self.selectedAssets, _originalButton.selected);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)previewNextStep:(UIButton *)button
{
    if (_directEnter) {
        if (_onlySelected) {
            for (int i = 0; i < self.selectedIndexes.count; i++) {
                if (![self.previewSelectedIndexes containsObject:[NSNumber numberWithInteger:i]]) {
                    [self.selectedAssets removeObjectAtIndex:i];
                    [self.selectedIndexes removeObjectAtIndex:i];
                }
            }
        }
        
        MRTTextViewController *textVC = [[MRTTextViewController alloc] init];
        textVC.photoAssets = self.selectedAssets;
        textVC.originalMode = _originalButton.selected;
        textVC.shouldSetUpPhotoView = YES;
        MRTNavigationController *navVC = [[MRTNavigationController alloc] initWithRootViewController:textVC];
        
        UIViewController *presentingVC = self.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^{
            [presentingVC presentViewController:navVC animated:YES completion:nil];
        }];
    } else {
        if (_singleImageMode) {
            [self dismissViewControllerAnimated:YES completion:^{
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:_assets[_currentPreviewIndex]];
                //传递选择的照片
                if (_photosBlock) {
                    _photosBlock(array, YES);
                }
            }];
            
        } else {
            if (_onlySelected) {
                for (int i = 0; i < self.selectedIndexes.count; i++) {
                    if (![self.previewSelectedIndexes containsObject:[NSNumber numberWithInteger:i]]) {
                        [self.selectedAssets removeObjectAtIndex:i];
                        [self.selectedIndexes removeObjectAtIndex:i];
                    }
                }
            }
            //传递选择的照片
            if (_photosBlock) {
                _photosBlock(self.selectedAssets, _originalButton.selected);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    
    
}

#pragma mark 选择照片
- (void)previewChoose:(UIButton *)button
{
    //button.selected = !button.selected;

    if (!button.selected) {
        
        if (_onlySelected && self.previewSelectedIndexes.count < 9) {
            
            [self.previewSelectedIndexes insertObject:[NSNumber numberWithInteger:_currentPreviewIndex] atIndex:_currentPreviewIndex];
            button.selected = YES;
        } else if (!_onlySelected && self.selectedIndexes.count < 9){
            [self.selectedIndexes addObject:[NSNumber numberWithInteger:_currentPreviewIndex]];
            [self.selectedAssets addObject:_assets[_currentPreviewIndex]];
            button.selected = YES;
        }
        
        
    } else {
        if (_onlySelected) {
            [self.previewSelectedIndexes removeObject:[NSNumber numberWithInteger:_currentPreviewIndex]];
        } else {
            [self.selectedIndexes removeObject:[NSNumber numberWithInteger:_currentPreviewIndex]];
            [self.selectedAssets removeObject:_assets[_currentPreviewIndex]];
        }
        button.selected = NO;
    }
    NSInteger index;
    if (_onlySelected) {
        index = [self.selectedIndexes[_currentPreviewIndex] integerValue] + 1;
    } else {
        index = _currentPreviewIndex + 1;
    }
    MRTImagePickerCell *pickerCell = (MRTImagePickerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    pickerCell.chooseButton.selected = button.selected;
    [self setPreviewButtonStatus];
    [self setPickerViewButtonStatus];
    
}

- (void)clickChooseButtton:(UIButton *)button AtIndex:(NSInteger)index
{
    
    if ((!button.selected) && self.selectedAssets.count < 9) {
        button.selected = !button.selected;
        [self.selectedAssets addObject:[self.assets objectAtIndex:index]];
        [self.selectedIndexes addObject:[NSNumber numberWithInteger:index]];
    } else if (button.selected) {
        button.selected = !button.selected;
        [self.selectedAssets removeObject:[self.assets objectAtIndex:index]];
        [self.selectedIndexes removeObject:[NSNumber numberWithInteger:index]];
    }
    
    [self setPickerViewButtonStatus];
    if (self.selectedAssets.count && _originalButton.selected) {
        [self getSizeOfPhotos];
    } else {
        _sizeLabel.text = @"";
    }
}

#pragma mark - 设置预览按钮和下一步按钮的状态
- (void)setPickerViewButtonStatus
{
    if (self.selectedAssets.count) {
        
        _previewButton.enabled = YES;
        _rightButton.enabled = YES;
        [_rightButton setTitle:[NSString stringWithFormat:@"下一步(%ld)", self.selectedAssets.count] forState:UIControlStateNormal];
        
        _rightButtonBG.frame = CGRectMake(_rightButtonBG.x, _rightButtonBG.y, 80, 28);
        _rightButton.frame = _rightButtonBG.bounds;
        NSLog(@"rightButton.size(%f, %f)", _rightButton.width, _rightButton.height);
    } else {
        _previewButton.enabled = NO;
        _rightButton.enabled = NO;
        [_rightButton setTitle:@"下一步" forState:UIControlStateNormal];
        _rightButtonBG.frame = CGRectMake(_rightButtonBG.x, _rightButtonBG.y, 60, 28);
        _rightButton.frame = _rightButtonBG.bounds;
        NSLog(@"rightButton.size(%f, %f)", _rightButton.width, _rightButton.height);
    }
}

#pragma mark - 设置预览界面下一步按钮的状态
- (void)setPreviewButtonStatus
{
    if (_singleImageMode) {
        _previewRightButton.enabled = YES;
        [_previewRightButton setTitle:@"下一步" forState:UIControlStateNormal];
        CGRect rect = _previewRightButton.frame;
        rect.size = CGSizeMake(60, 28);
        rect.origin = CGPointMake(MRTScreen_Width - rect.size.width - 20, 20 + 44 * 0.5 - rect.size.height * 0.5);
        _previewRightButton.frame = rect;
    } else {
        NSArray *array = [NSArray array];
        if (_onlySelected) {
            array = self.previewSelectedIndexes;
        } else {
            array = self.selectedIndexes;
        }
        if (array.count) {
            _previewRightButton.enabled = YES;
            [_previewRightButton setTitle:[NSString stringWithFormat:@"下一步(%ld)", array.count] forState:UIControlStateNormal];
            CGRect rect = _previewRightButton.frame;
            rect.size = CGSizeMake(80, 28);
            rect.origin = CGPointMake(MRTScreen_Width - rect.size.width - 20, 20 + 44 * 0.5 - rect.size.height * 0.5);
            _previewRightButton.frame = rect;
        } else {
            _previewRightButton.enabled = NO;
            [_previewRightButton setTitle:@"下一步" forState:UIControlStateNormal];
            CGRect rect = _previewRightButton.frame;
            rect.size = CGSizeMake(60, 28);
            rect.origin = CGPointMake(MRTScreen_Width - rect.size.width - 20, 20 + 44 * 0.5 - rect.size.height * 0.5);
            _previewRightButton.frame = rect;
        }
    }
}

#pragma mark 工具栏按钮
- (void)clickPreview:(UIButton *)button
{
    _onlySelected = YES;
    /*
    NSInteger smallestIndex = [(NSNumber *)(self.selectedIndexes[0]) integerValue];
    for (int i = 1; i < self.selectedIndexes.count; i++) {
        if ([(NSNumber *)(self.selectedIndexes[i]) integerValue] < smallestIndex) {
            smallestIndex = [(NSNumber *)(self.selectedIndexes[i]) integerValue];
        }
    }*/
    [self.previewSelectedIndexes removeAllObjects];
    for (int i = 0; i < self.selectedIndexes.count; i++) {
        NSNumber *m = [NSNumber numberWithInteger:i];
        [self.previewSelectedIndexes addObject:m];
    }
    [self enterPreviewFromIndex:[NSIndexPath indexPathForItem:[(NSNumber *)(self.selectedIndexes[0]) integerValue] + 1 inSection:0]];
}

- (void)clickOriginal:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (self.selectedAssets.count == 0 || !button.selected) {
        _sizeLabel.text = @"";
        return;
    }
    
    [self getSizeOfPhotos];
}

- (void)getSizeOfPhotos
{
    __block NSInteger photosSize = 0;
    __block NSInteger compressPhotoSize = 0;
    for (int i = 0; i < self.selectedAssets.count; i++) {
        PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.synchronous=NO;
        typeof (self) weakSelf = self;
        [[PHImageManager defaultManager] requestImageDataForAsset:self.selectedAssets[i] options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            typeof (weakSelf) strongSelf = weakSelf;
            UIImage *image = [UIImage imageWithData:imageData];
            NSData *compressData = UIImageJPEGRepresentation(image, 0.5);
            compressPhotoSize += compressData.length;
            photosSize += imageData.length;
            if (i == strongSelf.selectedAssets.count - 1) {
                CGFloat Msize = photosSize / (1024.0 * 1024.0);
                CGFloat Ksize = photosSize / 1024.0;
                NSString *sizeStr = @"";
                if (Msize >= 1) {
                    sizeStr = [NSString stringWithFormat:@"%.1f M", Msize];
                    NSLog(@"图片总共%.1f M", Msize);
                } else {
                    sizeStr = [NSString stringWithFormat:@"%.1f K", Ksize];
                    NSLog(@"图片总共%.1f K", Ksize);
                }
                NSLog(@"压缩体积%.1f M，%.1f K", compressPhotoSize / (1024.0 * 1024.0), compressPhotoSize / 1024.0);
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.sizeLabel.text = sizeStr;
                    [strongSelf.sizeLabel sizeToFit];
                    strongSelf.sizeLabel.center = CGPointMake(CGRectGetMaxX(strongSelf.originalButton.frame) + 10 + strongSelf.sizeLabel.width * 0.5, CGRectGetMidY(strongSelf.originalButton.frame));
                    
                });
            }
        }];
    }
}

- (void)tapToCloseImageViewer:(UITapGestureRecognizer *)gesture
{
    
    [self exitPreview];
    if (_onlySelected) {
        for (int i = 0; i < self.selectedIndexes.count; i++) {
            if (![self.previewSelectedIndexes containsObject:[NSNumber numberWithInteger:i]]) {
                [self.selectedAssets removeObjectAtIndex:i];
                [self.selectedIndexes removeObjectAtIndex:i];
            }
        }
    }
    
    [self setPickerViewButtonStatus];
    _onlySelected = NO;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 2) {
        if (_onlySelected) {
            return self.selectedAssets.count;
        } else {
            return self.assets.count;
        }
        
    } else {
        return self.assets.count;
    }
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 2) {
        MRTImageViewerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"viewerCell" forIndexPath:indexPath];
        
        PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];
        options.resizeMode=PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.synchronous=NO;   //YES 一定是同步    NO不一定是异步
        
        NSMutableArray *assets = [NSMutableArray array];
        if (_singleImageMode) {
            for (PHAsset *asset in self.assets) {
                [assets addObject:asset];
            }
        } else {
            if (_onlySelected) {
                assets = self.selectedAssets;
            } else {
                for (PHAsset *asset in self.assets) {
                    [assets addObject:asset];
                }
            }
        }
        
        
        [[PHImageManager defaultManager] requestImageForAsset:assets[indexPath.item] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.photo = result;
            });
        }];
        
        return cell;
    } else {
        if (_singleImageMode) {
            MRTImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
            
            cell.singleImageMode = _singleImageMode;
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
            /*
             for (PHAsset *asset in self.alreadySelectedPhotoAssets) {
             NSLog(@"asset.localIdentifier:%@", asset.localIdentifier);
             NSLog(@"[self.assets[indexPath.item] localIdentifier] :%@", [self.assets[indexPath.item] localIdentifier]);
             if ([asset.localIdentifier isEqual:[self.assets[indexPath.item] localIdentifier]]) {
             cell.chooseButton.selected = YES;
             [self.selectedAssets addObject:self.assets[indexPath.item]];
             [self.selectedIndexes addObject:[NSNumber numberWithInteger:indexPath.item]];
             }
             }
             [self setPickerViewButtonStatus];
             */
            cell.chooseButton.selected = NO;
            for (NSNumber *number in self.selectedIndexes) {
                //NSLog(@"selectedIndex:%ld, indexPath.item:%ld", [number integerValue], indexPath.item);
                if ([number integerValue] == indexPath.item) {
                    cell.chooseButton.selected = YES;
                    [self setPickerViewButtonStatus];
                }
            }
            return cell;
        } else {
            if (indexPath.item == 0) {
                MRTImagePickerCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCamera forIndexPath:indexPath];
                
                return cell;
            } else {
                MRTImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
                
                cell.singleImageMode = _singleImageMode;
                cell.delegate = self;
                cell.index = indexPath.item - 1;
                cell.backgroundColor = [UIColor orangeColor];
                
                PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];//请求选项设置
                options.resizeMode=PHImageRequestOptionsResizeModeExact;
                options.synchronous=NO;   //YES 一定是同步    NO不一定是异步
                
                
                CGFloat scale = [UIScreen mainScreen].scale;
                CGSize size =CGSizeMake((MRTScreen_Width - 3) / 4.0 * scale, (MRTScreen_Width - 3) / 4.0 * scale);
                
                [[PHImageManager defaultManager] requestImageForAsset:self.assets[indexPath.item - 1] targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.photo = result;
                    });
                }];
                /*
                 for (PHAsset *asset in self.alreadySelectedPhotoAssets) {
                 NSLog(@"asset.localIdentifier:%@", asset.localIdentifier);
                 NSLog(@"[self.assets[indexPath.item] localIdentifier] :%@", [self.assets[indexPath.item] localIdentifier]);
                 if ([asset.localIdentifier isEqual:[self.assets[indexPath.item] localIdentifier]]) {
                 cell.chooseButton.selected = YES;
                 [self.selectedAssets addObject:self.assets[indexPath.item]];
                 [self.selectedIndexes addObject:[NSNumber numberWithInteger:indexPath.item]];
                 }
                 }
                 [self setPickerViewButtonStatus];
                 */
                cell.chooseButton.selected = NO;
                for (NSNumber *number in self.selectedIndexes) {
                    //NSLog(@"selectedIndex:%ld, indexPath.item:%ld", [number integerValue], indexPath.item);
                    if ([number integerValue] == indexPath.item - 1) {
                        cell.chooseButton.selected = YES;
                        [self setPickerViewButtonStatus];
                    }
                }
                return cell;
            }
        }
        
        
        
    }
    
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 2) {
        
    } else {
        if (_singleImageMode) {
            //点击图片从小图位置放大进入预览
            [self enterPreviewFromIndex:indexPath];
        } else {
            if (indexPath.item == 0) {
                
                [self dismissViewControllerAnimated:NO completion:^{
                    if ([_delegate respondsToSelector:@selector(shouldPresentCameraVC)]) {
                        [_delegate shouldPresentCameraVC];
                    }
                }];
                
            } else {
                //点击图片从小图位置放大进入预览
                [self enterPreviewFromIndex:indexPath];
            }
        }
        
        
        
    }
    
    
}

#pragma mark - 点击图片放大进入预览
- (void)enterPreviewFromIndex:(NSIndexPath *)indexPath
{
    NSInteger enterIndex;
    if (_singleImageMode) {
        enterIndex = indexPath.item + 1;
    } else {
        enterIndex = indexPath.item;
    }
    //隐藏控制器导航栏
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //自制imageViewer导航栏
    UIView *imageViewerNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MRTScreen_Width, 64)];
    imageViewerNavBar.backgroundColor = [UIColor whiteColor];
    //设置张数标题
    UILabel *title = [[UILabel alloc] init];
    title.font = [UIFont boldSystemFontOfSize:16];
    NSInteger currentPage = _onlySelected ? 1 : enterIndex;
    NSInteger totalPages = _onlySelected ? self.selectedAssets.count : _assets.count;
    title.text = [NSString stringWithFormat:@"%ld/%ld", currentPage, totalPages];
    title.textColor = [UIColor darkTextColor];
    [title sizeToFit];
    title.center = CGPointMake(imageViewerNavBar.width * 0.5, 44 * 0.5 + 20);
    _currentPreviewIndex = _onlySelected ? 0 : enterIndex - 1;
    [imageViewerNavBar addSubview:title];
    _imageViewerTitle = title;
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
    //自定义下一步按钮
    UIButton *previewRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewRightButton addTarget:self action:@selector(previewNextStep:) forControlEvents:UIControlEventTouchUpInside];
    [previewRightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_white_disable"] forState:UIControlStateDisabled];
    [previewRightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange"] forState:UIControlStateNormal];
    [previewRightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange_highlighted"] forState:UIControlStateHighlighted];
    previewRightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    //[previewRightButton setTitle:@"下一步" forState:UIControlStateNormal];
    [previewRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [previewRightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    /*[previewRightButton sizeToFit];
    CGRect rect = previewRightButton.frame;
    rect.size = CGSizeMake(60, 28);
    previewRightButton.frame = rect;
    previewRightButton.center = CGPointMake(imageViewerNavBar.width - previewRightButton.width * 0.5 - 20, 44 * 0.5 + 20);
    if (self.selectedAssets.count) {
        previewRightButton.enabled = YES;
    } else {
        previewRightButton.enabled = NO;
    }*/
    [imageViewerNavBar addSubview:previewRightButton];
    [self.view addSubview:imageViewerNavBar];
    _previewRightButton = previewRightButton;
    [self setPreviewButtonStatus];
    _imageViewerNavBar = imageViewerNavBar;
    
    
    //开始创建预览collectionView
    MRTImagePickerCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect beginRect = [self.collectionView convertRect:cell.frame toView:self.view];
    NSLog(@"collectionView.contentOffset.y:%f", self.collectionView.contentOffset.y);

    MRTImageViewerLayout *layout = [[MRTImageViewerLayout alloc] initWithItemSize:CGSizeMake(MRTScreen_Width, MRTScreen_Height - 64)];
    layout.beginIndex = _onlySelected ? 0 : enterIndex - 1;
    UICollectionView *imageViewer = [[UICollectionView alloc] initWithFrame:CGRectMake(-5, 64, MRTScreen_Width + 10, MRTScreen_Height - 64) collectionViewLayout:layout];
    layout.itemSize = CGSizeMake(imageViewer.width - 10, imageViewer.height);
    imageViewer.tag = 2;
    imageViewer.delegate = self;
    imageViewer.dataSource = self;
    imageViewer.prefetchingEnabled = YES; //预加载cell，提升体验
    imageViewer.pagingEnabled = YES;
    imageViewer.backgroundColor = [UIColor whiteColor];
    imageViewer.alpha = 0; //先设置透明
    [imageViewer registerClass:[MRTImageViewerCell class] forCellWithReuseIdentifier:@"viewerCell"];
    [self.view addSubview:imageViewer];
    _imageViewer = imageViewer;
    
    //添加白色背景和临时缩放imageView
    UIView *whiteBG = [[UIView alloc] initWithFrame:CGRectMake(0, 64, MRTScreen_Width, MRTScreen_Height - 64)];
    whiteBG.backgroundColor = [UIColor whiteColor];
    whiteBG.alpha = 0;
    UIImageView *temporaryView = [[UIImageView alloc] initWithFrame:beginRect];
    temporaryView.contentMode = UIViewContentModeScaleAspectFill;
    temporaryView.clipsToBounds = YES;
    _temporaryView = temporaryView;
    
    if (!_singleImageMode) {
        //添加预览界面选择按钮
        UIButton *previewSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [previewSelectButton setImage:[UIImage imageNamed:@"compose_photo_preview_default"] forState:UIControlStateNormal];
        [previewSelectButton setImage:[UIImage imageNamed:@"compose_photo_preview_right"] forState:UIControlStateSelected];
        [previewSelectButton addTarget:self action:@selector(previewChoose:) forControlEvents:UIControlEventTouchUpInside];
        //previewSelectButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        previewSelectButton.frame = CGRectMake(MRTScreen_Width - 20 - 45, 64 + 10, 45, 45);
        previewSelectButton.alpha = 0;
        //previewSelectButton.backgroundColor = [UIColor blueColor];
        [self.view addSubview:previewSelectButton];
        _previewSelectButton = previewSelectButton;
        if (_onlySelected) {
            _previewSelectButton.selected = YES;
        } else if (indexPath.item == 1 && [self.selectedIndexes containsObject:[NSNumber numberWithInt:0]]) {
            _previewSelectButton.selected = YES;
        }
    }
    
    
    //开始获取缩放图片
    PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];//请求选项设置
    options.resizeMode=PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous=NO;   //YES 一定是同步    NO不一定是异步
    
    NSInteger assetIndex;
    if (_singleImageMode) {
        assetIndex = indexPath.item;
    } else {
        assetIndex = indexPath.item - 1;
    }
    [[PHImageManager defaultManager] requestImageForAsset:self.assets[assetIndex] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            temporaryView.image = result;
            CGSize imageSize = result.size;
            CGFloat temporaryWidth;
            CGFloat temporaryHeight;
            CGFloat temporaryX;
            CGFloat temporaryY;
            
            if ((imageSize.width / imageSize. height) > (MRTScreen_Width / (MRTScreen_Height - 64))) {
                temporaryWidth = MRTScreen_Width;
                temporaryHeight = imageSize.height / (imageSize.width / MRTScreen_Width);
                temporaryX = 0;
                temporaryY = (MRTScreen_Height - 64 - temporaryHeight) * 0.5 + 64;
            } else {
                temporaryHeight = MRTScreen_Height - 64;
                temporaryWidth = imageSize.width / (imageSize.height / (MRTScreen_Height - 64));
                temporaryY = 64;
                temporaryX = (MRTScreen_Width - temporaryWidth) * 0.5;
            }
            [self.view addSubview:whiteBG];
            [self.view addSubview:temporaryView];
            
            //缩放动画
            [UIView animateWithDuration:0.2 animations:^{
                temporaryView.frame = CGRectMake(temporaryX, temporaryY, temporaryWidth, temporaryHeight);
                whiteBG.alpha = 1;
                
                _previewSelectButton.alpha = 1;
            } completion:^(BOOL finished) {
                imageViewer.alpha = 1;
                temporaryView.hidden = YES;
                [whiteBG removeFromSuperview];
                //[temporaryView removeFromSuperview];
                
            }];
        });
    }];
}

#pragma mark - 点击返回图片缩小退出预览
- (void)exitPreview
{
    //开始获取缩放图片
    MRTImageViewerCell *cell = (MRTImageViewerCell *)[_imageViewer cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPreviewIndex inSection:0]];
    
    _temporaryView.image = cell.photo;
    CGSize imageSize = cell.photo.size;
    CGFloat temporaryWidth;
    CGFloat temporaryHeight;
    CGFloat temporaryX;
    CGFloat temporaryY;
    
    if ((imageSize.width / imageSize. height) > (MRTScreen_Width / (MRTScreen_Height - 64))) {
        temporaryWidth = MRTScreen_Width;
        temporaryHeight = imageSize.height / (imageSize.width / MRTScreen_Width);
        temporaryX = 0;
        temporaryY = (MRTScreen_Height - 64 - temporaryHeight) * 0.5 + 64;
    } else {
        temporaryHeight = MRTScreen_Height - 64;
        temporaryWidth = imageSize.width / (imageSize.height / (MRTScreen_Height - 64));
        temporaryY = 64;
        temporaryX = (MRTScreen_Width - temporaryWidth) * 0.5;
    }
    NSInteger index;
    if (_singleImageMode) {
        index = _currentPreviewIndex;
    } else {
        if (_onlySelected) {
            index = [self.selectedIndexes[_currentPreviewIndex] integerValue] + 1;
        } else {
            index = _currentPreviewIndex + 1;
        }
    }
    
    
    MRTImagePickerCell *pickerCell = (MRTImagePickerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    NSLog(@"pickerCell:%@", pickerCell);
    
    NSIndexPath *realIndexPath = [self.collectionView indexPathForCell:pickerCell];
    CGRect currentMiniRect;
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    NSInteger bigestIndex = 0;
    for (int i = 0; i < visibleIndexPaths.count; i++) {
        if (((NSIndexPath *)visibleIndexPaths[i]).item > bigestIndex) {
            bigestIndex = ((NSIndexPath *)visibleIndexPaths[i]).item;
        }
    }
    
    if ([visibleIndexPaths containsObject:[NSIndexPath indexPathForItem:realIndexPath.item inSection:0]]) {
        currentMiniRect = [self.collectionView convertRect:pickerCell.frame toView:self.view];
    } else {
        if (realIndexPath.item > bigestIndex) {
            currentMiniRect = CGRectMake(MRTScreen_Width * 0.5 - pickerCell.width * 0.5, MRTScreen_Height, pickerCell.width, pickerCell.height);
        } else {
            currentMiniRect = CGRectMake(MRTScreen_Width * 0.5 - pickerCell.width * 0.5, - pickerCell.height, pickerCell.width, pickerCell.height);
        }
        
    }
    
    _temporaryView.frame = CGRectMake(temporaryX, temporaryY, temporaryWidth, temporaryHeight);
    _temporaryView.hidden = NO;
    [_imageViewer removeFromSuperview];
    [_imageViewerNavBar removeFromSuperview];
    [_previewSelectButton removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    //缩放动画
    [UIView animateWithDuration:0.2 animations:^{
        _temporaryView.frame = currentMiniRect;
    } completion:^(BOOL finished) {
        [_temporaryView removeFromSuperview];
    }];
}

#pragma mark - 预览界面滚动时
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2) {
        NSLog(@"scrollView.contentOffset.x:%f", scrollView.contentOffset.x);
        NSInteger page = roundf(scrollView.contentOffset.x / (MRTScreen_Width + 10) + 1);
        NSLog(@"page:%ld", page);
        if (page != _currentPreviewIndex + 1) {
            _currentPreviewIndex = page - 1;
            NSInteger totalPages = _onlySelected ? self.selectedAssets.count : _assets.count;
            _imageViewerTitle.text = [NSString stringWithFormat:@"%ld/%ld", page, totalPages];
            [_imageViewerTitle sizeToFit];
        }
        if (_onlySelected) {
            if ([self.previewSelectedIndexes containsObject:[NSNumber numberWithInteger:_currentPreviewIndex]]) {
                _previewSelectButton.selected = YES;
            } else {
                _previewSelectButton.selected = NO;
            }
        } else {
            if ([self.selectedIndexes containsObject:[NSNumber numberWithInteger:_currentPreviewIndex]]) {
                _previewSelectButton.selected = YES;
            } else {
                _previewSelectButton.selected = NO;
            }
        }
        
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
