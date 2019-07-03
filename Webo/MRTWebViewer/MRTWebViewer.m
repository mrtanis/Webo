//
//  MRTWebViewer.m
//  Webo
//
//  Created by mrtanis on 2017/11/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTWebViewer.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD+MRT.h"


@interface MRTWebViewer ()<WKNavigationDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) UIProgressView *progress;

@property (nonatomic, weak) UIView *darkBG;
@property (nonatomic, weak) UIView *whiteBG;

@end

@implementation MRTWebViewer

#pragma mark - 初始化
- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    
    if (self) {
        _url = url;
    }
    
    return self;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setUpNavigationBar];
    
    [self beginLoadRequest];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //从扫描界面进入需要删除导航栏黑色透明背景
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - 设置导航栏
- (void)setUpNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(popSelf)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"feed_picture_topguideicon_more_highlight"] style:UIBarButtonItemStylePlain target:self action:@selector(moreButton)];
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 42, MRTScreen_Width, 1)];
    [self.navigationController.navigationBar addSubview:progress];
    _progress = progress;
}

#pragma mark - 开始加载请求
- (void)beginLoadRequest
{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    _scrollView = scrollView;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:scrollView.bounds];
    //webView.scrollView.contentOffset = CGPointMake(0, -64);
    //webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    webView.navigationDelegate = self;
    
    [scrollView addSubview:webView];
    _webView = webView;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    
    [_webView loadRequest:request];
}

#pragma mark - 弹出控制器
- (void)popSelf
{
    [_progress removeFromSuperview];
    [_webView stopLoading];
    if (_popToRootVC) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - 更多选项
- (void)moreButton
{
    //背景视图变暗
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIView *darkBG = [[UIView alloc] initWithFrame:window.bounds];
    darkBG.backgroundColor = [UIColor blackColor];
    darkBG.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [darkBG addGestureRecognizer:tap];
    [window addSubview:darkBG];
    _darkBG = darkBG;
    
    //选项白色背景
    UIView *whiteBG = [[UIView alloc] initWithFrame:CGRectMake(0 , window.height, window.width, 164)];
    whiteBG.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [window addSubview:whiteBG];
    _whiteBG = whiteBG;
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    blurView.frame = whiteBG.bounds;
    [whiteBG addSubview:blurView];
    
    //系统分享
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"icon_system_share"] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont systemFontOfSize:12];
    shareButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [shareButton.titleLabel sizeToFit];
    shareButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    shareButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 30, 0);
    shareButton.titleEdgeInsets = UIEdgeInsetsMake(70, (60 - shareButton.titleLabel.frame.size.width) / 2.0 - 60, 0, (60 - shareButton.titleLabel.frame.size.width) / 2.0);
    [shareButton addTarget:self action:@selector(systemShare) forControlEvents:UIControlEventTouchUpInside];
    [blurView.contentView addSubview:shareButton];
    //复制链接
    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [copyButton setTitle:@"复制链接" forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"icon_copy_link"] forState:UIControlStateNormal];
    copyButton.titleLabel.font = [UIFont systemFontOfSize:12];
    copyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [copyButton.titleLabel sizeToFit];
    copyButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    copyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    copyButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 30, 0);
    copyButton.titleEdgeInsets = UIEdgeInsetsMake(70, (60 - copyButton.titleLabel.frame.size.width) / 2.0 - 60, 0, (60 - copyButton.titleLabel.frame.size.width) / 2.0);
    [copyButton addTarget:self action:@selector(copyLink) forControlEvents:UIControlEventTouchUpInside];
    [blurView.contentView addSubview:copyButton];
    //在Safari中打开
    UIButton *safariButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [safariButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [safariButton setTitle:@"Safari打开" forState:UIControlStateNormal];
    [safariButton setImage:[UIImage imageNamed:@"icon_open_in_safari"] forState:UIControlStateNormal];
    safariButton.titleLabel.font = [UIFont systemFontOfSize:12];
    safariButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [safariButton.titleLabel sizeToFit];
    safariButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    safariButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    safariButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 30, 0);
    safariButton.titleEdgeInsets = UIEdgeInsetsMake(70, (60 - safariButton.titleLabel.frame.size.width) / 2.0 - 60, 0, (60 - safariButton.titleLabel.frame.size.width) / 2.0);
    [safariButton addTarget:self action:@selector(openInSafari) forControlEvents:UIControlEventTouchUpInside];
    [blurView.contentView addSubview:safariButton];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [blurView.contentView addSubview:cancelButton];
    
    //设置按钮位置
    shareButton.frame = CGRectMake(40, 20, 60, 90);
    copyButton.frame = CGRectMake(CGRectGetMaxX(shareButton.frame) + 57.5, 20, 60, 90);
    safariButton.frame = CGRectMake(CGRectGetMaxX(copyButton.frame) + 57.5, 20, 60, 90);
    cancelButton.frame = CGRectMake(0, whiteBG.height - 44, whiteBG.width, 44);
    
    //开始动画
    [UIView animateWithDuration:0.3 animations:^{
        darkBG.alpha = 0.4;
        whiteBG.frame = CGRectMake(0 , window.height - 164, window.width, 164);
    }];
}

#pragma mark - 系统分享
- (void)systemShare
{
    [self cancel];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[_webView.URL] applicationActivities:nil];
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - 复制链接
- (void)copyLink
{
    [self cancel];
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    pastboard.URL = _webView.URL;
    //弹出复制成功提示
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"复制成功" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(dismissAlert:) userInfo:alert repeats:NO];
}

- (void)dismissAlert:(NSTimer *)timer
{
    UIAlertController *alert = timer.userInfo;
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
    [timer invalidate];
    
}

#pragma mark - 在Safari中打开
- (void)openInSafari
{
    [self cancel];
    [[UIApplication sharedApplication] openURL:_webView.URL options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"safari打开成功");
        } else {
            NSLog(@"safari打开失败");
        }
    }];
}

#pragma mark - 关闭选项
- (void)cancel
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [UIView animateWithDuration:0.3 animations:^{
        _darkBG.alpha = 0;
        _whiteBG.frame = CGRectMake(0 , window.height, window.width, 200);
    } completion:^(BOOL finished) {
        [_darkBG removeFromSuperview];
        [_whiteBG removeFromSuperview];
    }];
}

#pragma mark - kvo观测title和estimateProgress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[WKWebView class]]) {
        if ([keyPath isEqualToString:@"title"]) {
            self.title = _webView.title;
        } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
            [_progress setAlpha:1.0f];
            [_progress setProgress:_webView.estimatedProgress animated:YES];
            
            if(_webView.estimatedProgress >= 1.0f) {
                
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [_progress setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [_progress setProgress:0.0f animated:NO];
                }];
                
            }
        }
    }
}

#pragma mark - <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //NSLog(@"%@", _scrollView);
    NSLog(@"%@", _webView);
    NSLog(@"webView.scrollView:%@", _webView.scrollView);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
}

- (void)dealloc
{
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_progress removeFromSuperview];
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
