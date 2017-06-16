//
//  MRTTextToolBar.h
//  Webo
//
//  Created by mrtanis on 2017/6/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRTTextToolBar;

@protocol MRTTextToolBarDelegate <NSObject>

@optional

- (void)textToolBar:(MRTTextToolBar *)toolBar didClickButton:(NSInteger)index;


@end

@interface MRTTextToolBar : UIView

@property (nonatomic, weak) id <MRTTextToolBarDelegate> delegate;

@end
