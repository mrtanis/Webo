//
//  MRTCommentPopMenu.h
//  Webo
//
//  Created by mrtanis on 2017/8/12.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRTCommentPopMenuDelegate <NSObject>
@optional
- (void)popMenuDidClickButton:(NSInteger)index;

@end
@interface MRTCommentPopMenu : UIView
@property (nonatomic, weak) id <MRTCommentPopMenuDelegate>delegate;

@property (nonatomic) NSInteger selectedRow;

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text;
@end
