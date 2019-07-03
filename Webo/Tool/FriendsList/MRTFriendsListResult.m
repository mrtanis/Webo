//
//  MRTFriendsListResult.m
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTFriendsListResult.h"
#import "MRTOtherUser.h"

@implementation MRTFriendsListResult
+ (NSDictionary *)objectClassInArray
{
    return @{@"users":[MRTOtherUser class]};
}
@end
