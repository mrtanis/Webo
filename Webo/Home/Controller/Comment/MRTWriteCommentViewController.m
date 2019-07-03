//
//  MRTWriteCommentViewController.m
//  Webo
//
//  Created by mrtanis on 2017/6/17.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTWriteCommentViewController.h"
#import "MRTTextView.h"
#import "MRTTextToolBar.h"
#import "MRTEmotionKeyboard.h"
#import "MRTCommentTool.h"
#import "MBProgressHUD+MRT.h"
#import "NSAttributedString+MRTConvert.h"

#import "MRTTextParam.h"
#import "AFNetworking.h"
#import "MJExtension.h"

@interface MRTWriteCommentViewController ()<UITextViewDelegate, MRTTextToolBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MRTtextViewDelegate>


@property (nonatomic, weak) MRTTextView *textView;
@property (nonatomic, weak) MRTTextToolBar *toolBar;

@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UIView *rightButtonBG;

@property (nonatomic) BOOL emotionKeyboardShow;
@property (nonatomic) BOOL normalKeyboardShow;
@end

@implementation MRTWriteCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigationBar];
    
    [self setUpTextView];
    
    [self setUpToolBar];
    
    
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
    if (_replyToComment) {
        self.title = @"回复评论";
    } else {
        self.title = @"发评论";
    }
    
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
    
    [rightButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    //未选择照片或输入文字时不可点击
    rightButton.enabled = NO;
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
    textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    textView.repostFlag = NO;
    
    //将导航栏右侧发送按钮赋值给textView的rightItem属性
    //textView.rightItem = self.navigationItem.rightBarButtonItem;
    
    //设置占位符
    textView.placeHolderStr = @"写评论...";
    
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
    } else {
        self.textView.frame = CGRectMake(self.textView.x, self.textView.y, self.textView.width, self.view.height - 44);
    }
}

#pragma mark - textView委托方法
- (void)textChanged
{
    NSLog(@"textChanged!!!");
    [self textViewDidChange:_textView];
}

#pragma mark textView发生改变时执行该代理方法
- (void)textViewDidChange:(UITextView *)textView
{
    [self setRightButtonStatus];
}

#pragma mark - 设置发送按钮状态
- (void)setRightButtonStatus
{
    if ([_textView hasText]) {
        NSLog(@"发送按钮可用");
        _rightButton.enabled = YES;
    } else {
        NSLog(@"发送按钮不可用");
        _rightButton.enabled = NO;
    }
}

//关闭视图控制器
- (void)dismissSelf
{
    //先关闭键盘避免造成视图控制器关闭后键盘才消失
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 发送评论
- (void)sendComment
{
    NSString *plainText = [self.textView.attributedText getPlainEmoString];
    if (_replyToComment) {
        [MRTCommentTool replyCommentWithText:plainText ID:self.commentFrame.comment.status.idstr CID:self.commentFrame.comment.idstr success:^{
            //提示成功
            [MBProgressHUD showSuccess:@"发送成功"];
            
            //回到首页
            [self dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"发送成功");
        } failure:^(NSError *error) {
            [MBProgressHUD showError:@"发送失败"];
            NSLog(@"error:%@", error);
        }];
    } else {
        //发送文字
        [MRTCommentTool sendCommentWithText:plainText ID:self.statusFrame.status.idstr success:^{
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


 -(void)dealloc
 {
 [[NSNotificationCenter defaultCenter] removeObserver:self];
 }

@end
