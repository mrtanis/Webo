//
//  MRTImageViewerController.h
//  Webo
//
//  Created by mrtanis on 2017/9/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface MRTImageViewerController : UICollectionViewController

@property (nonatomic, strong) PHFetchResult *assets;
@property (nonatomic, copy) NSMutableArray *assetsArray;
@property (nonatomic) NSInteger index;

@end
