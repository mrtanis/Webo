//
//  MRTDeleteCell.h
//  Webo
//
//  Created by mrtanis on 2017/9/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRTDeleteCellDelegate <NSObject>

@optional
- (void)longPressDelete;

- (void)endDelete;

@end

@interface MRTDeleteCell : UICollectionViewCell

@property (nonatomic, weak) id <MRTDeleteCellDelegate> delegate;

@end
