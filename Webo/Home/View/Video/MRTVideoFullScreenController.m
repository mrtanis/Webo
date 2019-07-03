//
//  MRTVideoFullScreenController.m
//  Webo
//
//  Created by mrtanis on 2017/10/31.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTVideoFullScreenController.h"

@interface MRTVideoFullScreenController ()

@end

@implementation MRTVideoFullScreenController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (_orientationMask) {
        return _orientationMask;
    } else {
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return _hideStatusBar;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor orangeColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
