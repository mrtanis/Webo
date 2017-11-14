//
//  MRTMessageStatusCell.m
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageStatusCell.h"
#import "MRTStatusCell.h"


@interface MRTMessageStatusCell () <MRTMessageOriginalStatusViewDelegate,MRTMessageRetweetStatusViewDelegate>
@end
@implementation MRTMessageStatusCell

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
    MRTMessageOriginalStatusView *originalView = [[MRTMessageOriginalStatusView alloc] init];
    originalView.delegate = self;
    [self addSubview:originalView];
    _originalView = originalView;
    
    //转发微博
    MRTMessageRetweetStatusView *retweetView = [[MRTMessageRetweetStatusView alloc] init];
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
- (void)setStatusFrame:(MRTMessageStatusFrame *)statusFrame
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
    _statusToolBar.messageStatusFrame = statusFrame;
}

#pragma mark 点击工具栏按钮执行代理方法
- (void)didClickButton:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(statusCell:didClickButton:)]) {
        
        MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
        
        statusFrame.status = self.statusFrame.status;
        
        [_delegate statusCell:statusFrame didClickButton:button.tag];
    }
}

#pragma mark 点击原创微博文字执行代理方法
- (void)originalTextViewDidTapCell
{
    if ([_delegate respondsToSelector:@selector(textViewDidClickCell:onlyOriginal:)]) {
        MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
        if (self.statusFrame.comment) {
            statusFrame.status = self.statusFrame.comment.status;
            [_delegate textViewDidClickCell:statusFrame onlyOriginal:NO];
        } else {
            statusFrame.status = self.statusFrame.status;
            [_delegate textViewDidClickCell:statusFrame onlyOriginal:YES];
        }
    }
}

#pragma mark 点击转发微博微博文字执行代理方法
- (void)retweetTextViewDidTapCell
{
    if ([_delegate respondsToSelector:@selector(textViewDidClickCell:onlyOriginal:)]) {
        //新建被转发微博的frame（作为原创微博的显示形式）
        MRTStatusFrame *retweetFrame = [[MRTStatusFrame alloc] init];
        if (self.statusFrame.comment) {
            retweetFrame.status = self.statusFrame.comment.status;
        } else {
            retweetFrame.status = self.statusFrame.status.retweeted_status;
        }
        
        
        [_delegate textViewDidClickCell:retweetFrame onlyOriginal:NO];
    }
}

#pragma mark 点击回复按钮
- (void)clickReplyButton
{
    if ([_delegate respondsToSelector:@selector(clickReplyButtonWithFrame:)]) {
        NSLog(@"clickReplyButton2");
        MRTCommentFrame *commentFrame = [[MRTCommentFrame alloc] init];
        commentFrame.comment = _statusFrame.comment;
        [_delegate clickReplyButtonWithFrame:commentFrame];
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

#pragma mark 点击url代理方法
- (void)clickURL:(NSURL *)url
{
    if ([_delegate respondsToSelector:@selector(clickURL:)]) {
        [_delegate clickURL:url];
    }
}

@end
