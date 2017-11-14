//
//  MRTTextView.h
//  Webo
//
//  Created by mrtanis on 2017/6/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRTtextViewDelegate <NSObject>
@optional
- (void)textChanged;
@end

@interface MRTTextView : UITextView

@property (nonatomic, weak) id <MRTtextViewDelegate> delegate_mrt;
@property (nonatomic, copy) NSString *placeHolderStr;
//占位符
@property (nonatomic, weak) UILabel *placeHolder;

@property (nonatomic) CGFloat keyboardHeight;


@property (nonatomic, weak) UIView *overview;


//判断是否为发微博或者评论界面，如果是转发界面则发送按钮一直可用
@property (nonatomic) BOOL repostFlag;

- (void)textChange;

@end
