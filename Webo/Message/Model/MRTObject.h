//
//  MRTObject.h
//  Webo
//
//  Created by mrtanis on 2017/7/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTImage.h"
#import "MRTStream.h"

@interface MRTObject : NSObject <NSCoding, MJKeyValue>
@property (nonatomic) int duration;
@property (nonatomic, strong) MRTImage *image;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) MRTStream *stream;
@property (nonatomic, strong) MRTObject *object;
@end
