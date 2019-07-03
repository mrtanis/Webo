//
//  MRTMessageCommentCell.m
//  Webo
//
//  Created by mrtanis on 2017/8/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageCommentCell.h"


@interface MRTMessageCommentCell() <MRTMessageCommentViewDelegate, MRTMessageReplyCommentViewDelegate>
@end

@implementation MRTMessageCommentCell

#pragma mark 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //添加子控件
        [self setUpAllChildView];
        //清空cell背景颜色
        //self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

#pragma mark 添加子控件
- (void)setUpAllChildView
{
    //主评论
    MRTMessageCommentView *commentView = [[MRTMessageCommentView alloc] init];
    commentView.delegate = self;
    [self addSubview:commentView];
    _commentView = commentView;
    
    //被回复的评论
    MRTMessageReplyCommentView *replyCommentView = [[MRTMessageReplyCommentView alloc] init];
    replyCommentView.delegate = self;
    [self addSubview:replyCommentView];
    _replyCommentView = replyCommentView;
}

#pragma mark 设置布局
- (void)setCommentFrame:(MRTMessageCommentFrame *)commentFrame
{
    
    _commentFrame = commentFrame;
    
    //设置原创微博frame
    _commentView.frame = commentFrame.originalViewFrame;
    _commentView.commentFrame = commentFrame;
    
    //设置转发微博frame
    _replyCommentView.frame = commentFrame.retweetViewFrame;
    _replyCommentView.commentFrame = commentFrame;
}

#pragma mark 点击原创微博文字执行代理方法
- (void)originalTextViewDidTapCell
{
    if ([_delegate respondsToSelector:@selector(textViewDidClickCell:)]) {
        
        [_delegate textViewDidClickCell:_commentFrame];
    }
}

#pragma mark 点击转发微博微博文字执行代理方法
- (void)retweetTextViewDidTapCell
{
    if ([_delegate respondsToSelector:@selector(textViewDidClickCell:)]) {
        
        [_delegate textViewDidClickCell:_commentFrame];
    }
}

#pragma mark 点击回复按钮
- (void)clickReplyButton
{
    if ([_delegate respondsToSelector:@selector(clickReplyButtonWithFrame:)]) {
        NSLog(@"clickReplyButton2");
        MRTCommentFrame *commentFrame = [[MRTCommentFrame alloc] init];
        commentFrame.comment = _commentFrame.comment;
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
