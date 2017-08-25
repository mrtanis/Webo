//
//  MRTStatusCell.m
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusCell.h"
#import "MRTOriginalView.h"



@interface MRTStatusCell () <MRTOriginalViewDelegate,MRTRetweetViewDelegate>


@end

@implementation MRTStatusCell

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
    //原创微博
    MRTOriginalView *originalView = [[MRTOriginalView alloc] init];
    originalView.delegate = self;
    [self addSubview:originalView];
    _originalView = originalView;
    
    //转发微博
    MRTRetweetView *retweetView = [[MRTRetweetView alloc] init];
    retweetView.delegate = self;
    [self addSubview:retweetView];
    _retweetView = retweetView;
    
    //配图
    MRTPictureView *picView = [[MRTPictureView alloc] init];
    [self addSubview:picView];
    _pictureView = picView;
    
    //工具条
    MRTStatusToolBar *toolBar = [[MRTStatusToolBar alloc] init];
    
    _retweetBtn = toolBar.retweetBtn;
    [_retweetBtn addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    _commentBtn = toolBar.commentBtn;
    [_commentBtn addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    _likeBtn = toolBar.likeBtn;
    [_likeBtn addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:toolBar];
    
    _statusToolBar = toolBar;
    
}

#pragma mark 设置布局
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

#pragma mark 点击工具栏按钮执行代理方法
- (void)didClickButton:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(statusCell:didClickButton:)]) {
        [_delegate statusCell:self.statusFrame didClickButton:button.tag];
    }
}

#pragma mark 点击原创微博文字执行代理方法
- (void)originalTextViewDidTapCell
{
    if ([_delegate respondsToSelector:@selector(textViewDidClickCell:)] && _ignoreOriginalViewTap == NO) {
        [_delegate textViewDidClickCell:self.statusFrame];
    }
}

#pragma mark 点击转发微博微博文字执行代理方法
- (void)retweetTextViewDidTapCell
{
    if ([_delegate respondsToSelector:@selector(textViewDidClickCell:)]) {
        //新建被转发微博的frame（作为原创微博的显示形式）
        MRTStatusFrame *retweetFrame = [[MRTStatusFrame alloc] init];
        retweetFrame.status = self.statusFrame.status.retweeted_status;
        
        [_delegate textViewDidClickCell:retweetFrame];
    }
}

#pragma mark 点击视频链接代理方法
- (void)playVideoWithUrl:(NSURL *)url allowRotate:(BOOL)allowRotate
{
    if ([_delegate respondsToSelector:@selector(playVideoWithUrl:allowRotate:)]) {
        [_delegate playVideoWithUrl:url allowRotate:allowRotate];
    }
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
