//
//  MRTFriendsList_m
//  Webo
//
//  Created by mrtanis on 2017/10/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTFriendsListCell.h"
#import "MRTOtherUser.h"
#import "UIImageView+WebCache.h"
#import "MRTRelation.h"



@implementation MRTFriendsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _iconView.layer.cornerRadius = 35;
    _iconView.clipsToBounds = YES;
    self.separatorInset = UIEdgeInsetsZero;
}


- (void)setUpCellWithType:(MRTListControllerType)type User:(MRTOtherUser *)otherUser relation:(MRTRelation *)relation
{
    _type = type;
    _otherUser = otherUser;
    _relation = relation;
    
    [_iconView sd_setImageWithURL:otherUser.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    _nameLabel.text = otherUser.name;
    if (otherUser.vip) {
        _nameLabel.textColor = [UIColor orangeColor];
        NSString *vipImageName = [NSString stringWithFormat:@"common_icon_membership_level%d", otherUser.mbrank];
        _vipView.image = [UIImage imageNamed:vipImageName];
    }
    _statusTextLabel.text = otherUser.status.text;
    NSLog(@"cell.type:%ld, cell.relation.following:%d, cell.relation.followed_by:%d", _type, _relation.following, _relation.followed_by);
    if (_type == MRTListControllerTypeFriends) {
        if (otherUser.follow_me) {
            [_relationButton setImage:[UIImage imageNamed:@"card_icon_arrow"] forState:UIControlStateNormal];
            [_relationButton setTitle:@"互相关注" forState:UIControlStateNormal];
        } else {
            [_relationButton setImage:[UIImage imageNamed:@"card_icon_attention"] forState:UIControlStateNormal];
            [_relationButton setTitle:@"已关注" forState:UIControlStateNormal];
        }
    } else {
        if (_relation.following) {
            NSLog(@"_relation.following:%d", _relation.following);
            [_relationButton setImage:[UIImage imageNamed:@"card_icon_arrow"] forState:UIControlStateNormal];
            [_relationButton setTitle:@"互相关注" forState:UIControlStateNormal];
            _relationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 10, -4);
        } else {
            [_relationButton setImage:[UIImage imageNamed:@"card_icon_addattention"] forState:UIControlStateNormal];
            [_relationButton setTitle:@"加关注" forState:UIControlStateNormal];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
