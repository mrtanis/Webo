//
//  MRTRepostCell.m
//  Webo
//
//  Created by mrtanis on 2017/8/13.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRepostCell.h"
#import "MRTRepostMainView.h"

@interface MRTRepostCell()
@property (nonatomic, weak) MRTRepostMainView *repostView;

@end
@implementation MRTRepostCell

#pragma mark 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //添加子控件
        [self setUpAllChildView];
        //清空cell背景颜色
        self.backgroundColor = [UIColor clearColor];
        //设置分割线长度
        self.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    }
    
    return self;
}

#pragma mark 添加子控件
- (void)setUpAllChildView
{
    //原始评论
    MRTRepostMainView *repostView = [[MRTRepostMainView alloc] init];
    [self addSubview:repostView];
    _repostView = repostView;
}

#pragma mark 设置布局
- (void)setRepostFrame:(MRTRepostFrame *)repostFrame
{
    _repostFrame = repostFrame;
    
    //设置原始评论
    _repostView.frame = repostFrame.repostViewFrame;
    _repostView.repostFrame = repostFrame;
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
