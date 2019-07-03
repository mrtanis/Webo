//
//  MRTQRcodeScannerController.m
//  Webo
//
//  Created by mrtanis on 2017/11/6.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTQRcodeScannerController.h"
#import <AVFoundation/AVFoundation.h>
#import "MRTWebViewer.h"
#import "MRTImagePickerController.h"
#import "MRTNavigationController.h"
#import <Photos/Photos.h>
#import "MRTRootVCPicker.h"

@interface MRTQRcodeScannerController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer; //视频预览层

@property (nonatomic, strong) CADisplayLink *link;

@property (nonatomic, strong) CAShapeLayer *scanLayer;
@property (nonatomic, weak) UIImageView *scanLine;
@property (nonatomic) CGFloat scanLineY;

//从相册选择的照片
@property (nonatomic, copy) NSArray *photo;
@end

@implementation MRTQRcodeScannerController

-(UIStatusBarStyle)preferredStatusBarStyle

{
    //设置状态栏字体为白色
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setUpScanView];
}


- (void)setUpNavigationBar
{
    //设置item文字颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置title颜色
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:16]
                                                                
                                                                    };
    //通过设置背景图片来达到透明黑色导航栏
    UINavigationBar * bar = self.navigationController.navigationBar;
    UIImage *bgImage = [self imageWithFrame:CGRectMake(0, 0, MRTScreen_Width, 64) alphe:0.3];
    [bar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
    
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(popSelf)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openImagePicker)];
}

- (UIImage *) imageWithFrame:(CGRect)frame alphe:(CGFloat)alphe {
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    UIColor *blackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alphe];
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [blackColor CGColor]);
    CGContextFillRect(context, frame);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)popSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openImagePicker
{
    [_session stopRunning];
    MRTImagePickerController *imagePicker = [[MRTImagePickerController alloc] init];
    imagePicker.photosBlock = ^(NSMutableArray *array, BOOL originalMode) {
        self.photo = array;
        [self scanPhoto];
    };
    imagePicker.singleImageMode = YES;
    
    MRTNavigationController *nav = [[MRTNavigationController alloc] initWithRootViewController:imagePicker];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)setUpScanView
{
    //扫描框边界
    UIImageView *scanBorder = [[UIImageView alloc] initWithFrame:CGRectMake((MRTScreen_Width - 218) * 0.5, (MRTScreen_Height - 218) * 0.5, 218, 218)];
    scanBorder.image = [UIImage imageWithStretchableName:@"qrcode_border"];
    scanBorder.clipsToBounds = YES;
    [self.view addSubview:scanBorder];
    
    //手电筒开关
    UIButton *torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    torchButton.bounds = CGRectMake(0, 0, 45, 45);
    torchButton.center = CGPointMake(CGRectGetMidX(scanBorder.frame), CGRectGetMaxY(scanBorder.frame) + 70);
    torchButton.layer.cornerRadius = 45;
    [torchButton setImage:[UIImage imageNamed:@"QRCodeCloseFlashLight"] forState:UIControlStateNormal];
    [torchButton setImage:[UIImage imageNamed:@"QRCodeOpenFlashLight"] forState:UIControlStateSelected];
    [torchButton addTarget:self action:@selector(clickTorchButton:) forControlEvents:UIControlEventTouchUpInside];
    torchButton.selected = NO;
    [self.view addSubview:torchButton];
    
    _scanLineY = -170;
    UIImageView *scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, - 170, 218, 170)];
    scanLine.image = [UIImage imageNamed:@"qrcode_scanline_qrcode"];
    [scanBorder addSubview:scanLine];
    _scanLine = scanLine;
    
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(moveScanLine)];
    [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)moveScanLine
{
    if (_scanLineY >= 218) {
        _scanLineY = - 170;
    }
    _scanLineY += 4;
    _scanLine.frame = CGRectMake(0, _scanLineY, 218, 170);
}

- (void)clickTorchButton:(UIButton *)button
{
    button.selected = !button.selected;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (button.selected) {
        
        if ([device hasTorch]) {
            //请求独占访问硬件设备
            [device lockForConfiguration:nil];
            //开启手电筒
            [device setTorchMode:AVCaptureTorchModeOn];
            //解除独占访问硬件设备
            [device unlockForConfiguration];
        } else {
            NSLog(@"当前设备无闪光灯");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:@"当前设备无闪光灯或闪光灯不可用" preferredStyle:UIAlertControllerStyleAlert];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissAlert:) userInfo:alert repeats:NO];
            button.selected = NO;
        }
    } else {
        //请求独占访问硬件设备
        [device lockForConfiguration:nil];
        //关闭手电筒
        [device setTorchMode: AVCaptureTorchModeOff];
        //解除独占访问硬件设备
        [device unlockForConfiguration];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpNavigationBar];
    [self setUpScanLayer];
    [self configCamera];
    
}

- (void)setUpScanLayer
{
    if (_scanLayer) {
        [_scanLayer removeFromSuperlayer];
    }
    _scanLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake((MRTScreen_Width - 215) * 0.5, (MRTScreen_Height - 215) * 0.5, 215, 215));
    CGPathAddRect(path, nil, self.view.bounds);
    
    [_scanLayer setFillRule:kCAFillRuleEvenOdd];
    [_scanLayer setPath:path];
    [_scanLayer setFillColor:[UIColor blackColor].CGColor];
    [_scanLayer setOpacity:0.3];
    
    [_scanLayer setNeedsDisplay];
    [self.view.layer addSublayer:_scanLayer];
    
}

- (void)configCamera
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:@"当前设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    //设置device
    _device = device;
    //设置input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    //设置output
    _output = [[AVCaptureMetadataOutput alloc] init];
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置有效扫描区域,所有值在0~1之间，按比例计算
    CGFloat x =(MRTScreen_Width - 218) * 0.5 / MRTScreen_Width;
    CGFloat y = (MRTScreen_Height - 218) * 0.5 / MRTScreen_Height;
    CGFloat width = 218 / MRTScreen_Width;
    CGFloat height = 218 / MRTScreen_Height;
    
    //x,y互换， width,height互换
    [_output setRectOfInterest:CGRectMake(y, x, height, width)];
    
    //设置session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    
    //设置为二维码类型
    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置previewLayer
    if (_previewLayer) {
        [_previewLayer removeFromSuperlayer];
    }
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    //将视频layer放到最底层，保证扫描layer可见
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    [_session startRunning];
    
}

- (void)scanPhoto
{
    if (!_photo.count) {
        return;
    }
    
    PHImageRequestOptions *options= [[PHImageRequestOptions alloc] init];
    options.resizeMode=PHImageRequestOptionsResizeModeExact;
    //options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:[self.photo firstObject] options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        UIImage *image = [self compressPhoto:[UIImage imageWithData:imageData]];
        NSData *data = UIImagePNGRepresentation(image);
        CIImage *ciimage = [CIImage imageWithData:data];
        
        if (ciimage) {
            CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[[CIContext alloc] initWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
            NSArray *resultArr = [qrDetector featuresInImage:ciimage];
            if (resultArr.count >0) {
                CIFeature *feature = resultArr[0];
                CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
                NSString *result = qrFeature.messageString;
                [self showAlertWithString:result];

            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片中不包含二维码信息" preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:nil];
                [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(dismissAlert:) userInfo:alert repeats:NO];
            }
        }else{
            NSLog(@"ciimage为空");
        }
        
    }];
}

- (UIImage *)compressPhoto:(UIImage *)theImage
{
    UIImage* bigImage = theImage;
    float actualHeight = bigImage.size.height;
    float actualWidth = bigImage.size.width;
    float newWidth =0;
    float newHeight =0;
    if(actualWidth < actualHeight) {
        //长图
        newHeight =280.0f;
        newWidth = newHeight / actualHeight * actualWidth;
    }
    else
    {
        //宽图
        newWidth =280.0f;
        newHeight = newWidth / actualWidth * actualHeight;
    }
    CGRect rect =CGRectMake(0.0,0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [bigImage drawInRect:rect];// scales image to rect
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //RETURN
    return newImage;
    
}

- (void)dealloc
{
    [_link invalidate];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if (metadataObjects.count) {
        //大于零说明有结果
        [_session stopRunning];
        //AudioServicesPlaySystemSound(1520);
        //音效文件路径
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"QRcodeSound" ofType:@"wav"];
        NSLog(@"扫描音效地址%@",path);
        
        //组装并播放音效
        SystemSoundID soundID;
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        AudioServicesPlaySystemSound(soundID);
        
        UINotificationFeedbackGenerator *feedback = [[UINotificationFeedbackGenerator alloc] init];
        [feedback notificationOccurred:UINotificationFeedbackTypeSuccess];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        NSArray *arry = metadataObject.corners;
        for (id cornerPoint in arry) {
            NSLog(@"%@",cornerPoint);
        }
        [self showAlertWithString:stringValue];
        
    } else {
        NSLog(@"无扫描信息");
    }
}

- (void)showAlertWithString:(NSString *)stringValue
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:stringValue preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_session != nil) {
            [_session startRunning];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_session != nil) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = stringValue;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"复制成功" preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(dismissAlert:) userInfo:alert repeats:NO];
            
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MRTWebViewer *webViewer = [[MRTWebViewer alloc] initWithURL:[NSURL URLWithString:stringValue]];
        webViewer.popToRootVC = YES;
        [self.navigationController pushViewController:webViewer animated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissAlert:(NSTimer *)timer
{
    UIAlertController *alert = timer.userInfo;
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
    [timer invalidate];
    if (!_session.running) {
        [_session startRunning];
    }
    
    
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
