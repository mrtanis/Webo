//
//  MRTOAuthViewController.m
//  Webo
//
//  Created by mrtanis on 2017/5/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTOAuthViewController.h"
#import "MBProgressHUD+MRT.h"
#import "AFNetworking.h"
#import "MRTAccount.h"
#import "MRTAccountStore.h"
#import "MRTRootVCPicker.h"

#define MRTClient_id @"1316088724"
#define MRTClient_secret @"1cc4b41b7fee63dddbd4739831434efa"
#define MRTAuthorizeBaseUrl @"https://api.weibo.com/oauth2/authorize"
#define MRTRedirect_uri @"http://www.baidu.com"


@interface MRTOAuthViewController () <UIWebViewDelegate>

@end

@implementation MRTOAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *logInView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:logInView];
    
    NSString *baseURL = MRTAuthorizeBaseUrl;
    NSString *client_id = MRTClient_id;
    NSString *redirect_uri = MRTRedirect_uri;
    
    //拼接URL字符串
    NSString *urlStr = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@", baseURL, client_id, redirect_uri];
    //创建URL
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //加载请求
    [logInView loadRequest:request];
    
    //设置代理
    logInView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UIWebViewDelegate>

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //提示用户正在加载
    [MBProgressHUD showMessage:@"正在加载..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideHUD];
}

//当webView需要加载一个请求的时候，就会调用此方法询问是否加载请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlStr = request.URL.absoluteString;
    //获取code（RequestToken)
    NSRange range = [urlStr rangeOfString:@"code="];
    if (range.length) {
        NSString *code = [urlStr substringFromIndex:range.location + range.length];
        NSLog(@"urlStr:%@", urlStr);
        NSLog(@"The code is:%@", code);
        [self accessTokenWithCode:code];
        
        //不加载回调页面
        return  NO;
    }
    
    return  YES;
}

-(void)accessTokenWithCode:(NSString*)code{
    
    [MRTAccountStore accountWithCode:code success:^{
        
        //进入新特性界面或者主界面
        [MRTRootVCPicker chooseRootVC:MRTKeyWindow];
        
    } failure:^(NSError *error) {
        
        NSLog(@"error:%@", error);
        
    }];
}

@end
