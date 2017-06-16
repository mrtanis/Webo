//
//  MRTRetweetView.m
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRetweetView.h"
#import "MRTPictureView.h"

@interface MRTRetweetView()

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) MRTPictureView *pictureView;

@end

@implementation MRTRetweetView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //添加子控件
        [self setUpAllChildView];
        
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageWithStretchableName:@"timeline_retweet_background"];
    }
    
    return self;
}

- (void)setUpAllChildView
{
    //昵称
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = MRTNameFont;
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    //正文
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = MRTTextFont;
    textLabel.numberOfLines = 0;
    [self addSubview:textLabel];
    _textLabel = textLabel;
    
    //配图
    MRTPictureView *pictureView = [[MRTPictureView alloc] init];
    [self addSubview:pictureView];
    _pictureView = pictureView;
}

- (void)setStatusFrame:(MRTStatusFrame *)statusFrame
{
    _statusFrame = statusFrame;
    
    //昵称
    _nameLabel.frame = self.statusFrame.retweetNameFrame;
    //昵称前加上@
    NSString *nameStr = [NSString stringWithFormat:@"@%@", self.statusFrame.status.retweeted_status.user.name];
    _nameLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1];
    _nameLabel.text = nameStr;
    
    //正文
    _textLabel.frame = self.statusFrame.retweetTextFrame;
    _textLabel.text = self.statusFrame.status.retweeted_status.text;
    _textLabel.textColor = [UIColor grayColor];
    
    //配图
    _pictureView.frame = self.statusFrame.retweetPictureFrame;
    _pictureView.onePicSize = self.statusFrame.retweetOnePicSize;
    _pictureView.pic_urls = self.statusFrame.status.retweeted_status.pic_urls;
}


@end
