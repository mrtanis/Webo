//
//  MRTRelation.h
//  Webo
//
//  Created by mrtanis on 2017/10/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTRelation : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *screen_name;
@property (nonatomic) BOOL followed_by;
@property (nonatomic) BOOL following;
@property (nonatomic) BOOL notifications_enabled;

@end
