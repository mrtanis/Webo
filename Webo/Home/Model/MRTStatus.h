//
//  MRTStatus.h
//  Webo
//
//  Created by mrtanis on 2017/5/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"
#import "MRTUser.h"
#import "MRTPicture.h"
#import "MRTRetweeted_status.h"

@interface MRTStatus : NSObject <MJKeyValue, NSCoding>

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *idstr;
@property (nonatomic, copy) NSString *text;
//建立一个属性字符串
@property (nonatomic, copy) NSMutableAttributedString *attrText;

@property (nonatomic, copy) NSString *source;
@property (nonatomic, strong) MRTUser *user;
@property (nonatomic, strong) MRTStatus *retweeted_status;
@property (nonatomic, assign) int reposts_count;
@property (nonatomic, assign) int comments_count;
@property (nonatomic, assign) int attitudes_count;
@property (nonatomic, strong) NSArray *pic_urls;


@end
