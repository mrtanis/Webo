//
//  MRTEmotionCell.m
//  Webo
//
//  Created by mrtanis on 2017/9/15.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTEmotionCell.h"

@interface MRTEmotionCell ()

@property (nonatomic, weak) UIImageView *emotionView;

@end

@implementation MRTEmotionCell

//若使用init不会执行
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIImageView *emotionView = [UIImageView new];
        [self addSubview:emotionView];
        NSLog(@"emotionCell初始化");
        _emotionView = emotionView;
    }
    
    return self;
}

- (void)setEmoDic:(NSDictionary *)emoDic
{
    NSLog(@"设置emoDic");
    _emoDic = emoDic;
    
    _emotionView.image = [UIImage imageNamed:emoDic[@"png"]];
    _emotionView.frame = self.bounds;
    
}

@end
