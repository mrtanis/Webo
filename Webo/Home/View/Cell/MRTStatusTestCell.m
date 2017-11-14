//
//  MRTStatusTestCell.m
//  Webo
//
//  Created by mrtanis on 2017/10/28.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusTestCell.h"

@implementation MRTStatusTestCell

#pragma mark 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //添加子控件
        [self setUpAllChildView];
        //清空cell背景颜色
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

#pragma mark 添加子控件
- (void)setUpAllChildView
{
    
}





- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
