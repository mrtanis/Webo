//
//  MRTCommentTitle.h
//  Webo
//
//  Created by mrtanis on 2017/6/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTCommentTitle : UIButton
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title frame:(CGRect)frame;
@property (nonatomic, strong) UIFont *titleFont;
@end
