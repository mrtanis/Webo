//
//  MRTMessageCommentFrame.m
//  Webo
//
//  Created by mrtanis on 2017/7/26.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageCommentFrame.h"

@implementation MRTMessageCommentFrame

#pragma mark 计算@我的评论的frame
//重写setComment，计算控件Frame
- (void)setComment:(MRTComment *)comment
{
    _comment = comment;
    
    //计算主评论
    [self setUpCommentViewFrame];
    
    //计算cell高度
    _cellHeight = CGRectGetMaxY(_originalViewFrame) + 5;
    
    //计算被回复的评论
    if (comment.reply_comment) {
        [self setUpReply_commentViewFrame];
        _cellHeight = CGRectGetMaxY(_retweetViewFrame) + 5;
    }
}

#pragma mark 计算主评论frame
- (void)setUpCommentViewFrame
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
    CGSize name_Size = [self.comment.user.name sizeWithAttributes:nameAttrs];
    
    _originalNameFrame = CGRectMake(name_X, name_Y, name_Size.width, name_Size.height);
    
    //vip
    if (self.comment.user.vip) {
        CGFloat vip_X = CGRectGetMaxX(_originalNameFrame) + 5;
        CGFloat vip_Y = CGRectGetMidY(_originalNameFrame) - 7.5;
        CGFloat vip_W_H =14;
        
        _originalVipFrame = CGRectMake(vip_X, vip_Y, vip_W_H, vip_W_H);
    }
    
    //时间和来源的计算转移到为其frame赋值中，因为时间是变化的，而来源frame又依赖时间frame
    
    //正文
    CGFloat text_X = icon_X;
    CGFloat text_Y = CGRectGetMaxY(_originalIconFrame);
    CGFloat text_Width = MRTScreen_Width - 2 * MRTStatusCellMargin;
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    //字体
    textAttrs[NSFontAttributeName] = MRTTextFont;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, text_Width, text_Width)];
    textView.font = MRTTextFont;
    textView.attributedText = self.comment.attrText;
    CGSize contentSize = textView.contentSize;
    
    _originalTextFrame = CGRectMake(text_X, text_Y, contentSize.width, contentSize.height);
    
    CGFloat original_Height = CGRectGetMaxY(_originalTextFrame);
    //status概览
    if (self.comment.reply_comment == nil) {
        //配图
        CGFloat picture_X = 0;
        CGFloat picture_Y = 0;
        CGFloat picture_WH = 70;
        _originalStatusPictureFrame = CGRectMake(picture_X, picture_Y, picture_WH, picture_WH);
        
        //昵称
        CGFloat status_name_X = CGRectGetMaxX(_originalStatusPictureFrame) +  MRTStatusCellMargin;
        CGFloat status_name_Y = MRTStatusCellMargin;
        
        NSMutableDictionary *status_nameAttrs = [NSMutableDictionary dictionary];
        status_nameAttrs[NSFontAttributeName] = MRTNameFont;
        //昵称前加上@
        NSString *nameStr = nil;
        if (self.comment.status.retweeted_status) {
            nameStr = [NSString stringWithFormat:@"@%@", self.comment.status.retweeted_status.user.name];
        } else {
            nameStr = [NSString stringWithFormat:@"@%@", self.comment.status.user.name];
        }
        
        CGSize status_name_Size = [nameStr sizeWithAttributes:status_nameAttrs];
        
        _originalStatusNameFrame = CGRectMake(status_name_X, status_name_Y, status_name_Size.width, status_name_Size.height);
        
        //正文
        CGFloat status_text_X = status_name_X;
        CGFloat status_text_Y = CGRectGetMaxY(_originalStatusNameFrame) + 6;
        CGFloat status_text_Width = MRTScreen_Width - 4 * MRTStatusCellMargin - picture_WH;
        CGFloat status_text_Height = picture_WH - CGRectGetMaxY(_originalStatusNameFrame) - 12;
        
        _originalStatusTextFrame = CGRectMake(status_text_X, status_text_Y, status_text_Width, status_text_Height);
        
        //灰色背景
        _originalStatusBackgroundFrame = CGRectMake(MRTStatusCellMargin, CGRectGetMaxY(_originalTextFrame), MRTScreen_Width - MRTStatusCellMargin * 2, picture_WH);
        
        original_Height = CGRectGetMaxY(_originalStatusBackgroundFrame) + MRTStatusCellMargin;
    }
    
    
    //通过以上子控件的frame计算原创微博的frame
    CGFloat original_X = 0;
    CGFloat original_Y = 0;
    CGFloat original_Width = MRTScreen_Width;
    
    _originalViewFrame = CGRectMake(original_X, original_Y, original_Width, original_Height);
}

#pragma mark 计算被评论微博frame
- (void)setUpReply_commentViewFrame
{
    
    //正文
    CGFloat text_X = MRTStatusCellMargin;
    CGFloat text_Y = 0;
    CGFloat text_Width = MRTScreen_Width - 2 * MRTStatusCellMargin;
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    //字体
    textAttrs[NSFontAttributeName] = MRTTextFont;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, text_Width, text_Width)];
    textView.font = MRTTextFont;
    textView.attributedText = self.comment.reply_comment.attrText;
    CGSize contentSize = textView.contentSize;
    
    _retweetTextFrame = CGRectMake(text_X, text_Y, contentSize.width, contentSize.height);
    
    //被回复评论的status
    MRTStatus *status = [[MRTStatus alloc] init];
    if (self.comment.status.retweeted_status) {
        status = self.comment.status.retweeted_status;
    } else {
        status = self.comment.status;
    }
    //配图
    CGFloat picture_X = 0;
    CGFloat picture_Y = 0;
    CGFloat picture_WH = 70;
    _retweetStatusPictureFrame = CGRectMake(picture_X, picture_Y, picture_WH, picture_WH);
    
    //昵称
    CGFloat status_name_X = CGRectGetMaxX(_retweetStatusPictureFrame) +  MRTStatusCellMargin;
    CGFloat status_name_Y = MRTStatusCellMargin;
    
    NSMutableDictionary *status_nameAttrs = [NSMutableDictionary dictionary];
    status_nameAttrs[NSFontAttributeName] = MRTNameFont;
    //昵称前加上@
    NSString *nameStr = [NSString stringWithFormat:@"@%@", status.user.name];
    CGSize status_name_Size = [nameStr sizeWithAttributes:status_nameAttrs];
    
    _retweetStatusNameFrame = CGRectMake(status_name_X, status_name_Y, status_name_Size.width, status_name_Size.height);
    
    //正文
    CGFloat status_text_X = status_name_X;
    CGFloat status_text_Y = CGRectGetMaxY(_retweetStatusNameFrame) + 6;
    CGFloat status_text_Width = MRTScreen_Width - 4 * MRTStatusCellMargin - picture_WH;
    CGFloat status_text_Height = picture_WH - CGRectGetMaxY(_retweetStatusNameFrame) - 12;
    
    _retweetStatusTextFrame = CGRectMake(status_text_X, status_text_Y, status_text_Width, status_text_Height);
    
    //白色背景
    _retweetStatusBackgroundFrame = CGRectMake(MRTStatusCellMargin, CGRectGetMaxY(_retweetTextFrame), MRTScreen_Width - MRTStatusCellMargin * 2, picture_WH);
    
    CGFloat retweet_Height = CGRectGetMaxY(_retweetStatusBackgroundFrame) + MRTStatusCellMargin;
    
    //计算被回复评论的frame
    CGFloat retweet_X = 0;
    CGFloat retweet_Y = CGRectGetMaxY(_originalViewFrame);
    CGFloat retweet_Width = MRTScreen_Width;
    
    _retweetViewFrame = CGRectMake(retweet_X, retweet_Y, retweet_Width, retweet_Height);
    
}

#pragma mark encode
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_comment forKey:@"comment"];
    [aCoder encodeCGRect:_originalViewFrame forKey:@"originalViewFrame"];
    [aCoder encodeCGRect:_originalIconFrame forKey:@"originalIconFrame"];
    [aCoder encodeCGRect:_originalNameFrame forKey:@"originalNameFrame"];
    [aCoder encodeCGRect:_originalVipFrame forKey:@"originalVipFrame"];
    [aCoder encodeCGRect:_originalTextFrame forKey:@"originalTextFrame"];
    [aCoder encodeCGRect:_originalStatusPictureFrame forKey:@"originalStatusPictureFrame"];
    [aCoder encodeCGRect:_originalStatusTextFrame forKey:@"originalStatusTextFrame"];
    [aCoder encodeCGRect:_originalStatusNameFrame forKey:@"originalStatusNameFrame"];
    [aCoder encodeCGRect:_originalStatusBackgroundFrame forKey:@"originalStatusBackgroundFrame"];
    
    [aCoder encodeCGRect:_retweetViewFrame forKey:@"retweetViewFrame"];
    [aCoder encodeCGRect:_retweetTextFrame forKey:@"retweetTextFrame"];
    [aCoder encodeCGRect:_retweetStatusPictureFrame forKey:@"retweetStatusPictureFrame"];
    [aCoder encodeCGRect:_retweetStatusNameFrame forKey:@"retweetStatusNameFrame"];
    [aCoder encodeCGRect:_retweetStatusTextFrame forKey:@"retweetStatusTextFrame"];
    [aCoder encodeCGRect:_retweetStatusBackgroundFrame forKey:@"retweetStatusBackgroundFrame"];
    
    [aCoder encodeFloat:_cellHeight forKey:@"cellHeight"];
}
#pragma mark decode
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _comment = [aDecoder decodeObjectForKey:@"comment"];
        _originalViewFrame = [aDecoder decodeCGRectForKey:@"originalViewFrame"];
        _originalIconFrame = [aDecoder decodeCGRectForKey:@"originalIconFrame"];
        _originalNameFrame = [aDecoder decodeCGRectForKey:@"originalNameFrame"];
        _originalVipFrame = [aDecoder decodeCGRectForKey:@"originalVipFrame"];
        _originalTextFrame = [aDecoder decodeCGRectForKey:@"originalTextFrame"];
        _originalStatusPictureFrame = [aDecoder decodeCGRectForKey:@"originalStatusPictureFrame"];
        _originalStatusNameFrame = [aDecoder decodeCGRectForKey:@"originalStatusNameFrame"];
        _originalStatusTextFrame = [aDecoder decodeCGRectForKey:@"originalStatusTextFrame"];
        _originalStatusBackgroundFrame = [aDecoder decodeCGRectForKey:@"originalStatusBackgroundFrame"];
        
        _retweetViewFrame = [aDecoder decodeCGRectForKey:@"retweetViewFrame"];
        _retweetTextFrame = [aDecoder decodeCGRectForKey:@"retweetTextFrame"];
        _retweetStatusPictureFrame = [aDecoder decodeCGRectForKey:@"retweetStatusPictureFrame"];
        _retweetStatusNameFrame = [aDecoder decodeCGRectForKey:@"retweetStatusNameFrame"];
        _retweetStatusTextFrame = [aDecoder decodeCGRectForKey:@"retweetStatusTextFrame"];
        _retweetStatusBackgroundFrame = [aDecoder decodeCGRectForKey:@"retweetStatusBackgroundFrame"];
        
        _cellHeight = [aDecoder decodeFloatForKey:@"cellHeight"];
    }
    
    return self;
}



@end
