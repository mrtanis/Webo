//
//  MRTComment.h
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"
#import "MRTUser.h"
#import "MRTStatus.h"

@interface MRTComment : NSObject <NSCoding>

@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *idstr;
@property (nonatomic, copy) NSString *text;
//建立一个属性字符串
@property (nonatomic, copy) NSMutableAttributedString *attrText;
@property (nonatomic, copy) NSString *source;

@property (nonatomic, strong) MRTUser *user;
@property (nonatomic, strong) MRTStatus *status;
@property (nonatomic, strong) MRTComment *reply_comment;

@end
