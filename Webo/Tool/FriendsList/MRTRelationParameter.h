//
//  MRTRelationParameter.h
//  Webo
//
//  Created by mrtanis on 2017/10/18.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTAccessToken.h"

@interface MRTRelationParameter : MRTAccessToken

@property (nonatomic, copy) NSString *source_id;
@property (nonatomic, copy) NSString *target_id;

@end
