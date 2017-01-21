//
//  YSCaptureViewController.m
//  CustomCapture
//
//  Created by yanshu on 15/9/1.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRView.h"
@interface QRViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession           * session;
@property (nonatomic, strong) AVCaptureDevice            *device;

@property (nonatomic, strong) AVCaptureDeviceInput       * videoInput;

@property (nonatomic, strong) AVCaptureMetadataOutput    *videoOutput;

@property (nonatomic, strong) AVCaptureStillImageOutput  * stillImageOutput;


@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;

@property (nonatomic, strong) QRView *qrRectView;

@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation QRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"二维码/条形码扫描";
    [self setupSession];
}
- (void)setupSession
{
    self.session = [[AVCaptureSession  alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);

    self.videoOutput = [[AVCaptureMetadataOutput alloc] init];
    [_videoOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    if ([_session canAddInput:self.videoInput]) {
        [_session addInput:self.videoInput];
    }
    
    if ([_session canAddOutput:self.videoOutput]) {
        [_session addOutput:self.videoOutput];
    }
    
    self.videoOutput.metadataObjectTypes = @[AVMetadataObjectTypeAztecCode,
                                             AVMetadataObjectTypeCode128Code,   //CODE128条码  顺丰用的
                                             AVMetadataObjectTypeCode39Code,    //条形码   韵达和申通
                                             AVMetadataObjectTypeCode39Mod43Code,
                                             AVMetadataObjectTypeCode93Code,   //条形码,星号来表示起始符及终止符,如邮政EMS单上的条码
                                             AVMetadataObjectTypeQRCode,        //二维码
                                             AVMetadataObjectTypeEAN8Code,
                                             AVMetadataObjectTypeUPCECode,
                                             AVMetadataObjectTypePDF417Code,                                             
                                             AVMetadataObjectTypeEAN13Code,
                                             ];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:self.view.layer.bounds];
    _previewLayer.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.58].CGColor;
    [self.view.layer addSublayer:_previewLayer];
    
    
    [self.session startRunning];
    [self initQrView];
    
}
- (void)initQrView
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.qrRectView = [[QRView alloc] initWithFrame:screenRect];
    _qrRectView.backgroundColor = [UIColor clearColor];
    _qrRectView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:_qrRectView];
    
    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = [self.view convertRect:_qrRectView.imageView.frame fromView:_qrRectView];

    [self.videoOutput setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];
    
    self.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, cropRect.origin.y + cropRect.size.height + 30, [UIScreen mainScreen].bounds.size.width - 20, 100)];
    _promptLabel.numberOfLines = 0;
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_promptLabel];

    

}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    NSLog(@"availableMetadataObjectTypes = %@", ((AVCaptureMetadataOutput *)captureOutput).availableMetadataObjectTypes);
    NSLog(@" %@",stringValue);
    dispatch_async(dispatch_get_main_queue(), ^{
         self.promptLabel.text = stringValue;
    });
   

}

- (void)pop:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
