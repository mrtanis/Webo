//
//  MRTSendRepostOverview.h
//  Webo
//
//  Created by mrtanis on 2017/6/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTPictureWithTag.h"


@interface MRTSendRepostOverview : UIView
- (void)setImageWithUrl:(NSURL *)url;

@property (nonatomic, strong) MRTPictureWithTag *pictureView;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@end
