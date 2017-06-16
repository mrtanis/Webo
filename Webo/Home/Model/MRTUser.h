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
@property (nonatomic, strong) NSURL *avatar_large;

// 用户类型, 大于2代表是会员
@property (nonatomic) int mbtype;

//会员等级
@property (nonatomic) int mbrank;

@property (nonatomic) BOOL vip;

@end
