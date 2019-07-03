//
//  MRTCommentCell.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentCell.h"
#import "MRTMainView.h"

@interface MRTCommentCell()
@property (nonatomic, weak) MRTMainView *commentView;

@end

@implementation MRTCommentCell

#pragma mark 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //添加子控件
        [self setUpAllChildView];
        //清空cell背景颜色
        //self.backgroundColor = [UIColor clearColor];
        //设置分割线长度
        self.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    }
    
    return self;
}

#pragma mark 添加子控件
- (void)setUpAllChildView
{
    //原始评论
    MRTMainView *commentView = [[MRTMainView alloc] init];
    [self addSubview:commentView];
    _commentView = commentView;
}

#pragma mark 设置布局
- (void)setCommentFrame:(MRTCommentFrame *)commentFrame
{
    _commentFrame = commentFrame;
    
    //设置原始评论
    _commentView.frame = commentFrame.commentViewFrame;
    _commentView.commentFrame = commentFrame;
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
