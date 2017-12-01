//
//  MRTImagePickerCell.m
//  Webo
//
//  Created by mrtanis on 2017/9/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTImagePickerCell.h"

@interface MRTImagePickerCell ()

@property (nonatomic, weak) UIImageView *photoView;



@end

@implementation MRTImagePickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpPhotoView];
        
        [self setUpChooseButton];
        
        
    }
    
    return self;
}

- (void)setUpPhotoView
{
    UIImageView *photoView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:photoView];
    _photoView = photoView;
}

- (void)setPhoto:(UIImage *)photo
{
    _photo = photo;
    
    _photoView.image = photo;
}

- (void)setUpChooseButton
{
    UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseButton setImage:[UIImage imageNamed:@"compose_photo_preview_default"] forState:UIControlStateNormal];
    [chooseButton setImage:[UIImage imageNamed:@"compose_photo_preview_right"] forState:UIControlStateSelected];
    [chooseButton addTarget:self action:@selector(clickChoose:) forControlEvents:UIControlEventTouchUpInside];
    //chooseButton.backgroundColor = [UIColor whiteColor];
    chooseButton.imageEdgeInsets = UIEdgeInsetsMake(4, 10, 10, 4);
    chooseButton.frame = CGRectMake(self.width - 10 - 25 - 4, 0, 39, 39);
    [self.contentView addSubview:chooseButton];
    _chooseButton = chooseButton;
    
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    _chooseButton.tag = index;
}

- (void)clickChoose:(UIButton *)button
{
    
    if ([_delegate respondsToSelector:@selector(clickChooseButtton:AtIndex:)]) {
        [_delegate clickChooseButtton:button AtIndex:_index];
    }
}

- (void)setSingleImageMode:(BOOL)singleImageMode
{
    _singleImageMode = singleImageMode;
    _chooseButton.hidden = singleImageMode;
}

@end
