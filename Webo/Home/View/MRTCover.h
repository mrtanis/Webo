//
//  MRTCover.h
//  Webo
//
//  Created by mrtanis on 2017/5/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRTCover;
@protocol MRTCoverDelegate <NSObject>

//自定义控件时使用代理，利于以后扩展新功能
@optional

- (void)coverDidClick:(MRTCover *)cover;

@end

@interface MRTCover : UIView

@property (nonatomic, weak) id <MRTCoverDelegate> delegate;

//显示蒙板
+(instancetype)show;

@end
