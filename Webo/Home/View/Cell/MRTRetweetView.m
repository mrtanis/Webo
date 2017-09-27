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
#import "UIImageView+WebCache.h"


@interface MRTRetweetView() <UITextViewDelegate>


@property (nonatomic, weak) MRTPictureView *pictureView;

@property (nonatomic, weak) UIButton *playButton;

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
    
    //视频封面
    UIImageView *posterView = [[UIImageView alloc] init];
    posterView.clipsToBounds = YES;
    posterView.contentMode = UIViewContentModeScaleAspectFill;
    posterView.userInteractionEnabled = YES;
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:[UIImage imageNamed:@"icon_bigplay"] forState:UIControlStateNormal];
    [playButton sizeToFit];
    playButton.frame = CGRectMake((MRTScreen_Width - 20) * 0.5 - playButton.width * 0.5, (MRTScreen_Width - 20) * 0.5625 * 0.5 - playButton.height * 0.5, playButton.width, playButton.height);
    [playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [posterView addSubview:playButton];
    _playButton = playButton;
    
    [self addSubview:posterView];
    _posterView = posterView;
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
    
    //视频封面
    _posterView.frame = self.statusFrame.retweetVideoPosterFrame;
    
    NSString *posterStr = nil;
    MRTURL_object *url_object = [self.statusFrame.status.retweeted_status.url_objects firstObject];
    if (!_statusFrame.isAtStatus) {
        posterStr = self.statusFrame.status.retweeted_status.videoPosterStr;;
    } else {
        NSLog(@"有视频地址str:%@", url_object.object.object.image.url);
        
        NSLog(@"有视频地址url:%@",  [NSURL URLWithString:url_object.object.object.image.url]);
        posterStr = url_object.object.object.image.url;
    }
    [_posterView sd_setImageWithURL:[NSURL URLWithString:posterStr] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"] options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            NSLog(@"封面下载成功:%@",image);
        } else {
            NSLog(@"封面下载失败:%@", error);
        }
    }];
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
        
        
        //[self playVideo];
        
        //__unused NSString *pic = [NSString videoPicUrlFromString:htmlStr];
        
        return YES;
    }

    return YES;
}

- (void)tapCell:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(retweetTextViewDidTapCell)]) {
        [_delegate retweetTextViewDidTapCell];
    }
}

- (void)playVideo
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        NSString *videoStr = nil;
        MRTURL_object *url_object = [strongSelf.statusFrame.status.retweeted_status.url_objects firstObject];
        
        if (url_object.object.object.stream.hd_url.length) {
            videoStr = url_object.object.object.stream.hd_url;
        } else {
            NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strongSelf.statusFrame.status.retweeted_status.urlStr]];
            
            NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
            NSLog(@"htmlStr:%@", htmlStr);
            
            videoStr = [NSString videoUrlFromString:htmlStr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (videoStr.length) {
                if ([strongSelf.delegate respondsToSelector:@selector(playVideoWithUrl:onView:)]) {
                    [strongSelf.delegate playVideoWithUrl:[NSURL URLWithString:videoStr] onView:_posterView];
                }
            }
        });
    });
}

@end
