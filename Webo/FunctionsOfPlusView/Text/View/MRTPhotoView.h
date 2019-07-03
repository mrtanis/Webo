//
//  MRTPhotoView.h
//  Webo
//
//  Created by mrtanis on 2017/10/10.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRTPhotoView;
@protocol MRTPhotoViewDelegate <NSObject>
@optional
- (void)deselectPhoto:(MRTPhotoView *)photoView;
@end

@interface MRTPhotoView : UIView
@property (nonatomic, weak) id <MRTPhotoViewDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

@end
