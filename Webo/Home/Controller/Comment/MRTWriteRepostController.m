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
#import "MRTCommentTool.h"
#import "MBProgressHUD+MRT.h"

#import "MRTTextParam.h"
#import "AFNetworking.h"
#import "MJExtension.h"

@interface MRTWriteRepostController ()<UITextViewDelegate, MRTTextToolBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (nonatomic, weak) MRTTextView *textView;
@property (nonatomic) CGFloat viewMoveDistance;
@property (nonatomic, weak) MRTTextToolBar *toolBar;
@property (nonatomic) CGFloat keyboardHeight;

@end

@implementation MRTWriteRepostController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigationBar];
    
    [self setUpTextView];
    
    [self setUpToolBar];
    
    [self setUpOverview];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextViewFrame:) name:UIKeyboardWillShowNotification object:nil];//使用第三方键盘是此方法会调用三次
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTextViewFrame:) name:UIKeyboardWillHideNotification object:nil];
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
    rect.size = CGSizeMake(50, 30);
    rightButton.frame = rect;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
}

#pragma mark 添加textView
- (void)setUpTextView
{
    CGRect rect = self.view.bounds;
    rect.size.height -= 44;//减去工具栏高度
    MRTTextView *textView = [[MRTTextView alloc] initWithFrame:rect];
    
    textView.repostFlag = YES;
    
    //将导航栏右侧发送按钮赋值给textView的rightItem属性
    textView.rightItem = self.navigationItem.rightBarButtonItem;
    
    
    
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
        
        textView.rightItem.enabled = YES;
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
    MRTSendRepostOverview *overview = [[MRTSendRepostOverview alloc] initWithFrame:CGRectMake(10, 130, MRTScreen_Width - 20, 80)];
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
}

#pragma mark 给commentFrame赋值时设置statusFrame
- (void)setCommentFrame:(MRTCommentFrame *)commentFrame
{
    _commentFrame = commentFrame;
    
    MRTStatusFrame *statusFrame = [[MRTStatusFrame alloc] init];
    statusFrame.status = commentFrame.comment.status;
    
    _statusFrame = statusFrame;
}

#pragma mark textView发生改变时执行该代理方法
- (void)textViewDidChange:(UITextView *)textView
{
    /*
     //如果键盘已弹出且textView未被上移过
     if (_toolBar.y + _toolBar.height != MRTScreen_Height && textView.y + textView.height == MRTScreen_Height) {
     
     //获取光标位置
     CGPoint cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.end].origin;
     //转换为相对window的位置
     CGPoint point = [textView convertPoint:cursorPosition toView:self.view];
     //获取当前textView的frame
     CGRect textViewFrame = textView.frame;
     //如果光标被键盘遮挡，则上移textView
     if (_toolBar.y < point.y) {
     self.viewMoveDistance = (point.y - _toolBar.y) + 40;//行高为20，40为两行
     textViewFrame.origin.y = textViewFrame.origin.y - self.viewMoveDistance;
     textView.frame = textViewFrame;
     }
     }*/
    
}


//关闭视图控制器
- (void)dismissSelf
{
    //先关闭键盘避免造成视图控制器关闭后键盘才消失
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark 键盘弹出时执行此方法
- (void)changeTextViewFrame:(NSNotification *)notification
{
    
    NSDictionary *userInfo = notification.userInfo;
    
    //捕获键盘动画时间是关键，使上移textView和弹出键盘动画同步
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        //获取键盘frame
        CGRect keyboardRectBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardRectEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSLog(@"keyboardRectBegin(%f,%f,%f,%f)", keyboardRectBegin.origin.x,keyboardRectBegin.origin.y,keyboardRectBegin.size.width,keyboardRectBegin.size.height);
        NSLog(@"keyboardRectEnd(%f,%f,%f,%f)", keyboardRectEnd.origin.x,keyboardRectEnd.origin.y,keyboardRectEnd.size.width,keyboardRectEnd.size.height);
        //保存键盘高度
        self.keyboardHeight = keyboardRectEnd.size.height;
        
        //首先工具栏上移
        //首先判断工具栏是否处于未被上移的状态，因为从后台打开软件该方法还会被调用三次，
        //如果不做判断，则工具栏在已经上移的状态下还会被上移
        if (self.toolBar.y + self.toolBar.height == MRTScreen_Height)
        {
            //然后判断是不是第三次调用本方法，因为第三方键盘会调用三次本方法，只有最后一次键盘frame才是准确
            if (keyboardRectBegin.size.height > 0 && (keyboardRectBegin.origin.y > keyboardRectEnd.origin.y) && (keyboardRectBegin.size.height < keyboardRectEnd.size.height)) {
                CGRect toolBarFrame = self.toolBar.frame;
                toolBarFrame.origin.y -= self.keyboardHeight;
                self.toolBar.frame = toolBarFrame;
            }
        }
        
        //接下来处理textView上移
        //获取光标位置
        CGPoint cursorPosition = [self.textView caretRectForPosition:self.textView.selectedTextRange.end].origin;
        //转换为相对window的位置
        CGPoint point = [self.textView convertPoint:cursorPosition toView:self.view];
        //获取当前textView的frame
        CGRect textViewFrame = self.textView.frame;
        //如果光标被键盘遮挡，则上移textView
        if (keyboardRectEnd.origin.y - 44 < point.y) {
            self.viewMoveDistance = (point.y - keyboardRectEnd.origin.y) + 40 + 44;//行高为20，40为两行,44为工具栏高度
            textViewFrame.origin.y = textViewFrame.origin.y - self.viewMoveDistance;
            self.textView.frame = textViewFrame;
        }
    }];
}

#pragma mark 键盘关闭时恢复textView的frame
- (void)resumeTextViewFrame:(NSNotification *)notification
{
    //如果工具栏被上移过则恢复
    if (self.toolBar.y + self.toolBar.height != MRTScreen_Height) {
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.origin.y += self.keyboardHeight;
        self.toolBar.frame = toolBarFrame;
    }
    
    //如果textView被上移过则恢复
    if (_textView.y != 0) {
        NSDictionary *userInfo = notification.userInfo;
        
        [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
            CGRect textViewFrame = self.textView.frame;
            textViewFrame.origin.y = 0;
            //textViewFrame.origin.y = textViewFrame.origin.y + self.viewMoveDistance;
            self.textView.frame = textViewFrame;
        }];
    }
}


#pragma mark 转发微博
- (void)sendRepost
{
    NSString *text = self.textView.text.length > 0 ? self.textView.text : @"转发微博";
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
