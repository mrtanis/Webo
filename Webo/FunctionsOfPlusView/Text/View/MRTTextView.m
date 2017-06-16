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
        self.rightItem.enabled = NO;
    }
}


//dealloc时移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
