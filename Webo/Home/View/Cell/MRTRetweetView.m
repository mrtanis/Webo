//
//  MRTRetweetView.m
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRetweetView.h"

@interface MRTRetweetView()

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *textLabel;

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
}

- (void)setStatusFrame:(MRTStatusFrame *)statusFrame
{
    _statusFrame = statusFrame;
    
    //昵称
    _nameLabel.frame = self.statusFrame.retweetNameFrame;
    _nameLabel.text = self.statusFrame.status.retweeted_status.user.name;
    
    //正文
    _textLabel.frame = self.statusFrame.retweetTextFrame;
    _textLabel.text = self.statusFrame.status.retweeted_status.text;
    _textLabel.textColor = [UIColor grayColor];
}


@end
