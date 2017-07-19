//
//  MRTTextViewController.m
//  Webo
//
//  Created by mrtanis on 2017/6/9.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTTextViewController.h"
#import "MRTTextView.h"
#import "MRTTextToolBar.h"
#import "MRTTextTool.h"
#import "MBProgressHUD+MRT.h"
#import "MRTTextAddPhotos.h"
#import "MRTTextParam.h"
#import "AFNetworking.h"
#import "MJExtension.h"

@interface MRTTextViewController ()<UITextViewDelegate, MRTTextToolBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) MRTTextView *textView;
@property (nonatomic) CGFloat viewMoveDistance;
@property (nonatomic) BOOL viewDidMoved;
@property (nonatomic, weak) MRTTextToolBar *toolBar;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic, weak) MRTTextAddPhotos *photosView;
@property (nonatomic, copy) NSMutableArray *photos;

@end

@implementation MRTTextViewController

//懒加载photos数组
- (NSMutableArray *)photos
{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    
    return _photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigationBar];
    
    [self setUpTextView];
    
    [self setUpToolBar];
    
    
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
    self.title = @"发微博";
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
    
    [rightButton addTarget:self action:@selector(sendWebo) forControlEvents:UIControlEventTouchUpInside];
    
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
    //未输入文字时不可点击
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark 添加textView
- (void)setUpTextView
{
    CGRect rect = self.view.bounds;
    rect.size.height -= 44;//减去工具栏高度
    MRTTextView *textView = [[MRTTextView alloc] initWithFrame:rect];
    
    textView.repostFlag = NO;
    
    //将导航栏右侧发送按钮赋值给textView的rightItem属性
    textView.rightItem = self.navigationItem.rightBarButtonItem;
    
    //设置占位符
    textView.placeHolderStr = @"分享新鲜事...";
    
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
    
    toolBar.delegate = self;
    [self.view addSubview:toolBar];
    _toolBar = toolBar;
}

#pragma mark 设置添加图片界面
- (void)setUpPhotos
{
    CGFloat photoY;
    if (_textView.contentSize.height > 100 + 30) {
        photoY = _textView.contentSize.height + 30;
    } else {
        photoY = 100;
    }
    
    MRTTextAddPhotos *photosView = [[MRTTextAddPhotos alloc] initWithFrame:CGRectMake(10, photoY, MRTScreen_Width - 20, MRTScreen_Width - 20)];
    
    photosView.backgroundColor = [UIColor clearColor];
    [self.textView addSubview:photosView];
    self.textView.overview = photosView;
    _photosView = photosView;
}

#pragma mark 当textView开始拖动时执行该代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
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
            self.viewMoveDistance = (point.y - keyboardRectEnd.origin.y) + 40 + 44;//行高为20，40为两行，44为工具栏高度
            textViewFrame.origin.y = textViewFrame.origin.y - self.viewMoveDistance;
            self.textView.frame = textViewFrame;
            _viewDidMoved = YES;
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
            _viewDidMoved = NO;
        }];
    }
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


#pragma mark 发送微博
- (void)sendWebo
{
    //先判断有没有图片
    if (self.photos.count) {
        //发送图片
        [self sendPhoto];
    } else {
        //发送文字
        [self sendText];
    }
}

- (void)sendPhoto
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    UIImage *image = self.photos[0];
    //没有输入文字则显示分享图片，微博不支持只发布图片
    NSString *status = self.textView.text.length ? self.textView.text : @"分享图片";
    
    [MRTTextTool weboWithStatus:status image:image success:^{
        [MBProgressHUD showSuccess:@"发送图片成功"];
        [self dismissViewControllerAnimated:YES completion:nil];
        self.navigationItem.rightBarButtonItem.enabled = YES;

    } failure:^(NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (void)sendText
{
    //发送文字
    [MRTTextTool weboWithStatus:self.textView.text success:^{
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

#pragma mark 执行点击工具栏按钮的代理方法
- (void)textToolBar:(MRTTextToolBar *)toolBar didClickButton:(NSInteger)index
{
    if (index == 0) {
        //弹出系统相册
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark 完成选择图片时的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@", info);
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //创建配图视图
    [self setUpPhotos];
    
    //传递图片
    self.photosView.image = image;
    //保存图片到数组
    [self.photos addObject:image];
    
    //返回首页
    [self dismissViewControllerAnimated:YES completion:nil];
    //设置发送按钮可点击
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
