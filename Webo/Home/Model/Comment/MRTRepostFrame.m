//
//  MRTRepostFrame.m
//  Webo
//
//  Created by mrtanis on 2017/8/13.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRepostFrame.h"

@implementation MRTRepostFrame
//设置repost时，计算控件frame
- (void)setRepost:(MRTStatus *)repost
{
    _repost = repost;
    
    //计算原始评论frame
    [self setUpRepostViewFrame];
    
    //计算cell高度
    _cellHeight = CGRectGetMaxY(_repostViewFrame);
}

- (void)setUpRepostViewFrame
{
    //头像
    CGFloat icon_X = MRTStatusCellMargin;
    CGFloat icon_Y = MRTStatusCellMargin;
    CGFloat icon_W_H = 40;
    
    _repostIconFrame = CGRectMake(icon_X, icon_Y, icon_W_H, icon_W_H);
    
    //昵称
    CGFloat name_X = CGRectGetMaxX(_repostIconFrame) + MRTStatusCellMargin;
    CGFloat name_Y = icon_Y + 5;
    //通富文本设置字体大小
    NSMutableDictionary *nameAttrs = [NSMutableDictionary dictionary];
    nameAttrs[NSFontAttributeName] = MRTCommentNameFont;
    CGSize name_Size = [self.repost.user.name sizeWithAttributes:nameAttrs];
    
    _repostNameFrame = CGRectMake(name_X, name_Y, name_Size.width, name_Size.height);
    
    //vip
    if (self.repost.user.vip) {
        CGFloat vip_X = CGRectGetMaxX(_repostNameFrame) + 5;
        CGFloat vip_Y = CGRectGetMidY(_repostNameFrame) - 7.5;
        CGFloat vip_W_H =14;
        
        _repostVipFrame = CGRectMake(vip_X, vip_Y, vip_W_H, vip_W_H);
    }
    
    //时间和来源的计算转移到为其frame赋值中，因为时间是变化的，而来源frame又依赖时间frame
    
    //正文
    CGFloat text_X = name_X;
    CGFloat text_Y = CGRectGetMaxY(_repostIconFrame);
    CGFloat text_Width = MRTScreen_Width - 3 * MRTStatusCellMargin - icon_W_H;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, text_Width, text_Width)];
    
    textView.attributedText = self.repost.attrText;
    textView.font = MRTCommentTextFont;
    CGSize contentSize = textView.contentSize;
    
    _repostTextFrame = CGRectMake(text_X, text_Y, contentSize.width, contentSize.height);
    
    
    
    //通过以上子控件的frame计算原始评论的frame
    CGFloat repost_X = 0;
    CGFloat repost_Y = 0;
    CGFloat repost_Width = MRTScreen_Width;
    CGFloat repost_Height = CGRectGetMaxY(_repostTextFrame) + MRTStatusCellMargin;
    
    _repostViewFrame = CGRectMake(repost_X, repost_Y, repost_Width, repost_Height);
}

@end
