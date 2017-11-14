//
//  MRTImagePickerController.h
//  Webo
//
//  Created by mrtanis on 2017/9/22.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^photosBlock)(NSMutableArray *, BOOL);

@protocol MRTImagePickerDelegate <NSObject>
@optional
- (void)shouldPresentCameraVC;
@end

@interface MRTImagePickerController : UICollectionViewController
@property (nonatomic, weak) id <MRTImagePickerDelegate> delegate;
@property (nonatomic, strong) photosBlock photosBlock;
@property (nonatomic, copy) NSMutableArray *selectedAssets;
@property (nonatomic) BOOL originalMode;
//只能选择一张图的模式，此模式下不显示chooseButton(扫描照片二维码)
@property (nonatomic) BOOL singleImageMode;
//直接从发照片按钮进入
@property (nonatomic) BOOL directEnter;
@end
