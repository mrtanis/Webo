//
//  MRTCommentFrame.m
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCommentFrame.h"

@implementation MRTCommentFrame

//设置comment时，计算控件frame
- (void)setComment:(MRTComment *)comment
{
    _comment = comment;
    
    //计算原始评论frame
    [self setUpCommentViewFrame];
    
    //计算cell高度
    _cellHeight = CGRectGetMaxY(_commentViewFrame);
}

- (void)setUpCommentViewFrame
{
    //头像
    CGFloat icon_X = MRTStatusCellMargin;
    CGFloat icon_Y = MRTStatusCellMargin;
    CGFloat icon_W_H = 40;
    
    _commentIconFrame = CGRectMake(icon_X, icon_Y, icon_W_H, icon_W_H);
    
    //昵称
    CGFloat name_X = CGRectGetMaxX(_commentIconFrame) + MRTStatusCellMargin;
    CGFloat name_Y = icon_Y + 5;
    //通富文本设置字体大小
    NSMutableDictionary *nameAttrs = [NSMutableDictionary dictionary];
    nameAttrs[NSFontAttributeName] = MRTCommentNameFont;
    CGSize name_Size = [self.comment.user.name sizeWithAttributes:nameAttrs];
    
    _commentNameFrame = CGRectMake(name_X, name_Y, name_Size.width, name_Size.height);
    
    //vip
    if (self.comment.user.vip) {
        CGFloat vip_X = CGRectGetMaxX(_commentNameFrame) + 5;
        CGFloat vip_Y = CGRectGetMidY(_commentNameFrame) - 7.5;
        CGFloat vip_W_H =14;
        
        _commentVipFrame = CGRectMake(vip_X, vip_Y, vip_W_H, vip_W_H);
    }
    
    //时间和来源的计算转移到为其frame赋值中，因为时间是变化的，而来源frame又依赖时间frame
    
    //正文
    CGFloat text_X = name_X;
    CGFloat text_Y = CGRectGetMaxY(_commentIconFrame);
    CGFloat text_Width = MRTScreen_Width - 3 * MRTStatusCellMargin - icon_W_H;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, text_Width, text_Width)];
    textView.font = MRTCommentTextFont;
    textView.attributedText = self.comment.attrText;
    CGSize contentSize = textView.contentSize;
    
    _commentTextFrame = CGRectMake(text_X, text_Y, contentSize.width, contentSize.height);
    
    
    
    //通过以上子控件的frame计算原始评论的frame
    CGFloat comment_X = 0;
    CGFloat comment_Y = 0;
    CGFloat comment_Width = MRTScreen_Width;
    CGFloat comment_Height = CGRectGetMaxY(_commentTextFrame) + MRTStatusCellMargin;
    
    _commentViewFrame = CGRectMake(comment_X, comment_Y, comment_Width, comment_Height);
}

@end
