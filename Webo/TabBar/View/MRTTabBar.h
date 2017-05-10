//
//  MRTTabBar.h
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

//我们需要用协议来申明哪些方法是被委托出去了
@class MRTTabBar;
@protocol MRTTabBarDelegate <NSObject>

@optional//可选方法，与之对应的是@required（必须实现）
- (void)tabBar:(MRTTabBar *)tabBar didClickButton:(NSInteger)index;

@end

@interface MRTTabBar : UIView
@property (nonatomic, strong) NSArray *items;
//委托者申明一个属性,委托者里得有一个属性代表被委托者, 注意这个属性是弱引用
@property (nonatomic, weak) id <MRTTabBarDelegate> delegate;
@end
