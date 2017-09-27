//
//  MRTURL_object.h
//  Webo
//
//  Created by mrtanis on 2017/7/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTObject.h"

@interface MRTURL_object : NSObject <NSCoding, MJKeyValue>
@property (nonatomic, strong) MRTObject *object;
@property (nonatomic) int play_count;
@property (nonatomic, copy) NSString *url_ori;
@end
