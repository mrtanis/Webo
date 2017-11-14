//
//  MRTFriendsListCell.h
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTFriendsListController.h"
@class MRTOtherUser;
@class MRTRelation;


@interface MRTFriendsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *relationButton;
@property (weak, nonatomic) IBOutlet UIImageView *vipView;

@property (nonatomic, strong) MRTOtherUser *otherUser;
@property (nonatomic) MRTListControllerType type;
@property (nonatomic, strong) MRTRelation *relation;

- (void)setUpCellWithType:(MRTListControllerType)type User:(MRTOtherUser *)otherUser relation:(MRTRelation *)relation;
@end
