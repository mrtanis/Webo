//
//  MRTPictureView.h
//  Webo
//
//  Created by mrtanis on 2017/6/5.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTPictureView : UIView

@property (nonatomic, copy) NSArray *pic_urls;
@property (nonatomic) CGSize onePicSize;
@property (nonatomic, strong) UIImage *firstImage;


@end
