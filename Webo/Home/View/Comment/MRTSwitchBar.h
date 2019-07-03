//
//  MRTSwitchBar.h
//  Webo
//
//  Created by mrtanis on 2017/6/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRTSwitchBar;

@protocol MRTSwitchBarDelegate <NSObject>

@optional
- (void)switchBar:(MRTSwitchBar *)switchBar didClickButton:(NSInteger)index;

@end

@interface MRTSwitchBar : UIImageView
@property (nonatomic, weak) UIButton *retweetBtn;
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *likeBtn;
@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, weak) id <MRTSwitchBarDelegate> delegate;

- (void)setTitleWithReposts:(int)repostsCount comments:(int)commentsCount attitudes:(int)attitudesCount;
@end
