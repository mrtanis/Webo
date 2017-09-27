//
//  MRTImageViewerLayout.h
//  Webo
//
//  Created by mrtanis on 2017/9/27.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTImageViewerLayout : UICollectionViewFlowLayout

@property (nonatomic) NSInteger beginIndex;


- (instancetype)initWithItemSize:(CGSize)size;
@end
