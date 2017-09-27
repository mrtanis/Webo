//
//  MRTImageViewerLayout.m
//  Webo
//
//  Created by mrtanis on 2017/9/27.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTImageViewerLayout.h"

@implementation MRTImageViewerLayout

- (instancetype)initWithItemSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemSize = size;
        self.minimumInteritemSpacing = 10;
        self.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    }
    return self;
}

- (void)prepareLayout{
    [super prepareLayout];
    self.collectionView.contentOffset = CGPointMake((MRTScreen_Width + 10) * _beginIndex, 0);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds{
    
    return NO;
}

@end
