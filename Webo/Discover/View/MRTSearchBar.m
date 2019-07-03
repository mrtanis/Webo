//
//  MRTSearchBar.m
//  Webo
//
//  Created by mrtanis on 2017/5/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTSearchBar.h"

@implementation MRTSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.font = [UIFont systemFontOfSize:13];
        
        //拉伸设置输入框背景
        self.background = [UIImage imageWithStretchableName:@"searchbar_textfield_background"];
        
        //设置左边的view,图片尺寸决定了imageView的初始尺寸
        UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar_textfield_search_icon"]];
        
        //图片左右留一定间隙
        imageV.width += 10;
        imageV.contentMode = UIViewContentModeCenter;
        
        self.leftView = imageV;
        //要显示搜索框左边的视图，一定要设置左边视图的模式,因为默认模式是不显示
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
    return self;
}

        

@end
