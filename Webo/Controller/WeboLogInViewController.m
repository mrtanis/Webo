//
//  WeboLogInViewController.m
//  Webo
//
//  Created by mrtanis on 2017/4/24.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "WeboLogInViewController.h"

@interface WeboLogInViewController () <UIWebViewDelegate>

@end

@implementation WeboLogInViewController

- (void)loadView {
    self.navigationItem.title = @"微博登录";
    self.navigationController.toolbarHidden = YES;
    
    UIWebView *logInView = [[UIWebView alloc] init];
    logInView.opaque = NO;
    logInView.backgroundColor = [UIColor clearColor];
    logInView.delegate = self;
    logInView.scalesPageToFit = YES;
    
    self.view = logInView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
