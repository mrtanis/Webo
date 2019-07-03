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
#import <WebKit/WebKit.h>
#import "MRTTimeLineStore.h"

#define MRTClient_id @"1316088724"
#define MRTClient_secret @"1cc4b41b7fee63dddbd4739831434efa"
#define MRTAuthorizeBaseUrl @"https://api.weibo.com/oauth2/authorize"
#define MRTRedirect_uri @"http://www.baidu.com"


@interface MRTOAuthViewController () <WKNavigationDelegate>

@property (nonatomic, weak) WKWebView *logInView;
@end

@implementation MRTOAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //如果是从个人界面切换登录，则设置导航栏
    if (_presentedByUser) {
        [self setUpNavigationBar];
    }
    
    WKWebView *logInView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
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
    logInView.navigationDelegate = self;
    _logInView = logInView;
}

#pragma mark 设置导航条
- (void)setUpNavigationBar
{
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionary];
    titleAttrs[NSForegroundColorAttributeName] = [UIColor darkTextColor];
    self.navigationController.navigationBar.titleTextAttributes = titleAttrs;
    
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf)];
   
    self.navigationItem.title = @"登录微博";
}

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    //提示用户正在加载
    [MBProgressHUD showMessage:@"正在加载..."];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (_presentedByUser) {
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [MBProgressHUD hideHUD];
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSString *urlStr = navigationAction.request.URL.absoluteString;
    //获取code（RequestToken)
    NSRange range = [urlStr rangeOfString:@"code="];
    if (range.length) {
        NSString *code = [urlStr substringFromIndex:range.location + range.length];
        NSLog(@"urlStr:%@", urlStr);
        NSLog(@"The code is:%@", code);
        [self accessTokenWithCode:code];
        
        //不加载回调页面
        
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

-(void)accessTokenWithCode:(NSString*)code{
    
    [MRTAccountStore accountWithCode:code success:^{
        
        //登录成功后先清空以前缓存的timeline数据
        //避免当前登录用户显示上个用户缓存timeline数据
        [MRTTimeLineStore deleteTimeLine];
        [MRTTimeLineStore deleteTimeLineOfAtMe];
        NSLog(@"进入新特性界面或者主界面");
        
        if (self.navigationController == nil) {
            //进入新特性界面或者主界面
            [MRTRootVCPicker chooseRootVC:MRTKeyWindow quickLaunchType:MRTQuickLaunchTypeFinished];
        } else {
            [self dismissViewControllerAnimated:NO completion:^{
                //进入新特性界面或者主界面
                [MRTRootVCPicker chooseRootVC:MRTKeyWindow quickLaunchType:MRTQuickLaunchTypeFinished];
            }];
        }
        
        
    } failure:^(NSError *error) {
        
        NSLog(@"error:%@", error);
        
    }];
}

/*
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //提示用户正在加载
    [MBProgressHUD showMessage:@"正在加载..."];
    //[NSObject performSelector:@selector(timeOut) withObject:nil afterDelay:6];
}

- (void)timeOut
{
    [MBProgressHUD hideHUD];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOut) object:nil];
    [MBProgressHUD hideHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOut) object:nil];
    [MBProgressHUD hideHUD];
    [self dismissViewControllerAnimated:YES completion:nil];
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
}*/




@end
