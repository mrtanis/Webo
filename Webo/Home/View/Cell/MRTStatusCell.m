//
//  MRTStatusCell.m
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusCell.h"
#import "MRTOriginalView.h"
#import "MRTRetweetView.h"
#import "MRTStatusToolBar.h"
#import "MRTPictureView.h"



@interface MRTStatusCell ()

@property (nonatomic, weak) MRTOriginalView *originalView;
@property (nonatomic, weak) MRTRetweetView *retweetView;
@property (nonatomic, weak) MRTStatusToolBar *statusToolBar;
@property (nonatomic, weak) MRTPictureView *pictureView;
@end

@implementation MRTStatusCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //添加子控件
        [self setUpAllChildView];
        //清空cell背景颜色
        self.backgroundColor = [UIColor darkGrayColor];
    }
    
    return self;
}

//添加子控件
- (void)setUpAllChildView
{
    //原创微博
    MRTOriginalView *originalView = [[MRTOriginalView alloc] init];
    [self addSubview:originalView];
    _originalView = originalView;
    
    //转发微博
    MRTRetweetView *retweetView = [[MRTRetweetView alloc] init];
    [self addSubview:retweetView];
    _retweetView = retweetView;
    
    //配图
    MRTPictureView *picView = [[MRTPictureView alloc] init];
    [self addSubview:picView];
    _pictureView = picView;
    
    //工具条
    MRTStatusToolBar *toolBar = [[MRTStatusToolBar alloc] init];
    [self addSubview:toolBar];
    _statusToolBar = toolBar;
    
}

- (void)setStatusFrame:(MRTStatusFrame *)statusFrame
{
    
    _statusFrame = statusFrame;
    
    //设置原创微博frame
    _originalView.frame = statusFrame.originalViewFrame;
    _originalView.statusFrame = statusFrame;
    
    //设置转发微博frame
    _retweetView.frame = statusFrame.retweetViewFrame;
    _retweetView.statusFrame = statusFrame;
    
    
    //设置工具条frame
    _statusToolBar.frame = statusFrame.toolBarFrame;
    _statusToolBar.statusFrame = statusFrame;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    id cell = [tableView dequeueReusableCellWithIdentifier:ID ];
    
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    return cell;
}

@end
