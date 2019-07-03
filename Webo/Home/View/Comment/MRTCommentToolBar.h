//
//  MRTCommentToolBar.h
//  Webo
//
//  Created by mrtanis on 2017/6/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRTCommentToolBar;
@protocol MRTCommentToolBarDelegate <NSObject>

@optional
- (void)commentToolBar:(MRTCommentToolBar *)toolBar didClickButton:(NSInteger)index;

@end

@interface MRTCommentToolBar : UIImageView
@property (nonatomic, weak) id <MRTCommentToolBarDelegate> delegate;
@end
