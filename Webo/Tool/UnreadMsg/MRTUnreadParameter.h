//
//  MRTUnreadParameter.h
//  Webo
//
//  Created by mrtanis on 2017/5/21.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccessToken.h"

@interface MRTUnreadParameter : MRTAccessToken

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *screen_name;

@end
