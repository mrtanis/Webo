//
//  MRTStream.h
//  Webo
//
//  Created by mrtanis on 2017/9/5.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface MRTStream : NSObject <NSCoding, MJKeyValue>

@property (nonatomic, copy) NSString *hd_url;

@end
