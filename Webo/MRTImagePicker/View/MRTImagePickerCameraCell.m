//
//  MRTImagePickerCameraCell.m
//  Webo
//
//  Created by mrtanis on 2017/11/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTImagePickerCameraCell.h"

@implementation MRTImagePickerCameraCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpCameraIcon];
    }
    
    return self;
}

- (void)setUpCameraIcon
{
    UIImageView *cameraIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compose_photo_photograph"]];
    cameraIcon.contentMode = UIViewContentModeCenter;
    cameraIcon.frame = self.bounds;
    [self.contentView addSubview:cameraIcon];
}
@end
