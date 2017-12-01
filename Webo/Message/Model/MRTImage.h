//
//  MRTImage.h
//  Webo
//
//  Created by mrtanis on 2017/7/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface MRTImage : NSObject <NSCoding, MJKeyValue>
@property (nonatomic) int height;
@property (nonatomic) int width;
@property (nonatomic, copy) NSString *url;
@end
