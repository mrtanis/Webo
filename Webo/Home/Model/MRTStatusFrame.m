//
//  MRTStatusFrame.m
//  Webo
//
//  Created by mrtanis on 2017/5/24.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTStatusFrame.h"

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
    _cellHeight = CGRectGetMaxY(_toolBarFrame) + MRTStatusCellMargin;
}

#pragma mark 计算原创微博frame
- (void)setUpOriginalViewFrame
{
    //头像
    CGFloat icon_X = MRTStatusCellMargin;
    CGFloat icon_Y = MRTStatusCellMargin;
    CGFloat icon_W_H = 35;
    
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
    
    //时间
    /*
    CGFloat time_X = name_X;
    NSMutableDictionary *timeAttrs = [NSMutableDictionary dictionary];
    timeAttrs[NSFontAttributeName] = MRTTimeFont;
    CGSize time_Size = [self.status.created_at sizeWithAttributes:timeAttrs];
    
    CGFloat time_Y = CGRectGetMaxY(_originalIconFrame) - time_Size.height ;
    
    _originalTimeFrame = CGRectMake(time_X, time_Y, time_Size.width, time_Size.height);
    
    //来源
    CGFloat source_X = CGRectGetMaxX(_originalTimeFrame) + MRTStatusCellMargin;
    CGFloat source_Y = time_Y;
    
    NSMutableDictionary *sourceAttrs = [NSMutableDictionary dictionary];
    sourceAttrs[NSFontAttributeName] = MRTSourceFont;
    CGSize source_Size = [self.status.source sizeWithAttributes:sourceAttrs];
    
    _originalSourceFrame = CGRectMake(source_X, source_Y, source_Size.width, source_Size.height);
    */
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
    
    //通过以上子控件的frame计算原创微博的frame
    CGFloat original_X = 0;
    CGFloat original_Y = 0;
    CGFloat original_Width = MRTScreen_Width;
    CGFloat original_Height = CGRectGetMaxY(_originalTextFrame) + MRTStatusCellMargin;
    
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
    CGSize name_Size = [self.status.retweeted_status.user.name sizeWithAttributes:nameAttrs];
    
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
    
    _retweetTextFrame = CGRectMake(text_X, text_Y, text_Rect.size.width, text_Rect.size.height);
    
    //计算转发微博的frame
    CGFloat retweet_X = 0;
    CGFloat retweet_Y = CGRectGetMaxY(_originalViewFrame);
    CGFloat retweet_Width = MRTScreen_Width;
    CGFloat retweet_Height = CGRectGetMaxY(_retweetTextFrame) + MRTStatusCellMargin;
    
    _retweetViewFrame = CGRectMake(retweet_X, retweet_Y, retweet_Width, retweet_Height);
}


@end
