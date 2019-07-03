//
//  MRTImagePickerCell.h
//  Webo
//
//  Created by mrtanis on 2017/9/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRTImagePickerCellDelegate <NSObject>

@optional

- (void)clickChooseButtton:(UIButton *)button AtIndex:(NSInteger)index;

@end

@interface MRTImagePickerCell : UICollectionViewCell
@property (nonatomic, weak) id <MRTImagePickerCellDelegate> delegate;
@property (nonatomic, weak) UIButton *chooseButton;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic) NSInteger index;

//只能选择一张图的模式，此模式下不显示chooseButton
@property (nonatomic) BOOL singleImageMode;


@end
