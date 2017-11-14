//
//  MRTRelationResult.h
//  Webo
//
//  Created by mrtanis on 2017/10/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTRelation.h"

@interface MRTRelationResult : NSObject
@property (nonatomic, strong) MRTRelation *target;
@property (nonatomic, strong) MRTRelation *source;

@end
