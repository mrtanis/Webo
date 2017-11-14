//
//  MRTFriendsListResult.h
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTFriendsListResult : NSObject
@property (nonatomic, strong) NSArray *users;
@property (nonatomic) int next_cursor;
@property (nonatomic) int previous_cursor;
@property (nonatomic) int totalNumber;
@end
