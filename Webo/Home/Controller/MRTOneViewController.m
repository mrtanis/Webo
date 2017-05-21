//
//  MRTOneViewController.m
//  Webo
//
//  Created by mrtanis on 2017/5/14.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTOneViewController.h"
#import "UIBarButtonItem+MRTItem.h"
#import "MRTTwoViewController.h"

@interface MRTOneViewController ()

@end

@implementation MRTOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    //设置leftBarButtonItem
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_back"] highLightedImage:[UIImage imageNamed:@"navigationbar_back_highlighted"] target:self action:@selector(backToPre) forControlEvents:UIControlEventTouchUpInside];
    
    //设置rightBarButtonItem
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_more"] highLightedImage:[UIImage imageNamed:@"navigationbar_more_highlighted"] target:self action:@selector(backToRoot) forControlEvents:UIControlEventTouchUpInside];
     */
}
/*
- (void)backToPre
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backToRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
*/
- (IBAction)jumpToTwoController:(id)sender
{
    MRTTwoViewController *two = [[MRTTwoViewController alloc] init];
    [self.navigationController pushViewController:two animated:YES];
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
