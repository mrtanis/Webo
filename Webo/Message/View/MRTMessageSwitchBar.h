//
//  MRTMessageSwitchBar.h
//  Webo
//
//  Created by mrtanis on 2017/7/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRTMessageSwitchBar;

@protocol MRTMessageSwitchBarDelegate <NSObject>
@optional
- (void)switchBar:(MRTMessageSwitchBar *)switchBar didClickButton:(NSInteger)index;
@end

@interface MRTMessageSwitchBar : UIView
@property (nonatomic, weak) UIView *indicatorBar;
@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, weak) id <MRTMessageSwitchBarDelegate> delegate;
@end
