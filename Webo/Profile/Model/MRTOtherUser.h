//
//  MRTOtherUser.h
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTStatus.h"


//为了避免MRTUser.h 和 MRTStatus.h 的相互引用造成错误，建立这个MRTOtherUser
@interface MRTOtherUser : NSObject
@property (nonatomic, copy) NSString *idstr;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *profile_image_url;
@property (nonatomic, strong) NSURL *avatar_large;
@property (nonatomic, strong) NSURL *avatar_hd;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, strong) MRTStatus *status;

@property (nonatomic) int followers_count;
@property (nonatomic) int friends_count;
@property (nonatomic) int statuses_count;
//判断其他用户是否关注我,此项不用保存，每次获取
@property (nonatomic) BOOL follow_me;

// 用户类型, 大于2代表是会员
@property (nonatomic) int mbtype;

//会员等级
@property (nonatomic) int mbrank;

@property (nonatomic) BOOL vip;
@end
