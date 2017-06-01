//
//  MRTStatusCell.h
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTStatusFrame.h"

@interface MRTStatusCell : UITableViewCell

@property (nonatomic, strong) MRTStatusFrame *statusFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
