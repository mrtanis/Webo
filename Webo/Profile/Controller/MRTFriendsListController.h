//
//  MRTFriendsListController.h
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MRTListControllerType) {
    MRTListControllerTypeFriends,
    MRTListControllerTypeFollewers,
};

@interface MRTFriendsListController : UITableViewController
@property (nonatomic, copy) NSString *leftTitle;
@property (nonatomic) MRTListControllerType type;
@end
