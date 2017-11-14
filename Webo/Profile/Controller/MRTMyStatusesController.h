//
//  MRTMyStatusesController.h
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRTUser;
@class MRTOtherUser;
@interface MRTMyStatusesController : UITableViewController
@property (nonatomic, strong) MRTUser *user;

@property (nonatomic, strong) MRTOtherUser *otherUser;

@property (nonatomic, copy) NSString *leftTitle;
@end
