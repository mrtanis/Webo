//
//  MRTLogInViewController.m
//  Webo
//
//  Created by mrtanis on 2017/5/6.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTLogInViewController.h"
//#import "AFHTTPRequestOperationManager.h"
#import "AFNetworking.h"
//#import "JSONKit.h"

@interface MRTLogInViewController () <UIWebViewDelegate>

@end

@implementation MRTLogInViewController

- (void)loadView {
    self.navigationItem.title = @"微博登录";
    self.navigationController.toolbarHidden = YES;
    
    UIWebView *logInView = [[UIWebView alloc] init];
    logInView.opaque = NO;
    logInView.backgroundColor = [UIColor clearColor];
    logInView.delegate = self;
    logInView.scalesPageToFit = YES;
    
    NSString *OAuthURL = @"https://api.weibo.com/oauth2/authorize?client_id=1316088724&response_type=code&redirect_uri=https://api.weibo.com/oauth2/default.html";
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:OAuthURL]];
    [logInView loadRequest:request];
    
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

//获得code并换取access_token都在这个回调函数内操作。
-(void) webViewDidFinishLoad:(UIWebView *)webView{
    /*
     NSString *url = webView.request.URL.absoluteString;
     NSLog(@"%@",url);
     if ([url hasPrefix:@"https://api.weibo.com/oauth2/default.html?"]) {
     
     
     //获得code
     NSString *code = [url substringFromIndex:47];
     
     NSString *urlTmp = @"https://api.weibo.com/oauth2/access_token?client_id=3151711642&client_secret=a9132449b749ca0324e7acbcae7523418&grant_type=authorization_code&redirect_uri=https://api.weibo.com/oauth2/default.html&code=";
     NSString *getTokenUrlString = [urlTmp stringByAppendingString:code];
     
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     manager.responseSerializer = [[AFJSONResponseSerializer alloc]init];
     //http请求头应该添加text/plain。接受类型内容无text/plain，若请求错误时提示无text/html同样加入text/html即可
     manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
     NSDictionary *dict = @{@"format": @"json"};
     
     [manager POST:getTokenUrlString parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
     NSDictionary *dict;
     NSLog(@"%@",responseObject);
     dict = responseObject;
     self.access_token = dict[@"access_token"];
     NSString *expires_in = dict[@"expires_in"];
     
     NSDictionary *token = [[NSDictionary alloc]init];
     token = @{@"token":self.access_token,@"expires_in":expires_in};
     //使用NotificationCenter通知中心将access_token的内容传递到其他类中。
     [[NSNotificationCenter defaultCenter]postNotificationName:@"loginStateChange" object:@YES userInfo:token];
     }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
     NSLog(@"server error.%@",error);
     }];
     
     
     }
     */
}
-(void) webViewDidStartLoad:(UIWebView *)webView{
    // [activityIndicatorView startAnimating];
    
}


@end
