//
//  MRTWebViewer.h
//  Webo
//
//  Created by mrtanis on 2017/11/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTWebViewer : UIViewController
@property (nonatomic) BOOL popToRootVC;
- (instancetype)initWithURL:(NSURL *)url;

@end
