//
//  MRTRepostMainView.m
//  Webo
//
//  Created by mrtanis on 2017/8/13.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRepostMainView.h"
#import "MRTStatus.h"
#import "UIImageView+WebCache.h"

@interface MRTRepostMainView()
@property (nonatomic, weak) UIImageView *iconView;

@property (nonatomic, weak) UILabel *nameLabel;

@property (nonatomic, weak) UIImageView *vipView;

@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, weak) UILabel *textLabel;

@end
@implementation MRTRepostMainView

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
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = MRTCommentTextFont;
    textLabel.textColor = [UIColor darkTextColor];
    textLabel.numberOfLines = 0;
    [self addSubview:textLabel];
    _textLabel = textLabel;
}

- (void)setRepostFrame:(MRTRepostFrame *)repostFrame
{
    _repostFrame = repostFrame;
    
    //设置frame
    [self setUpFrame];
    
    //设置数据
    [self setUpData];
}

//设置frame
- (void)setUpFrame
{
    //头像
    _iconView.frame = self.repostFrame.repostIconFrame;
    
    //昵称
    _nameLabel.frame = self.repostFrame.repostNameFrame;
    
    //vip frame
    if (self.repostFrame.repost.user.vip) {
        _vipView.hidden = NO;
        _vipView.frame = self.repostFrame.repostVipFrame;
    } else {
        _vipView.hidden = YES;
    }
    
    //时间
    //_timeLabel.frame = self.statusFrame.originalTimeFrame;
    
    CGFloat time_X = _nameLabel.frame.origin.x;
    NSMutableDictionary *timeAttrs = [NSMutableDictionary dictionary];
    timeAttrs[NSFontAttributeName] = MRTTimeFont;
    CGSize time_Size = [self.repostFrame.repost.created_at sizeWithAttributes:timeAttrs];
    CGFloat time_Y = CGRectGetMaxY(_iconView.frame) - time_Size.height ;
    
    _timeLabel.frame = CGRectMake(time_X, time_Y, time_Size.width, time_Size.height);
    
    
    //正文
    _textLabel.frame = self.repostFrame.repostTextFrame;
    
}

- (void)setUpData
{
    MRTStatus *repost = self.repostFrame.repost;
    
    //头像
    [_iconView sd_setImageWithURL:repost.user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    //昵称
    _nameLabel.text = repost.user.name;
    
    if (repost.user.vip) {
        _nameLabel.textColor = [UIColor orangeColor];
    } else {
        _nameLabel.textColor = [UIColor blackColor];
    }
    
    //vip
    NSString *vipImageName = [NSString stringWithFormat:@"common_icon_membership_level%d", repost.user.mbrank];
    
    _vipView.image = [UIImage imageNamed:vipImageName];
    
    //时间
    _timeLabel.text = repost.created_at;
    _timeLabel.textColor = [UIColor grayColor];
    
    //正文
    _textLabel.text = repost.text;
    
}

@end
