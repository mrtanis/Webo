//
//  MRTRetweetView.m
//  Webo
//
//  Created by mrtanis on 2017/5/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRetweetView.h"
#import "MRTPictureView.h"
#import "NSString+MRTConvert.h"


@interface MRTRetweetView() <UITextViewDelegate>


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
    //UILabel *textLabel = [[UILabel alloc] init];
    //textLabel.font = MRTTextFont;
    //textLabel.numberOfLines = 0;
    //[self addSubview:textLabel];
    UITextView *textView = [[UITextView alloc] init];
    textView.font = MRTTextFont;
    textView.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.userInteractionEnabled = YES;
    
    //textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0.5 blue:0.7 alpha:1]};
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
    [textView addGestureRecognizer:tap];
    
    textView.delegate = self;
    [self addSubview:textView];
    _textView = textView;
    
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
    _textView.frame = self.statusFrame.retweetTextFrame;
    _textView.attributedText = self.statusFrame.status.retweeted_status.attrText;
    _textView.textColor = [UIColor grayColor];
    
    //配图
    _pictureView.frame = self.statusFrame.retweetPictureFrame;
    _pictureView.onePicSize = self.statusFrame.retweetOnePicSize;
    _pictureView.pic_urls = self.statusFrame.status.retweeted_status.pic_urls;
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
        NSString *htmlStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.statusFrame.status.retweeted_status.urlStr] encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"htmlStr:%@", htmlStr);
        
        NSMutableDictionary *urlDic = [NSString videoUrlFromString:htmlStr];
        NSString *videoStr;
        BOOL allowRotate;
        if (urlDic[@"weibo"]) {
            videoStr = urlDic[@"weibo"];
            allowRotate = NO;
        } else {
            videoStr = urlDic[@"miaopai"];
            allowRotate = YES;
        }
        
        if (videoStr.length) {
            if ([_delegate respondsToSelector:@selector(playVideoWithUrl:allowRotate:)]) {
                [_delegate playVideoWithUrl:[NSURL URLWithString:videoStr] allowRotate:allowRotate];
            }
        }
        
        return NO;
    }

    return YES;
}

- (void)tapCell:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(retweetTextViewDidTapCell)]) {
        [_delegate retweetTextViewDidTapCell];
    }
}


@end
