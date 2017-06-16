//
//  MRTStatusFrame.m
//  Webo
//
//  Created by mrtanis on 2017/5/24.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusFrame.h"
#import "UIImageView+WebCache.h"

@implementation MRTStatusFrame

//重写setStatus，计算控件Frame
- (void)setStatus:(MRTStatus *)status
{
    _status = status;
    
    //计算原创微博
    [self setUpOriginalViewFrame];
    
    //tooBar坐标Y值
    CGFloat toolBar_Y = CGRectGetMaxY(_originalViewFrame);
    
    //计算转发微博
    if (status.retweeted_status) {
        [self setUpRetweetViewFrame];
        
        toolBar_Y = CGRectGetMaxY(_retweetViewFrame);
    }
    
    //有了Y值就可以计算tooBar的frame了
    CGFloat toolBar_X = 0;
    CGFloat tooBar_Width = MRTScreen_Width;
    CGFloat tooBar_Height = 35;
    
    _toolBarFrame = CGRectMake(toolBar_X, toolBar_Y, tooBar_Width, tooBar_Height);
    
    //计算cell高度
    _cellHeight = CGRectGetMaxY(_toolBarFrame);
}

#pragma mark 计算原创微博frame
- (void)setUpOriginalViewFrame
{
    //头像
    CGFloat icon_X = MRTStatusCellMargin;
    CGFloat icon_Y = MRTStatusCellMargin;
    CGFloat icon_W_H = 40;
    
    _originalIconFrame = CGRectMake(icon_X, icon_Y, icon_W_H, icon_W_H);
    
    //昵称
    CGFloat name_X = CGRectGetMaxX(_originalIconFrame) + MRTStatusCellMargin;
    CGFloat name_Y = icon_Y;
    //通富文本设置字体大小
    NSMutableDictionary *nameAttrs = [NSMutableDictionary dictionary];
    nameAttrs[NSFontAttributeName] = MRTNameFont;
    CGSize name_Size = [self.status.user.name sizeWithAttributes:nameAttrs];
    
    _originalNameFrame = CGRectMake(name_X, name_Y, name_Size.width, name_Size.height);
    
    //vip
    if (self.status.user.vip) {
        CGFloat vip_X = CGRectGetMaxX(_originalNameFrame) + 5;
        CGFloat vip_Y = CGRectGetMidY(_originalNameFrame) - 7.5;
        CGFloat vip_W_H =14;
        
        _originalVipFrame = CGRectMake(vip_X, vip_Y, vip_W_H, vip_W_H);
    }
    
    //时间和来源的计算转移到为其frame赋值中，因为时间是变化的，而来源frame又依赖时间frame
    
    //正文
    CGFloat text_X = icon_X;
    CGFloat text_Y = CGRectGetMaxY(_originalIconFrame) + MRTStatusCellMargin;
    CGFloat text_Width = MRTScreen_Width - 2 * MRTStatusCellMargin;
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    //字体
    textAttrs[NSFontAttributeName] = MRTTextFont;
    //段落格式
    //NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    //paraStyle.lineSpacing = 10;
    //textAttrs[NSParagraphStyleAttributeName] = paraStyle;
    
    //NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:self.status.text attributes:textAttrs];
    
    //_textStr = attText;
    
    CGRect text_Rect = [self.status.text boundingRectWithSize:CGSizeMake(text_Width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttrs context:nil];
    
    _originalTextFrame = CGRectMake(text_X, text_Y, ceil(text_Rect.size.width), ceil(text_Rect.size.height));
    
    CGFloat original_Height = CGRectGetMaxY(_originalTextFrame) + MRTStatusCellMargin;
    //配图
    if (_status.pic_urls.count) {
        CGFloat pic_X = MRTStatusCellMargin;
        CGFloat pic_Y = CGRectGetMaxY(_originalTextFrame) + MRTStatusCellMargin;
        CGSize picSize = [self pictureSizeWithCount:(int)_status.pic_urls.count picture:[self.status.pic_urls firstObject]];
        //如果只有一张图，则为originalOnePicSize赋值
        if (_status.pic_urls.count == 1) _originalOnePicSize = picSize;
        
        _originalPictureFrame = CGRectMake(pic_X, pic_Y, picSize.width, picSize.height);
        
        original_Height = CGRectGetMaxY(_originalPictureFrame) + MRTStatusCellMargin;
    }
    
    //通过以上子控件的frame计算原创微博的frame
    CGFloat original_X = 0;
    CGFloat original_Y = 0;
    CGFloat original_Width = MRTScreen_Width;
    
    _originalViewFrame = CGRectMake(original_X, original_Y, original_Width, original_Height);
}

#pragma mark 计算转发微博frame
- (void)setUpRetweetViewFrame
{
    //昵称
    CGFloat name_X = MRTStatusCellMargin;
    CGFloat name_Y = name_X;

    NSMutableDictionary *nameAttrs = [NSMutableDictionary dictionary];
    nameAttrs[NSFontAttributeName] = MRTNameFont;
    //昵称前加上@
    NSString *nameStr = [NSString stringWithFormat:@"@%@", self.status.retweeted_status.user.name];
    CGSize name_Size = [nameStr sizeWithAttributes:nameAttrs];
    
    _retweetNameFrame = CGRectMake(name_X, name_Y, name_Size.width, name_Size.height);
    
    //正文
    CGFloat text_X = name_X;
    CGFloat text_Y = CGRectGetMaxY(_retweetNameFrame) + MRTStatusCellMargin;
    CGFloat text_Width = MRTScreen_Width - 2 * MRTStatusCellMargin;
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    //字体
    textAttrs[NSFontAttributeName] = MRTTextFont;
    //段落格式
    //NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    //paraStyle.lineSpacing = 10;
    //textAttrs[NSParagraphStyleAttributeName] = paraStyle;
    
    CGRect text_Rect = [self.status.retweeted_status.text boundingRectWithSize:CGSizeMake(text_Width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttrs context:nil];
    
    _retweetTextFrame = CGRectMake(text_X, text_Y, ceil(text_Rect.size.width), ceil(text_Rect.size.height));
    
    CGFloat retweet_Height = CGRectGetMaxY(_retweetTextFrame) + MRTStatusCellMargin;
    //配图
    if (_status.retweeted_status.pic_urls.count) {
        CGFloat pic_X = MRTStatusCellMargin;
        CGFloat pic_Y = CGRectGetMaxY(_retweetTextFrame) + MRTStatusCellMargin;
        CGSize picSize = [self pictureSizeWithCount:(int)_status.retweeted_status.pic_urls.count picture:[self.status.retweeted_status.pic_urls firstObject]];
        //如果只有一张图，则为retweetOnePicSize赋值
        if (_status.retweeted_status.pic_urls.count == 1) _retweetOnePicSize = picSize;
        
        _retweetPictureFrame = CGRectMake(pic_X, pic_Y, picSize.width, picSize.height);
        
        retweet_Height = CGRectGetMaxY(_retweetPictureFrame) + MRTStatusCellMargin;
    }

    
    //计算转发微博的frame
    CGFloat retweet_X = 0;
    CGFloat retweet_Y = CGRectGetMaxY(_originalViewFrame);
    CGFloat retweet_Width = MRTScreen_Width;
    
    _retweetViewFrame = CGRectMake(retweet_X, retweet_Y, retweet_Width, retweet_Height);
    
}

#pragma mark 计算配图的size
- (CGSize)pictureSizeWithCount:(int)count picture:(MRTPicture *)picture//添加picture参数是因为存在原创和转发的区分
{
    //若只有一张图则按4：3显示，正方形则1：1
    if (count == 1) {
        NSURL *url = picture.thumbnail_pic;
        UIImage *pic = [UIImage getImageFromURL:url];
        
        CGFloat height = 0;
        CGFloat width = 0;
        CGFloat longSide = (MRTScreen_Width - 20) / 3.0 * 2;
        if (pic.size.height > pic.size.width) {
            height = longSide;
            width = height * 3 * 0.25;
        } else if (pic.size.height < pic.size.width) {
            width = longSide;
            height = height * 3 * 0.25;
        } else {
            width = longSide;
            height = longSide;
        }
        
        return CGSizeMake(width, height);
    } else {
        //计算列数
        int cols = count == 4 ? 2 : 3;
        //计算行数
        int rows = (count - 1) / cols + 1;
        CGFloat photo_W_H = (MRTScreen_Width - MRTStatusCellMargin * 3) / 3.0;
        CGFloat width = cols * photo_W_H + (cols - 1) * 5;
        CGFloat height = rows * photo_W_H + (rows - 1) * 5;
        
        return CGSizeMake(width, height);
    }
}
    


@end
