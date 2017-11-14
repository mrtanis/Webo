//
//  MRTTextAddPhotos.h
//  Webo
//
//  Created by mrtanis on 2017/6/15.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRTTextAddPhotosDelegate <NSObject>
@optional
- (void)deselectPhotoAtIndex:(NSInteger)index;
@end

@interface MRTTextAddPhotos : UIView
@property (nonatomic, weak) id <MRTTextAddPhotosDelegate> delegate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSMutableArray *images;

@end
