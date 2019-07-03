//
//  MRTMainView.m
//  Webo
//
//  Created by mrtanis on 2017/6/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMainView.h"
#import "MRTComment.h"
#import "UIImageView+WebCache.h"

@interface MRTMainView() <UITextViewDelegate>
@property (nonatomic, weak) UIImageView *iconView;

@property (nonatomic, weak) UILabel *nameLabel;

@property (nonatomic, weak) UIImageView *vipView;

@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, weak) UITextView *textView;


@end

@implementation MRTMainView

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
    
    //昵称
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = MRTCommentNameFont;
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
    
    //正文
    UITextView *textView = [[UITextView alloc] init];
    textView.font = MRTCommentTextFont;
    textView.textColor = [UIColor darkTextColor];
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
    textView.linkTextAttributes = attr;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.userInteractionEnabled = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    textView.delegate = self;
    
    [self addSubview:textView];
    _textView = textView;
}

- (void)setCommentFrame:(MRTCommentFrame *)commentFrame
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
    _iconView.frame = self.commentFrame.commentIconFrame;
    
    //昵称
    _nameLabel.frame = self.commentFrame.commentNameFrame;
    
    //vip frame
    if (self.commentFrame.comment.user.vip) {
        _vipView.hidden = NO;
        _vipView.frame = self.commentFrame.commentVipFrame;
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
    
    
    //正文
    _textView.frame = self.commentFrame.commentTextFrame;
    
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
    
    //正文
    _textView.attributedText = comment.attrText;
    
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
        return YES;
    }
    
    return YES;
}


@end
