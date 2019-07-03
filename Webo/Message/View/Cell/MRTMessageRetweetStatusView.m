//
//  MRTMessageRetweetStatusView.m
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageRetweetStatusView.h"
#import "UIImageView+WebCache.h"
#import "MRTImage.h"
#import "MRTURL_object.h"

@interface MRTMessageRetweetStatusView()
@property (nonatomic, weak) UIImageView *backgroundView;
@property (nonatomic, weak) UIImageView *pictureView;
@end
@implementation MRTMessageRetweetStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //添加子控件
        [self setUpAllChildView];
        
        self.userInteractionEnabled = YES;
        //self.image = [UIImage imageWithStretchableName:@"timeline_retweet_background"];
        self.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)setUpAllChildView
{
    //灰色背景
    UIImageView *backgroundView = [[UIImageView alloc] init];
    //backgroundView.image = [UIImage imageWithStretchableName:@"timeline_retweet_background"];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [self addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    //昵称
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = MRTNameFont;
    [self.backgroundView addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    //正文
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.numberOfLines = 2;
    [self.backgroundView addSubview:textLabel];
    _textLabel = textLabel;
    
    //配图
    UIImageView *pictureView = [[UIImageView alloc] init];
    
    pictureView.contentMode = UIViewContentModeScaleAspectFill;
    pictureView.clipsToBounds = YES;
    [self.backgroundView addSubview:pictureView];
    _pictureView = pictureView;
}

- (void)setStatusFrame:(MRTMessageStatusFrame *)statusFrame
{
    _statusFrame = statusFrame;
    
    MRTStatus *status = [[MRTStatus alloc] init];
    if (self.statusFrame.status.retweeted_status) {
        status = self.statusFrame.status.retweeted_status;
    } else if (self.statusFrame.comment) {
        status = self.statusFrame.comment.status;
    }
    
    //灰色背景
    _backgroundView.frame = self.statusFrame.retweetBackgroundFrame;
    //昵称
    _nameLabel.frame = self.statusFrame.retweetNameFrame;
    //昵称前加上@
    NSString *nameStr = [NSString stringWithFormat:@"@%@", status.user.name];
    _nameLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
    _nameLabel.text = nameStr;
    
    //正文
    _textLabel.frame = self.statusFrame.retweetTextFrame;
    _textLabel.text = status.text;
    _textLabel.textColor = [UIColor grayColor];
    
    //配图
    MRTURL_object *url_object = [status.url_objects firstObject];
    if (url_object.object.object.image) {
        
        MRTImage *image = url_object.object.object.image;
        
        
        [_pictureView sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    } else if (status.thumbnail_pic) {
        NSString *midlle = [status.thumbnail_pic stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        [_pictureView sd_setImageWithURL:[NSURL URLWithString:midlle] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    } else {
        NSLog(@"头像url：%@", status.user.avatar_large);
        [_pictureView sd_setImageWithURL:status.user.avatar_large placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
    
    _pictureView.frame = self.statusFrame.retweetPictureFrame;
}


- (void)tapCell:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(retweetTextViewDidTapCell)]) {
        [_delegate retweetTextViewDidTapCell];
    }
}


@end
