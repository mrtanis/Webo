//
//  MRTMessageCommentView.m
//  Webo
//
//  Created by mrtanis on 2017/8/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageCommentView.h"
#import "UIImageView+WebCache.h"
#import "MRTStatus.h"

@interface MRTMessageCommentView () <UITextViewDelegate>
@property (nonatomic, weak) UIImageView *vipView;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *sourceLabel;
@property (nonatomic, weak) UIImageView *statusPicture;
@property (nonatomic, weak) UILabel *statusNameLabel;
@property (nonatomic, weak) UILabel *statusTextLabel;
@property (nonatomic, weak) UIView *statusBackground;

@property (nonatomic, weak) UIButton *replyButton;
@end

@implementation MRTMessageCommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //设置子控件
        [self setUpAllChildView];
        self.userInteractionEnabled = YES;
        //self.image = [UIImage imageWithStretchableName:@"timeline_card_top_background"];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)setUpAllChildView
{
    //头像
    UIImageView *iconView = [[UIImageView alloc] init];
    //将头像设置为圆形
    iconView.layer.cornerRadius = 20;
    //裁减掉圆形外的图片
    iconView.clipsToBounds = YES;
    [self addSubview:iconView];
    _iconView = iconView;
    
    //添加评论列表的回复按钮
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [replyButton setTitle:@"回复" forState:UIControlStateNormal];
    replyButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [replyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [replyButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_white_highlighted"] forState:UIControlStateHighlighted];
    [replyButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_white"] forState:UIControlStateNormal];
    replyButton.frame = CGRectMake(MRTScreen_Width - MRTStatusCellMargin - 50, MRTStatusCellMargin, 50, 30);
    [replyButton addTarget:self action:@selector(clickReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:replyButton];
    _replyButton = replyButton;
    
    //昵称
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = MRTNameFont;
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    //vip
    UIImageView *vipView = [[UIImageView alloc] init];
    [self addSubview:vipView];
    _vipView = vipView;
    
    //时间
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = MRTTimeFont;
    [self addSubview:timeLabel];
    _timeLabel = timeLabel;
    
    //来源
    UILabel *sourceLabel = [[UILabel alloc] init];
    sourceLabel.font = MRTSourceFont;
    [self addSubview:sourceLabel];
    _sourceLabel = sourceLabel;
    
    //正文
    UITextView *textView = [[UITextView alloc] init];
    textView.font = MRTTextFont;
    textView.textColor = [UIColor darkTextColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.userInteractionEnabled = YES;
    
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
    [textView addGestureRecognizer:tap];
    
    textView.delegate = self;
    [self addSubview:textView];
    _textView = textView;
    
    //status
    if (self.commentFrame.comment.reply_comment == nil) {
        //灰色背景
        UIView *statusBackground = [[UIView alloc] init];
        statusBackground.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
        [self addSubview:statusBackground];
        _statusBackground = statusBackground;
        
        //图片
        UIImageView *statusPicture = [[UIImageView alloc] init];
        statusPicture.contentMode = UIViewContentModeScaleAspectFill;
        statusPicture.clipsToBounds = YES;
        [self.statusBackground addSubview:statusPicture];
        _statusPicture = statusPicture;
        
        //昵称
        UILabel *statusNameLabel = [[UILabel alloc] init];
        statusNameLabel.font = MRTNameFont;
        [self.statusBackground addSubview:statusNameLabel];
        _statusNameLabel = statusNameLabel;
        
        //正文
        UILabel *statusTextLabel = [[UILabel alloc] init];
        statusTextLabel.font = [UIFont systemFontOfSize:12];
        statusTextLabel.numberOfLines = 2;
        [self.statusBackground addSubview:statusTextLabel];
        _statusTextLabel = statusTextLabel;
    }
}

- (void)setCommentFrame:(MRTMessageCommentFrame *)commentFrame
{
    
    _commentFrame = commentFrame;
    
    //设置frame
    [self setUpFrame];
    
    //设置数据
    [self setUpData];
}

//设置frame
- (void)setUpFrame
{
    //头像
    _iconView.frame = self.commentFrame.originalIconFrame;
    
    //昵称
    _nameLabel.frame = self.commentFrame.originalNameFrame;
    
    //vip frame
    if (self.commentFrame.comment.user.vip) {
        _vipView.hidden = NO;
        _vipView.frame = self.commentFrame.originalVipFrame;
    } else {
        _vipView.hidden = YES;
    }
    
    //时间
    //_timeLabel.frame = self.statusFrame.originalTimeFrame;
    
    CGFloat time_X = _nameLabel.frame.origin.x;
    NSMutableDictionary *timeAttrs = [NSMutableDictionary dictionary];
    timeAttrs[NSFontAttributeName] = MRTTimeFont;
    CGSize time_Size = [self.commentFrame.comment.created_at sizeWithAttributes:timeAttrs];
    
    CGFloat time_Y = CGRectGetMaxY(_iconView.frame) - time_Size.height ;
    
    _timeLabel.frame = CGRectMake(time_X, time_Y, time_Size.width, time_Size.height);
    
    //来源
    CGFloat source_X = CGRectGetMaxX(_timeLabel.frame) + MRTStatusCellMargin;
    CGFloat source_Y = time_Y;
    
    NSMutableDictionary *sourceAttrs = [NSMutableDictionary dictionary];
    sourceAttrs[NSFontAttributeName] = MRTSourceFont;
    CGSize source_Size = [self.commentFrame.comment.source sizeWithAttributes:sourceAttrs];
    
    _sourceLabel.frame = CGRectMake(source_X, source_Y, source_Size.width, source_Size.height);
    
    //正文
    _textView.frame = self.commentFrame.originalTextFrame;
    
    //status
    _statusBackground.frame = self.commentFrame.originalStatusBackgroundFrame;
    _statusPicture.frame = self.commentFrame.originalStatusPictureFrame;
    _statusNameLabel.frame = self.commentFrame.originalStatusNameFrame;
    _statusTextLabel.frame = self.commentFrame.originalStatusTextFrame;

}

- (void)setUpData
{
    MRTComment *comment = self.commentFrame.comment;
    //头像
    [_iconView sd_setImageWithURL:comment.user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    //昵称
    _nameLabel.text = comment.user.name;
    
    if (comment.user.vip) {
        _nameLabel.textColor = [UIColor orangeColor];
    } else {
        _nameLabel.textColor = [UIColor blackColor];
    }
    
    //vip
    NSString *vipImageName = [NSString stringWithFormat:@"common_icon_membership_level%d", comment.user.mbrank];
    
    _vipView.image = [UIImage imageNamed:vipImageName];
    
    //时间
    _timeLabel.text = comment.created_at;
    _timeLabel.textColor = [UIColor grayColor];
    
    //来源
    _sourceLabel.text = comment.source;
    NSLog(@"source:%@", comment.source);
    _sourceLabel.textColor = [UIColor grayColor];
    
    //正文
    _textView.attributedText = comment.attrText;
    
    //status
    MRTStatus *status = [[MRTStatus alloc] init];
    if (comment.status.retweeted_status) {
        status = comment.status.retweeted_status;
    } else {
        status = comment.status;
    }
    //配图
    MRTURL_object *url_object = [status.url_objects firstObject];
    if (url_object.object.object.image) {
        
        MRTImage *image = url_object.object.object.image;
        
        
        [_statusPicture sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    } else if (status.thumbnail_pic) {
        NSString *middle = [status.thumbnail_pic stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        [_statusPicture sd_setImageWithURL:[NSURL URLWithString:middle] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    } else {
        NSLog(@"头像url：%@", status.user.avatar_large);
        [_statusPicture sd_setImageWithURL:status.user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
    //昵称
    _statusNameLabel.text = status.user.name;
    //正文
    _statusTextLabel.text = status.text;
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    if ([[URL scheme] rangeOfString:@"at"].location != NSNotFound) {
        NSLog(@"点击昵称");
        return NO;
    }
    if ([[URL scheme] rangeOfString:@"trend"].location != NSNotFound) {
        NSLog(@"点击话题");
        return NO;
    }
    if ([[URL scheme] rangeOfString:@"short"].location != NSNotFound) {
        NSLog(@"点击短连接");
        return NO;
    }
    
    return YES;
}

- (void)tapCell:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(commentTextViewDidTapCell)]) {
        [_delegate commentTextViewDidTapCell];
    }
}

- (void)clickReplyButton:(UIButton *)button
{
    
    if ([_delegate respondsToSelector:@selector(clickReplyButton)]) {
        NSLog(@"clickReplyButton1");
        [_delegate clickReplyButton];
    }
}

@end
