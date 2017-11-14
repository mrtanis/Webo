//
//  MRTProfileCell.m
//  Webo
//
//  Created by mrtanis on 2017/10/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTProfileCell.h"

@implementation MRTProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //设置button属性
    [self setButtonAttributes];
}

- (void)setButtonAttributes
{
    _statusesButton.layer.cornerRadius = 20;
    _statusesButton.titleLabel.numberOfLines = 2;
    _statusesButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _statusesButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];
    
    _friendsButton.layer.cornerRadius = 20;
    _friendsButton.titleLabel.numberOfLines = 2;
    _friendsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _friendsButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];
    
    _followersButton.layer.cornerRadius = 20;
    _followersButton.titleLabel.numberOfLines = 2;
    _followersButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _followersButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];
    
    _accountSwitchButton.layer.cornerRadius = 20;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
