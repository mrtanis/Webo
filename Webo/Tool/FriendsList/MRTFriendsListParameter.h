//
//  MRTFriendsListParameter.h
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccessToken.h"

@interface MRTFriendsListParameter : MRTAccessToken
@property (nonatomic, copy) NSString *uid;
@property (nonatomic) int cursor;
@property (nonatomic) int trim_status;
@end
