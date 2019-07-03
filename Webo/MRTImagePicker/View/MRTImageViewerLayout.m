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

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
    return NO;
}
/*
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 拿到系统已经帮我们计算好的布局属性数组，然后对其进行拷贝一份，后续用这个新拷贝的数组去操作
    NSArray * originalArray   = [super layoutAttributesForElementsInRect:rect];
    NSArray * curArray = [[NSArray alloc] initWithArray:originalArray copyItems:YES];
    
    // 计算collectionView中心点的y值(这个中心点可不是屏幕的中线点哦，是整个collectionView的，所以是包含在屏幕之外的偏移量的哦)
    //CGFloat centerY = self.collectionView.contentOffset.y + self.collectionView.frame.size.height * 0.5;
    
    // 拿到每一个cell的布局属性，在原有布局属性的基础上，进行调整
    for (UICollectionViewLayoutAttributes *attrs in curArray) {
        // cell的中心点y 和 collectionView最中心点的y值 的间距的绝对值
        //CGFloat space = ABS(attrs.center.y - centerY);
        
        // 根据间距值 计算 cell的缩放比例
        // 间距越大，cell离屏幕中心点越远，那么缩放的scale值就小
        //CGFloat scale = 1 - space / self.collectionView.frame.size.height;
        
        // 设置缩放比例
        //attrs.transform = CGAffineTransformMakeScale(scale, scale);
        attrs.frame = self.collectionView.bounds;
    }
    
    return curArray;
}
*/
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    NSLog(@"调用initialLayoutAttributes");
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
    attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
    
    return attr;
}

@end
