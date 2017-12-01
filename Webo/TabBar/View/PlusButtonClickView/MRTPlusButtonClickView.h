//
//  MRTPlusButtonClickView.h
//  Webo
//
//  Created by mrtanis on 2017/6/8.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRTPlusButtonClickViewDelegate <NSObject>

@optional
- (void)plusViewDidClickButton:(NSInteger)index;

@end

@interface MRTPlusButtonClickView : UIView

@property (nonatomic, weak) id <MRTPlusButtonClickViewDelegate> delegate;

@end
