//
//  MRTUser.h
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTUser : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *profile_image_url;
@end
