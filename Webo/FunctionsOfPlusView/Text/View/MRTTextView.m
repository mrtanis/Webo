//
//  MRTTextView.m
//  Webo
//
//  Created by mrtanis on 2017/6/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextView.h"
#import "MRTTextAttachment.h"
#import "NSAttributedString+MRTConvert.h"
#import "NSMutableAttributedString+MRTConvert.h"

@interface MRTTextView()



@end

@implementation MRTTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = [UIColor darkTextColor];
        NSMutableDictionary *textAttrDic = [NSMutableDictionary dictionary];
        textAttrDic[NSFontAttributeName] = [UIFont systemFontOfSize:16];
        textAttrDic[NSForegroundColorAttributeName] = [UIColor darkTextColor];
        self.typingAttributes = textAttrDic;
        self.allowsEditingTextAttributes = NO;
        //添加通知监听文本框输入
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:nil];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        menuController.menuItems = @[
                                     [[UIMenuItem alloc] initWithTitle:@"剪切" action:@selector(mrt_cut:)],
                                     [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(mrt_copy:)],
                                     [[UIMenuItem alloc] initWithTitle:@"选择" action:@selector(mrt_select:)],
                                     [[UIMenuItem alloc] initWithTitle:@"全选" action:@selector(mrt_selectAll:)],
                                     [[UIMenuItem alloc] initWithTitle:@"粘贴" action:@selector(mrt_paste:)]
                                     ];
        [menuController setTargetRect:self.bounds inView:self];
        [menuController setMenuVisible:NO];
                                     
        
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        //_keyboardHeight = MRTScreen_Width - 50;
        //[self addGestureRecognizer:tap];
    }
    
    return self;
}


//重写setFont，设置textVie字体的同时设置占位符的字体
- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeHolder.font = font;
    //改变字体后不要忘了sizeToFit
    [self.placeHolder sizeToFit];
}

//懒加载placeHolder
- (UILabel *)placeHolder
{
    if (!_placeHolder) {
        UILabel *label = [[UILabel alloc] init];
        
        [self addSubview:label];
        _placeHolder = label;
    }
    
    return _placeHolder;
}

//设置placeHolderStr
- (void)setPlaceHolderStr:(NSString *)placeHolderStr
{
    _placeHolderStr = placeHolderStr;
    
    self.placeHolder.text = placeHolderStr;
    self.placeHolder.textColor = [UIColor grayColor];
    
    [self.placeHolder sizeToFit];
    
    if (self.text.length) {
        self.placeHolder.hidden = YES;
    }
}

//设置子控件位置
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.placeHolder.x = 5;
    self.placeHolder.y = 8;
}

//文本框文字变化时执行此方法
- (void)textChange
{
    //根据有无文字判断是否隐藏占位符和发送按钮是否可点击
    if (self.text.length) {
        self.placeHolder.hidden = YES;
        self.rightItem.enabled = YES;
    } else {
        self.placeHolder.hidden = NO;
        if (!_repostFlag) self.rightItem.enabled = NO;
        
    }
    
    
    /*
    //根据文字调整overview的位置，避免遮挡文字
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    
    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake(self.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttrs context:nil].size;*/
    CGSize textSize = self.contentSize;
    CGRect rect = self.overview.frame;
    //判断是发微博的图片视图还是转发的overview
    CGFloat boundaryHeight = rect.size.height == 80 ? 130 : 100;
    if (boundaryHeight < ceil(textSize.height) + 30)
    {
        rect.origin.y = ceil(textSize.height) + 30;
        self.overview.frame = rect;
        
    } else {
        rect.origin.y = boundaryHeight;
        self.overview.frame = rect;
    }
    NSLog(@"self.y:%f,self.height:%f,offset.y:%f", self.y, self.height, self.contentOffset.y);
    NSLog(@"overview.y:%f,overview.height:%f", self.overview.y, self.overview.height);
    NSLog(@"contentsize.height:%f", self.contentSize.height);
    NSLog(@"textView:%@", self);
    
    /*
    //如果overview移出了textView的frame，则增加textView的height
    if (_overview.y + _overview.height > self.height) {
        
        CGRect rect = self.frame;
        rect.size.height = _overview.y + _overview.height;
        
        self.frame = rect;
    } else if (self.y + _overview.y + _overview.height < MRTScreen_Height - 44) {//如果overview没有超出textView的原始frame，则恢复textView的原始frame
        CGFloat differFromOrigin = self.y + self.height - (MRTScreen_Height - 44);
        CGRect rect = self.frame;
        rect.size.height -= differFromOrigin;
        self.frame = rect;
    }*/
    
}

//设置overView时调整insets
- (void)setOverview:(UIView *)overview
{
    _overview = overview;
    self.contentInset = UIEdgeInsetsMake(0, 0, overview.frame.size.height + 40, 0);
    
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if ((action == @selector(mrt_cut:) && self.selectedRange.length) || (action == @selector(mrt_copy:) && self.selectedRange.length) || (action == @selector(mrt_select:) && self.selectedRange.length == 0 && self.text.length) || (action == @selector(mrt_selectAll:) && self.selectedRange.length != self.text.length && self.text.length) || (action == @selector(mrt_paste:) && pasteboard.string.length)) {
        
        return YES;
    } else {
        return NO;
    }
}

- (void)mrt_cut:(UIMenuController *)menuController
{
    NSMutableAttributedString *str = [[self.attributedText attributedSubstringFromRange:self.selectedRange] mutableCopy];
    
    NSString *plainString = [str getPlainEmoString];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = plainString;
    
    
    NSMutableAttributedString *wholeStr = [self.attributedText mutableCopy];
    NSRange rangeCopy = NSMakeRange(self.selectedRange.location, 0);
    [wholeStr deleteCharactersInRange:self.selectedRange];
    self.attributedText = wholeStr;
    
    if (self.attributedText.length == 0) {
        self.placeHolder.hidden = NO;
        self.rightItem.enabled = NO;
    }
    self.selectedRange = rangeCopy;
    /*
    NSMutableString *text = [self.text mutableCopy];
    [text replaceCharactersInRange:self.selectedRange withString:@""];
    self.text = text;
    if (text.length == 0) {
        self.placeHolder.hidden = NO;
    }
    self.selectedRange = NSMakeRange(self.selectedRange.location, 0);
     */
}

- (void)mrt_copy:(UIMenuController *)menuController
{
    NSMutableAttributedString *str = [[self.attributedText attributedSubstringFromRange:self.selectedRange] mutableCopy];
    NSString *plainString = [str getPlainEmoString];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = plainString;
}

- (void)mrt_select:(UIMenuController *)menuController
{
    NSInteger textLength = self.text.length;
    NSInteger location = self.selectedRange.location;
    
    //开始分词
    NSString *str = self.text;
    CFStringTokenizerRef ref = CFStringTokenizerCreate(NULL, (__bridge CFStringRef)str, CFRangeMake(0, str.length), kCFStringTokenizerUnitWord, NULL);
    NSInteger m;
    if (location >= 3) {
        m = 3;
    } else {
        m = location;
    }
    CFStringTokenizerGoToTokenAtIndex(ref, location);
    CFRange range = CFStringTokenizerGetCurrentTokenRange(ref);
    NSLog(@"第一次range(%ld,%ld), location:%ld", range.location, range.length, location);
    if (range.location <= location && range.location + range.length >= location) {
        NSLog(@"第1种情况");
        NSRange nsRange = NSMakeRange(range.location, range.length);
        NSLog(@"分词为：%@", [self.text substringWithRange:nsRange]);
        self.selectedRange = nsRange;
    } else {
        NSLog(@"第2种情况");
        if (location < textLength) {
            NSLog(@"第2.1种情况");
            self.selectedRange = NSMakeRange(location, 1);
        } else {
            NSLog(@"第2.2种情况");
            self.selectedRange = NSMakeRange(location - 1, 1);
        }
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:YES animated:YES];
    
}

- (void)mrt_selectAll:(UIMenuController *)menuController
{
    self.selectedRange = NSMakeRange(0, self.text.length);
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:YES animated:YES];
}

- (void)mrt_paste:(UIMenuController *)menuController
{
    self.placeHolder.hidden = YES;
    self.rightItem.enabled = YES;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    //if (self.attributedText.length) {
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        NSMutableAttributedString *pasteStr = [[NSMutableAttributedString alloc] initWithString:pasteboard.string];
        //如果粘贴板含有表情字符串，则替换为表情
        
        [pasteStr convertToAttributedEmoString];
        
        [attText replaceCharactersInRange:self.selectedRange withAttributedString:pasteStr];
        NSMutableDictionary *textAttrDic = [NSMutableDictionary dictionary];
        textAttrDic[NSFontAttributeName] = [UIFont systemFontOfSize:16];
        textAttrDic[NSForegroundColorAttributeName] = [UIColor darkTextColor];
        [attText addAttributes:textAttrDic range:NSMakeRange(0, attText.length)];
        self.attributedText = attText;
        self.selectedRange = NSMakeRange(self.selectedRange.location + pasteStr.length, 0);
    /*} else {
        
        if (self.text.length) {
            NSMutableString *str = [self.text mutableCopy];
            [str replaceCharactersInRange:self.selectedRange withString:pasteboard.string];
            self.text = str;
            self.selectedRange = NSMakeRange(self.selectedRange.location + pasteboard.string.length, 0);
        } else {
            self.text = pasteboard.string;
        }
        
    }*/
}

//dealloc时移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
