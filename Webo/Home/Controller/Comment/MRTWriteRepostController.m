//
//  MRTWriteRepostController.m
//  Webo
//
//  Created by mrtanis on 2017/6/20.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTWriteRepostController.h"
#import "MRTTextView.h"
#import "MRTTextToolBar.h"
#import "MRTStatus.h"
#import "MRTPicture.h"
#import "MRTSendRepostOverview.h"
#import "MRTEmotionKeyboard.h"
#import "MRTCommentTool.h"
#import "MBProgressHUD+MRT.h"
#import "NSAttributedString+MRTConvert.h"

#import "MRTTextParam.h"
#import "AFNetworking.h"
#import "MJExtension.h"

@interface MRTWriteRepostController ()<UITextViewDelegate, MRTTextToolBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MRTtextViewDelegate>


@property (nonatomic, weak) MRTTextView *textView;
@property (nonatomic, weak) MRTTextToolBar *toolBar;
@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UIView *rightButtonBG;
@property (nonatomic, weak) UIView *overView;


@property (nonatomic) BOOL emotionKeyboardShow;
@property (nonatomic) BOOL normalKeyboardShow;
@end

@implementation MRTWriteRepostController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigationBar];
    
    [self setUpTextView];
    
    [self setUpToolBar];
    
    [self setUpOverview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

//自动弹出键盘
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}



#pragma mark 设置导航条
- (void)setUpNavigationBar
{
    self.title = @"转发微博";
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionary];
    titleAttrs[NSForegroundColorAttributeName] = [UIColor darkTextColor];
    self.navigationController.navigationBar.titleTextAttributes = titleAttrs;
    
    //左侧按钮
    //自定义取消按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    
    [leftButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    //右侧按钮
    //自定义发送按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightButton addTarget:self action:@selector(sendRepost) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_white_disable"] forState:UIControlStateDisabled];
    [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageWithStretchableName:@"common_button_orange_highlighted"] forState:UIControlStateHighlighted];
    
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [rightButton sizeToFit];
    CGRect rect = rightButton.frame;
    rect.size = CGSizeMake(60, 28);
    rightButton.frame = rect;
    

    _rightButton = rightButton;
    //添加按钮背景（iOS 11直接将uibutton设置为rightButtonItem的customView按钮不能调到最小）
    UIView *rightButtonBG = [[UIView alloc] initWithFrame:rightButton.frame];
    rightButtonBG.backgroundColor = [UIColor clearColor];
    [rightButtonBG addSubview:rightButton];
    _rightButtonBG = rightButtonBG;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonBG];
    
}

#pragma mark 添加textView
- (void)setUpTextView
{
    CGRect rect = self.view.bounds;
    rect.size.height -= 44;//减去工具栏高度
    rect.origin.x = 10;
    rect.size.width = MRTScreen_Width - 20;
    MRTTextView *textView = [[MRTTextView alloc] initWithFrame:rect];
    textView.delegate_mrt = self;
    textView.repostFlag = YES;
    
    //将导航栏右侧发送按钮赋值给textView的rightItem属性
    //textView.rightItem = self.navigationItem.rightBarButtonItem;
    
    
    
    //如果是转发，则添加转发文字
    if (_statusFrame.status.retweeted_status) {
        NSString *prefix = [NSString stringWithFormat:@"//@%@:", _statusFrame.status.user.name];
        NSString *repostStr = _statusFrame.status.text;
        if (_commentFrame) {
            prefix = [NSString stringWithFormat:@"//@%@:", _commentFrame.comment.user.name];
            repostStr = _commentFrame.comment.text;
        }
        repostStr = [prefix stringByAppendingString:repostStr];
        
        textView.text = repostStr;
        
        //textView.rightItem.enabled = YES;
    } 
        
    //设置光标位置到文本最前面
    textView.selectedRange = NSMakeRange(0, 0);
    
    //设置占位符
    textView.placeHolderStr = @"说说分享心得...";
    
    //设置垂直方向bounce，以便拖动隐藏键盘
    textView.alwaysBounceVertical = YES;
    textView.bounces = YES;
    textView.showsVerticalScrollIndicator = NO;
    
    //设置自身为textView的代理，监听滚动
    textView.delegate = self;
    
    [self.view addSubview:textView];
    
    _textView = textView;
}

#pragma mark 设置工具栏
- (void)setUpToolBar
{
    CGFloat width = self.view.width;
    CGFloat height = 44;
    CGFloat x = 0;
    CGFloat y = self.view.height - height;
    
    MRTTextToolBar *toolBar = [[MRTTextToolBar alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [toolBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"compose_toolbar_background_new"]]];
    
    //设置图片按钮不可用，非会员不能发送图片
    UIButton *photoButton = [toolBar.subviews firstObject];
    photoButton.enabled = NO;
    
    toolBar.delegate = self;
    [self.view addSubview:toolBar];
    _toolBar = toolBar;
}

#pragma mark 添加overview
- (void)setUpOverview
{
    MRTSendRepostOverview *overview = [[MRTSendRepostOverview alloc] initWithFrame:CGRectMake(0, 130, MRTScreen_Width - 20, 80)];
    overview.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:0.96];
    
    MRTStatus *status = [[MRTStatus alloc] init];
    if (self.statusFrame.status.retweeted_status) {
        status = self.statusFrame.status.retweeted_status;
    } else {
        status = self.statusFrame.status;
    }
    
    MRTURL_object *url_object = [status.url_objects firstObject];
    if (url_object.object.object.image) {
        
        MRTImage *image = url_object.object.object.image;
        
        
        [overview setImageWithUrl:[NSURL URLWithString:image.url]];
    } else if (status.thumbnail_pic) {
        NSString *midlle = [status.thumbnail_pic stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        [overview setImageWithUrl:[NSURL URLWithString:midlle]];
    } else {
        NSLog(@"头像url：%@", status.user.avatar_large);
        [overview setImageWithUrl:status.user.avatar_large];
    }
  
        
    //设置昵称
    overview.name = status.user.name;
    //设置正文
    overview.text = status.text;
    
    
    self.textView.overview = overview;
    
    [self.textView addSubview:overview];
    _overView = overview;
}

#pragma mark 给commentFrame赋值时设置statusFrame
- (void)setCommentFrame:(MRTCommentFrame *)commentFrame
{
    _commentFrame = commentFrame;
    
    MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
    statusFrame.status = commentFrame.comment.status;
    
    _statusFrame = statusFrame;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRectEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //捕获键盘动画时间是关键，使上移textView和弹出键盘动画同步
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.origin.y = keyboardRectEnd.origin.y - toolBarFrame.size.height;
        _toolBar.frame = toolBarFrame;
        
        
        
    }];
    if (keyboardRectEnd.origin.y != MRTScreen_Height) {
        self.textView.frame = CGRectMake(self.textView.x, self.textView.y, self.textView.width, self.view.height - 44 - keyboardRectEnd.size.height);
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    } else {
        self.textView.frame = CGRectMake(self.textView.x, self.textView.y, self.textView.width, self.view.height - 44);
        
        if (_overView.y + _overView.height <= _textView.height - 64) {
            _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
            
        } else {
            _textView.contentInset = UIEdgeInsetsMake(0, 0, _overView.height + 60, 0);
        }
    }
}

#pragma mark - textView委托方法
- (void)textChanged
{
    [self textViewDidChange:_textView];
}

#pragma mark textView发生改变时执行该代理方法
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat photoY;
    if ([_textView hasText]) {
        if (_textView.contentSize.height > 130 - 30) {
            photoY = _textView.contentSize.height + 30;
        } else {
            photoY = 130;
        }
    } else {
        photoY = 130;
    }
    
    _overView.frame = CGRectMake(0, photoY, MRTScreen_Width - 20, 80);
    
}


//关闭视图控制器
- (void)dismissSelf
{
    //先关闭键盘避免造成视图控制器关闭后键盘才消失
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}






#pragma mark 转发微博
- (void)sendRepost
{
    NSString *plainText = [self.textView.attributedText getPlainEmoString];
    NSString *text = self.textView.attributedText.length ? plainText : @"转发微博";
    NSString *idStr = @"";
    if (self.statusFrame.status.retweeted_status) {
        idStr = self.statusFrame.status.retweeted_status.idstr;
    } else {
        idStr = self.statusFrame.status.idstr;
    }
    //发送文字
    [MRTCommentTool sendRepostWithText:text ID:idStr is_comment:0 success:^{
        //提示成功
        [MBProgressHUD showSuccess:@"发送成功"];
        
        //回到首页
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"发送成功");
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"发送失败"];
        NSLog(@"error:%@", error);
    }];
}

#pragma mark 当textView开始拖动时执行该代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark 执行点击工具栏按钮的代理方法
- (void)textToolBar:(MRTTextToolBar *)toolBar didClickButton:(NSInteger)index
{
    
    if (index == 3) {
        MRTEmotionKeyboard *emotionKeyboard = [[MRTEmotionKeyboard alloc] init];
        emotionKeyboard.textView = _textView;
        _emotionKeyboardShow = YES;
        _textView.inputView = emotionKeyboard;
        [_textView reloadInputViews];
        [_textView becomeFirstResponder];
    }
    if (index == 4) {
        _normalKeyboardShow = YES;
        _textView.inputView = nil;
        [_textView reloadInputViews];
        [_textView becomeFirstResponder];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
