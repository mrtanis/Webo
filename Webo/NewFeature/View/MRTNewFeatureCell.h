//
//  MRTNewFeatureCell.h
//  Webo
//
//  Created by mrtanis on 2017/5/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTNewFeatureCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *image;

- (void)checkIndexPath:(NSIndexPath *)indexPath pageCount:(int)count;
@end
