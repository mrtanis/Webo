//
//  MRTSendRepostOverview.m
//  Webo
//
//  Created by mrtanis on 2017/6/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTSendRepostOverview.h"
#import "UIImageView+WebCache.h"

@interface MRTSendRepostOverview()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *textLabel;

@end

@implementation MRTSendRepostOverview



- (void)setImageWithUrl:(NSURL *)url
{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    [self addSubview:imageView];
    _imageView = imageView;
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = [NSString stringWithFormat:@"@%@", name];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = [UIColor darkTextColor];
    
    [nameLabel sizeToFit];
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.numberOfLines = 2;
    textLabel.textColor = [UIColor grayColor];
    
    [self addSubview:textLabel];
    _textLabel = textLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake(0, 0, 80, 80);
    
    _nameLabel.frame = CGRectMake(90, 10, _nameLabel.width, _nameLabel.height);
    
    _textLabel.frame = CGRectMake(90, CGRectGetMaxY(_nameLabel.frame) + 6, self.width - 100, self.height - CGRectGetMaxY(_nameLabel.frame) - 12);
}

@end
