//
//  MRTTextViewController.h
//  Webo
//
//  Created by mrtanis on 2017/6/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTTextViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *photoAssets;
@property (nonatomic) BOOL originalMode; //原图模式

@property (nonatomic, strong) UIImage *photoFromCamera;

//如果直接选择照片再进入写微博控制器，意味着不能通过block设置照片视图，所以标注在viewWillApear时手动设置
@property (nonatomic) BOOL shouldSetUpPhotoView;
@end
