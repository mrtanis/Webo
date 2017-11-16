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
#import "MRTEmotionKeyboard.h"
#import "NSAttributedString+MRTConvert.h"
#import "MRTImagePickerController.h"
#import "MRTNavigationController.h"
#import "MRTPhotoView.h"
#import <Photos/Photos.h>

@interface MRTTextViewController ()<UITextViewDelegate, MRTtextViewDelegate, MRTTextToolBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MRTPhotoViewDelegate, MRTImagePickerDelegate>

@property (nonatomic, weak) MRTTextView *textView;
@property (nonatomic) CGFloat viewMoveDistance;
@property (nonatomic) BOOL viewDidMoved;
@property (nonatomic, weak) MRTTextToolBar *toolBar;
@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UIView *rightButtonBG;


@property (nonatomic, copy) NSMutableArray *photos;
@property (nonatomic, copy) NSMutableArray *photoViews;



//键盘状态
//@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) BOOL emotionKeyboardShow;
@property (nonatomic) BOOL normalKeyboardShow;



@end

@implementation MRTTextViewController
@synthesize photoAssets = _photoAssets;

//懒加载photos数组
- (NSMutableArray *)photos
{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    
    return _photos;
}

- (NSMutableArray *)photoViews
{
    if (!_photoViews) {
        _photoViews = [NSMutableArray array];
    }
    
    return _photoViews;
}

- (NSMutableArray *)photoAssets
{
    if (!_photoAssets) {
        _photoAssets = [NSMutableArray array];
    }
    
    return _photoAssets;
}

- (void)setPhotoAssets:(NSMutableArray *)photoAssets
{
    _photoAssets = [[NSMutableArray alloc] initWithArray:photoAssets];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigationBar];
    
    [self setUpTextView];
    
    [self setUpToolBar];
    
    if (_shouldSetUpPhotoView && self.photoAssets.count) {
        [self setUpPhotos];
    }
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextViewFrame:) name:UIKeyboardWillShowNotification object:nil];//使用第三方键盘是此方法会调用三次
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTextViewFrame:) name:UIKeyboardWillHideNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
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
    textView.delegate = self;
    textView.delegate_mrt = self;
    
    textView.repostFlag = NO;
    
    //将导航栏右侧发送按钮赋值给textView的rightItem属性
    //textView.rightItem = self.navigationItem.rightBarButtonItem;
    
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
    _shouldSetUpPhotoView = NO;
    NSLog(@"setUpPhotos");
    CGFloat photoY;
    if ([_textView hasText]) {
        if (_textView.contentSize.height > 100 - 30) {
            photoY = _textView.contentSize.height + 30;
        } else {
            photoY = 100;
        }
    } else {
        photoY = 100;
    }
    
    
    PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];
    options.resizeMode=PHImageRequestOptionsResizeModeExact;
    //options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = YES;   //YES 一定是同步    NO不一定是异步
    __weak typeof (self) weakSelf = self;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake((MRTScreen_Width - 20 - 5 * 2) / 3.0 * scale, (MRTScreen_Width - 20 - 5 * 2) / 3.0 * scale);
    
    [self.photoViews removeAllObjects];
    NSLog(@"self.photoAssets.count:%ld", self.photoAssets.count);
    for (int i = 0; i < self.photoAssets.count; i++) {
        
        [[PHImageManager defaultManager] requestImageForAsset:self.photoAssets[i] targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof (weakSelf) strongSelf = weakSelf;
                
                MRTPhotoView *imageView = [[MRTPhotoView alloc] init];
                imageView.image = result;
                imageView.delegate = strongSelf;
                imageView.tag = i;
                [strongSelf.textView addSubview:imageView];
                [strongSelf.photoViews addObject:imageView];
                if (i == strongSelf.photoAssets.count - 1) {
                    if (strongSelf.photoAssets.count < 9) {
                        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [addButton setBackgroundImage:[UIImage imageNamed:@"compose_pic_add"] forState:UIControlStateNormal];
                        [addButton setBackgroundImage:[UIImage imageNamed:@"compose_pic_add_highlighted"] forState:UIControlStateHighlighted];
                        [addButton addTarget:strongSelf action:@selector(clickAddButton:) forControlEvents:UIControlEventTouchUpInside];
                        addButton.contentMode = UIViewContentModeScaleAspectFill;
                        [strongSelf.textView addSubview:addButton];
                        [strongSelf.photoViews addObject:addButton];
                    }
                    int cols = 3;
                    int col = 0;
                    int row = 0;
                    CGFloat margin = 5;
                    CGFloat x = 0;
                    CGFloat y = 0;
                    CGFloat width_Height = (MRTScreen_Width - margin * (cols - 1) - 20) / cols;
                    for (int m = 0; m < strongSelf.photoViews.count; m++) {
                        col = m % cols;
                        row = m / cols;
                        x = (margin + width_Height) * col;
                        y = (margin + width_Height) * row + photoY;
                        CGRect rect = CGRectMake(x, y, width_Height, width_Height);
                        UIView *imageView = strongSelf.photoViews[m];
                        imageView.frame = rect;
                    }
                    UIView *lastPhoto = [strongSelf.photoViews lastObject];
                    if (lastPhoto.y + lastPhoto.height <= _textView.height - 64) {
                        _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
                    } else {
                        UIView *firstPhoto = [strongSelf.photoViews firstObject];
                        _textView.contentInset = UIEdgeInsetsMake(0, 0, lastPhoto.y - firstPhoto.y + lastPhoto.height + 60, 0);
                    }
                    [strongSelf setRightButtonStatus];
                }
                
            });
        }];
    }
    

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
/*
#pragma mark 键盘将要弹出时执行此方法
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
            //如果是表情键盘
            if (_emotionKeyboardShow) {
                CGRect toolBarFrame = self.toolBar.frame;
                toolBarFrame.origin.y -= self.keyboardHeight;
                self.toolBar.frame = toolBarFrame;
            } else {//普通键盘
                //判断是不是第三次调用本方法，因为第三方键盘会调用三次本方法，只有最后一次键盘frame才是准确
                if (keyboardRectBegin.size.height > 0 && (keyboardRectBegin.origin.y > keyboardRectEnd.origin.y) && (keyboardRectBegin.size.height < keyboardRectEnd.size.height)) {
                    CGRect toolBarFrame = self.toolBar.frame;
                    toolBarFrame.origin.y -= self.keyboardHeight;
                    self.toolBar.frame = toolBarFrame;
                }
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

#pragma mark 键盘已经弹出时执行此方法
- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRectEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (keyboardRectEnd.origin.y + keyboardRectEnd.size.height == MRTScreen_Height) {
        if (keyboardRectEnd.size.height == 220) {
            _emotionKeyboardShow = YES;
            _normalKeyboardShow = NO;
        } else {
            _emotionKeyboardShow = NO;
            _normalKeyboardShow = YES;
        }
    }
}

#pragma mark 键盘将要关闭时恢复textView的frame
- (void)resumeTextViewFrame:(NSNotification *)notification
{
    //如果工具栏被上移过则恢复
    if (self.toolBar.y + self.toolBar.height != MRTScreen_Height) {
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.origin.y = MRTScreen_Height - toolBarFrame.size.height;
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

#pragma mark 键盘已经关闭时执行此方法
- (void)keyboardDidHide:(NSNotification *)notification
{
    _emotionKeyboardShow = NO;
    _normalKeyboardShow = NO;
}
*/

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRectEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //捕获键盘动画时间是关键，使上移textView和弹出键盘动画同步
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        //获取键盘frame
        //CGRect keyboardRectBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        //NSLog(@"keyboardRectBegin(%f,%f,%f,%f)", keyboardRectBegin.origin.x,keyboardRectBegin.origin.y,keyboardRectBegin.size.width,keyboardRectBegin.size.height);
        //NSLog(@"keyboardRectEnd(%f,%f,%f,%f)", keyboardRectEnd.origin.x,keyboardRectEnd.origin.y,keyboardRectEnd.size.width,keyboardRectEnd.size.height);
        //保存键盘高度
        //self.keyboardHeight = keyboardRectEnd.size.height;
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.origin.y = keyboardRectEnd.origin.y - toolBarFrame.size.height;
        _toolBar.frame = toolBarFrame;
        
        
        
    }];
    if (keyboardRectEnd.origin.y != MRTScreen_Height) {
        self.textView.frame = CGRectMake(self.textView.x, self.textView.y, self.textView.width, self.view.height - 44 - keyboardRectEnd.size.height);
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    } else {
        self.textView.frame = CGRectMake(self.textView.x, self.textView.y, self.textView.width, self.view.height - 44);
        
        if (self.photoViews.count == 0) {
            _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
            return;
        }
        UIView *lastPhoto = [self.photoViews lastObject];
        if (lastPhoto.y + lastPhoto.height <= _textView.height - 64) {
            _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);

        } else {
            UIView *firstPhoto = [self.photoViews firstObject];
            _textView.contentInset = UIEdgeInsetsMake(0, 0, lastPhoto.y - firstPhoto.y + lastPhoto.height + 60, 0);
        }
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
    if (self.photoViews.count == 0) return;
    
    CGFloat photoY;
    if ([_textView hasText]) {
        if (_textView.contentSize.height > 100 - 30) {
            photoY = _textView.contentSize.height + 30;
        } else {
            photoY = 100;
        }
    } else {
        photoY = 100;
    }
    int cols = 3;
    int col = 0;
    int row = 0;
    CGFloat margin = 5;
    CGFloat x = 0;
    CGFloat y = photoY;
    CGFloat width_Height = (MRTScreen_Width - margin * (cols - 1) - 20) / cols;
    for (int m = 0; m < self.photoViews.count; m++) {
        col = m % cols;
        row = m / cols;
        x = (margin + width_Height) * col;
        y = (margin + width_Height) * row + photoY;
        CGRect rect = CGRectMake(x, y, width_Height, width_Height);
        UIView *imageView = self.photoViews[m];
        imageView.frame = rect;
    }
    
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

#pragma mark - 设置发送按钮状态
- (void)setRightButtonStatus
{
    if ([_textView hasText] || self.photoViews.count) {
        NSLog(@"发送按钮可用");
        _rightButton.enabled = YES;
    } else {
        NSLog(@"发送按钮不可用");
        _rightButton.enabled = NO;
    }
}

#pragma mark 发送微博
- (void)sendWebo
{
    //先判断有没有图片
    if (self.photoViews.count) {
        //发送图片
        NSLog(@"发送图片微博");
        [self sendPhoto];
    } else {
        //发送文字
        NSLog(@"发送文字微博");
        [self sendText];
    }
}

- (void)sendPhoto
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    for (int i = 0; i < self.photoViews.count; i++) {
        if ([self.photoViews[i] isKindOfClass:[MRTPhotoView class]]) {
            MRTPhotoView *photoView = self.photoViews[i];
            NSData *imageData = nil;
            if (_originalMode) {
                imageData = UIImageJPEGRepresentation(photoView.image, 1);
            } else {
                imageData = UIImageJPEGRepresentation(photoView.image, 0.5);
            }
            
            [self.photos addObject:imageData];
        }
    }
    //没有输入文字则显示分享图片，微博不支持只发布图片
    NSString *plainText = [self.textView.attributedText getPlainEmoString];
    NSString *status = self.textView.attributedText.length ? plainText : @"分享图片";
    
    [MRTTextTool weboWithStatus:status imageData:self.photos success:^{
        [MBProgressHUD showSuccess:@"发送图片成功"];
        [self dismissViewControllerAnimated:YES completion:nil];
        self.navigationItem.rightBarButtonItem.enabled = YES;

    } failure:^(NSError *error) {
        NSLog(@"发送微博失败:%@", error);
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (void)sendText
{
    NSString *plainText = [self.textView.attributedText getPlainEmoString];
    
    //发送文字
    [MRTTextTool weboWithStatus:plainText success:^{
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
        [self showImagePicker];
        
        /*
        //弹出系统相册
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
         */
    }
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

#pragma mark - 点击添加图片按钮
- (void)clickAddButton:(UIButton *)button
{
    [self showImagePicker];
}

#pragma mark - 弹出相片多选界面
- (void)showImagePicker
{
    for (MRTPhotoView *photoView in self.photoViews) {
        [photoView removeFromSuperview];
    }
    MRTImagePickerController *imagePicker = [[MRTImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.photosBlock = ^(NSMutableArray *array, BOOL originalMode) {
        self.photoAssets = array;
        self.originalMode = originalMode;
        [self setUpPhotos];
    };
    imagePicker.originalMode = _originalMode;//传递是否之前选择了原图模式
    if (self.photoAssets.count) {
        //NSLog(@"imagePicker.selectedAssets:%@", imagePicker.selectedAssets);
        imagePicker.selectedAssets = self.photoAssets;
        
    }
    MRTNavigationController *nav = [[MRTNavigationController alloc] initWithRootViewController:imagePicker];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 弹出拍照界面
- (void)shouldPresentCameraVC
{
    UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
    
    //判断摄像头是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    pickerVC.delegate = self;
    
    [self presentViewController:pickerVC animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //__block PHAsset *assetOfImage;
    typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            typeof(weakSelf) strongSelf = weakSelf;
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    //写入图片到相册
                    PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    NSLog(@"success = %d, error = %@", success, error);
                    
                    
                    //先获取相机胶卷
                    //PHFetchResult *collectionsResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[@"相机胶卷"] options:nil];
                    //PHAssetCollection *assetCollection = [collectionsResult firstObject];
                    //按日期降序排列并过滤掉非照片类型
                    PHFetchOptions *fetchAssetOption = [[PHFetchOptions alloc] init];
                    fetchAssetOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];//按照日期降序排序
                    //fetchAssetOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];//过滤剩下照片类型
                    PHFetchResult *assetsResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchAssetOption];
                    PHAsset *asset = [assetsResult firstObject];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [picker dismissViewControllerAnimated:NO completion:^{
                            if (strongSelf.photoAssets.count < 9) {
                                [strongSelf.photoAssets addObject:asset];
                            } else {
                                [strongSelf.photoAssets replaceObjectAtIndex:8 withObject:asset];
                            }
                            [strongSelf setUpPhotos];
                        }];
                    });
                }];
            }
        }];
    });
}

#pragma mark - 删除选择的图片
- (void)deselectPhoto:(MRTPhotoView *)photoView
{
    [photoView removeFromSuperview];
    NSInteger index = [self.photoViews indexOfObject:photoView];
    [self.photoViews removeObject:photoView];
    [self.photoAssets removeObjectAtIndex:index];
    
    
    if ([[self.photoViews lastObject] isKindOfClass:[UIButton class]]) {
        if (self.photoViews.count == 1) {
            UIView *addButton = [self.photoViews lastObject];
            [addButton removeFromSuperview];
            [self.photoViews removeLastObject];
            _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
            [self setRightButtonStatus];
        }
    } else {
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setBackgroundImage:[UIImage imageNamed:@"compose_pic_add"] forState:UIControlStateNormal];
        [addButton setBackgroundImage:[UIImage imageNamed:@"compose_pic_add_highlighted"] forState:UIControlStateHighlighted];
        [addButton addTarget:self action:@selector(clickAddButton:) forControlEvents:UIControlEventTouchUpInside];
        UIView *last = [self.photoViews lastObject];
        addButton.frame = CGRectMake(MRTScreen_Width, last.y, last.width, last.height);
        [self.textView addSubview:addButton];
        [self.photoViews addObject:addButton];
    }
    
    CGFloat photoY;
    if ([_textView hasText]) {
        if (_textView.contentSize.height > 100 - 30) {
            photoY = _textView.contentSize.height + 30;
        } else {
            photoY = 100;
        }
    } else {
        photoY = 100;
    }
    int cols = 3;
    __block int col = 0;
    __block int row = 0;
    CGFloat margin = 5;
    __block CGFloat x = 0;
    __block CGFloat y = photoY;
    CGFloat width_Height = (MRTScreen_Width - margin * (cols - 1) - 20) / cols;
    [UIView animateWithDuration:0.2 animations:^{
        for (int m = 0; m < self.photoViews.count; m++) {
            col = m % cols;
            row = m / cols;
            x = (margin + width_Height) * col;
            y = (margin + width_Height) * row + photoY;
            CGRect rect = CGRectMake(x, y, width_Height, width_Height);
            UIView *imageView = self.photoViews[m];
            imageView.frame = rect;
        }
    }];
    
    UIView *lastPhoto = [self.photoViews lastObject];
    if (lastPhoto.y + lastPhoto.height <= _textView.height - 64) {
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    } else {
        UIView *firstPhoto = [self.photoViews firstObject];
        _textView.contentInset = UIEdgeInsetsMake(0, 0, lastPhoto.y - firstPhoto.y + lastPhoto.height + 60, 0);
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
