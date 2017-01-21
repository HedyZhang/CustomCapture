//
//  CaptureViewController.m
//  CustomCapture
//
//  Created by 张海迪 on 15/3/18.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import "CaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface CaptureViewController ()
@property (nonatomic, strong)       AVCaptureSession            * session;
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong)       AVCaptureDeviceInput        * videoInput;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong)       AVCaptureStillImageOutput   * stillImageOutput;
//照片输出流对象，当然我的照相机只有拍照功能，所以只需要这个对象就够了
@property (nonatomic, strong)       AVCaptureVideoPreviewLayer  * previewLayer;
//预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong)       UIBarButtonItem             * toggleButton;
//切换前后镜头的按钮
@property (nonatomic, strong)       UIButton                    * shutterButton;
//拍照按钮
@property (nonatomic, strong)       UIButton                      * changeCameraButton;

@end

@implementation CaptureViewController


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.session) {
        [self.session startRunning];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照相机";
    [self setupButton];
    [self setupSession];
    [self setupPreviewLayer];
}

- (void)setupButton {
    self.shutterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _shutterButton.frame = CGRectMake(0, self.view.bounds.size.height - 100, 80, 80);
    _shutterButton.center = CGPointMake(self.view.bounds.size.width / 2, _shutterButton.center.y);
    [_shutterButton setTitle:@"快门" forState:UIControlStateNormal];
    [_shutterButton addTarget:self action:@selector(shutter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shutterButton];
    
    self.changeCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _changeCameraButton.frame = CGRectMake(self.view.bounds.size.width - 100, self.view.bounds.size.height - 100, 80, 80);
    [_changeCameraButton setTitle:@"切换" forState:UIControlStateNormal];
    [_changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_changeCameraButton];

}

- (void)setupSession {
    //创建会话层
    self.session = [[AVCaptureSession alloc] init];
    [self.session  setSessionPreset:AVCaptureSessionPresetPhoto];
    
    //创建输入捕获设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device  error:nil];
    
    //图片输出对象
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSetting = @{AVVideoCodecKey: AVVideoCodecJPEG};
    [self.stillImageOutput  setOutputSettings:outputSetting];
    
    [self.session addInput:self.videoInput];
    [self.session addOutput:self.stillImageOutput];
}

/**
 配置预览layer
 */
- (void)setupPreviewLayer
{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 300);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];

}

//快门
- (void)shutter:(UIButton *)btn {
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        NSLog(@"image size = %@",NSStringFromCGSize(image.size));
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
}

//切换前置、后置
- (void)changeCamera:(UIButton *)btn {
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs )
    {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] )
        {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            
            
            [self.session beginConfiguration];
            [self.session removeInput:input];
            [self.session addInput:newInput];
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            
            break;
        }
    }
}


/**
 根据摄像头方向获取捕获设备

 @param position 摄像头方向
 @return 指定摄像头方向的捕获设备
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
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
