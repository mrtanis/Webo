//
//  MRTTextView.m
//  Webo
//
//  Created by mrtanis on 2017/6/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextView.h"

@interface MRTTextView()

//占位符
@property (nonatomic, weak) UILabel *placeHolder;

@end

@implementation MRTTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = [UIColor darkTextColor];
        
        //添加通知监听文本框输入
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:nil];
        
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
    }
    */
}


//dealloc时移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
