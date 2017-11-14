//
//  MRTSearchController.m
//  Webo
//
//  Created by mrtanis on 2017/10/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTSearchController.h"

@interface MRTSearchController ()

@end

@implementation MRTSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//自定义searchBar
- (UISearchBar *)searchBar
{
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MRTScreen_Width - 60, 35)];
    searchBar.placeholder = @"大家都在搜";
    
    return searchBar;
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
