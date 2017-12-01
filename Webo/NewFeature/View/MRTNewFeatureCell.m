//
//  MRTNewFeatureCell.m
//  Webo
//
//  Created by mrtanis on 2017/5/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTNewFeatureCell.h"
#import "MRTTabBarController.h"

@interface MRTNewFeatureCell()
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIButton *shareButton;
@property (nonatomic, weak) UIButton *finishButton;

@end

@implementation MRTNewFeatureCell

- (UIButton *)shareButton
{
    if (!_shareButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"分享" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"new_feature_share_false"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"new_feature_share_true"] forState:UIControlStateSelected];
        
        [button sizeToFit];
        
        [self.contentView addSubview:button];
        
        _shareButton = button;
    }
    
    return _shareButton;
}

- (UIButton *)finishButton
{
    if (!_finishButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setTitle:@"开始微博" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"new_feature_finish_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"new_featrue_finish_button_highlighted"] forState:UIControlStateHighlighted];
        
        [button sizeToFit];
        //添加点击事件
        [button addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
        
        _finishButton = button;
    }
    
    return _finishButton;
}

- (void)finish
{
    //进入tabBarController
    MRTTabBarController *tabBarVc = [[MRTTabBarController alloc] init];
    //切换根控制器为tabBarController
    MRTKeyWindow.rootViewController = tabBarVc;
}

//判断当前cell是否是最后一页，是则显示两个按钮，否则隐藏
- (void)checkIndexPath:(NSIndexPath *)indexPath pageCount:(int)count
{
    if (indexPath.row == count - 1) {
        self.shareButton.hidden = NO;
        self.finishButton.hidden = NO;
    } else {
        self.shareButton.hidden = YES;
        self.finishButton.hidden = YES;
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImageView *imageV = [[UIImageView alloc] init];
        _imageView = imageV;
        
        //在contentView上添加imageV
        [self.contentView addSubview:imageV];
    }
    
    return _imageView;
}

//布局子控件的frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    
    //设置两个按钮的位置
    self.shareButton.center = CGPointMake(self.width * 0.5, self.height * 0.8);
    self.finishButton.center = CGPointMake(self.width * 0.5, self.height * 0.9);
    
}

//设置图片
- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = image;
}



@end
