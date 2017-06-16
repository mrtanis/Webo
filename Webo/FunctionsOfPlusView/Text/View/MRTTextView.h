//
//  MRTTextView.h
//  Webo
//
//  Created by mrtanis on 2017/6/11.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTTextView : UITextView

@property (nonatomic, copy) NSString *placeHolderStr;

@property (nonatomic) CGFloat keyboardHeight;

@property (nonatomic, strong) UIBarButtonItem *rightItem;

@end
