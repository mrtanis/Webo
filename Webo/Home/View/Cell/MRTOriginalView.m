//
//  MRTOriginalView.m
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTOriginalView.h"
#import "UIImageView+WebCache.h"
#import "MRTStatus.h"
#import "MRTPictureView.h"

@interface MRTOriginalView()

@property (nonatomic, weak) UIImageView *iconView;

@property (nonatomic, weak) UILabel *nameLabel;

@property (nonatomic, weak) UIImageView *vipView;

@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, weak) UILabel *sourceLabel;

@property (nonatomic, weak) UILabel *textLabel;

@property (nonatomic, weak) MRTPictureView *pictureView;

@end

@implementation MRTOriginalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //设置子控件
        [self setUpAllChildView];
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageWithStretchableName:@"timeline_card_top_background"];
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
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = MRTTextFont;
    textLabel.textColor = [UIColor darkTextColor];
    textLabel.numberOfLines = 0;
    [self addSubview:textLabel];
    _textLabel = textLabel;
    
    //配图
    MRTPictureView *picView = [[MRTPictureView alloc] init];
    [self addSubview:picView];
    _pictureView = picView;
    
}

- (void)setStatusFrame:(MRTStatusFrame *)statusFrame
{
    
    _statusFrame = statusFrame;
    
    //设置frame
    [self setUpFrame];
    
    //设置数据
    [self setUpData];
}

//设置frame
- (void)setUpFrame
{
    //头像
    _iconView.frame = self.statusFrame.originalIconFrame;

    //昵称
    _nameLabel.frame = self.statusFrame.originalNameFrame;
    
    //vip frame
    if (self.statusFrame.status.user.vip) {
        _vipView.hidden = NO;
        _vipView.frame = self.statusFrame.originalVipFrame;
    } else {
        _vipView.hidden = YES;
    }
    
    //时间
    //_timeLabel.frame = self.statusFrame.originalTimeFrame;
    
    CGFloat time_X = _nameLabel.frame.origin.x;
    NSMutableDictionary *timeAttrs = [NSMutableDictionary dictionary];
    timeAttrs[NSFontAttributeName] = MRTTimeFont;
    CGSize time_Size = [self.statusFrame.status.created_at sizeWithAttributes:timeAttrs];
    CGFloat time_Y = CGRectGetMaxY(_iconView.frame) - time_Size.height ;
    
    _timeLabel.frame = CGRectMake(time_X, time_Y, time_Size.width, time_Size.height);
    
    
    
    //来源
    CGFloat source_X = CGRectGetMaxX(_timeLabel.frame) + MRTStatusCellMargin;
    CGFloat source_Y = time_Y;
    
    NSMutableDictionary *sourceAttrs = [NSMutableDictionary dictionary];
    sourceAttrs[NSFontAttributeName] = MRTSourceFont;
    CGSize source_Size = [self.statusFrame.status.source sizeWithAttributes:sourceAttrs];
    
    _sourceLabel.frame = CGRectMake(source_X, source_Y, source_Size.width, source_Size.height);
    //_sourceLabel.frame = self.statusFrame.originalSourceFrame;
    
    //正文
    _textLabel.frame = self.statusFrame.originalTextFrame;

    //配图
    _pictureView.frame = self.statusFrame.originalPictureFrame;
    _pictureView.onePicSize = self.statusFrame.originalOnePicSize;
}

- (void)setUpData
{
    MRTStatus *status = self.statusFrame.status;
    
    //头像
    [_iconView sd_setImageWithURL:status.user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    //昵称
    _nameLabel.text = status.user.name;
    
    if (status.user.vip) {
        _nameLabel.textColor = [UIColor orangeColor];
    } else {
        _nameLabel.textColor = [UIColor blackColor];
    }
    
    //vip
    NSString *vipImageName = [NSString stringWithFormat:@"common_icon_membership_level%d", status.user.mbrank];
    
    _vipView.image = [UIImage imageNamed:vipImageName];
    
    //时间
    _timeLabel.text = status.created_at;
    _timeLabel.textColor = [UIColor grayColor];
    
    //来源
    _sourceLabel.text = status.source;
    NSLog(@"source:%@", status.source);
    _sourceLabel.textColor = [UIColor grayColor];
    
    //正文
    _textLabel.text = status.text;
    
    //配图
    _pictureView.pic_urls = status.pic_urls;
}

@end
