//
//  MRTFriendsListTool.h
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTRelation.h"

@interface MRTFriendsListTool : NSObject

+ (void)newFriendsListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure;

+ (void)moreFriendsListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure;

+ (void)newFollowersListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure;

+ (void)moreFollowersListWithUID:(NSString *)uid cursor:(int)cursor trim_status:(int)trim_status success:(void(^)(NSArray *users, int next_cursor))success failure:(void(^)(NSError *error))failure;

+ (void)getRelationWithSource_id:(NSString *)source_id target_id:(NSString *)target_id success:(void(^)(MRTRelation *relation))success failure:(void(^)(NSError *error))failure;

@end
