//
//  MRTMessageReplyCommentView.m
//  Webo
//
//  Created by mrtanis on 2017/8/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageReplyCommentView.h"
#import "UIImageView+WebCache.h"
#import "MRTStatus.h"

@interface MRTMessageReplyCommentView () <UITextViewDelegate>
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UIImageView *statusPicture;
@property (nonatomic, weak) UILabel *statusNameLabel;
@property (nonatomic, weak) UILabel *statusTextLabel;
@property (nonatomic, weak) UIView *statusBackground;

@end

@implementation MRTMessageReplyCommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //设置子控件
        [self setUpAllChildView];
        self.userInteractionEnabled = YES;
        //self.image = [UIImage imageWithStretchableName:@"timeline_card_top_background"];
        self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    }
    
    return self;
}

- (void)setUpAllChildView
{
    
    
    //正文
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor clearColor];  
    textView.font = MRTTextFont;
    textView.textColor = [UIColor darkTextColor];
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
    textView.linkTextAttributes = attr;
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
    //白色背景
    UIView *statusBackground = [[UIView alloc] init];
    statusBackground.backgroundColor = [UIColor whiteColor];
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
    
    //正文
    _textView.frame = self.commentFrame.retweetTextFrame;
    
    //status
    _statusBackground.frame = self.commentFrame.retweetStatusBackgroundFrame;
    _statusPicture.frame = self.commentFrame.retweetStatusPictureFrame;
    _statusNameLabel.frame = self.commentFrame.retweetStatusNameFrame;
    _statusTextLabel.frame = self.commentFrame.retweetStatusTextFrame;
    
}

- (void)setUpData
{
    MRTComment *comment = self.commentFrame.comment;
        
    //正文
    _textView.attributedText = comment.reply_comment.attrText;
    
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
    if ([[URL scheme] rangeOfString:@"http"].location != NSNotFound) {
        NSLog(@"点击短连接");
        if ([_delegate respondsToSelector:@selector(clickURL:)]) {
            [_delegate clickURL:URL];
        }
        return NO;
    }
    
    return YES;
}

- (void)tapCell:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(replyCommentTextViewDidTapCell)]) {
        [_delegate replyCommentTextViewDidTapCell];
    }
}


@end
