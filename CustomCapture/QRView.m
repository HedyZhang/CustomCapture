//
//  QRView.m
//  CustomCapture
//
//  Created by yanshu on 15/9/3.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import "QRView.h"

#define kImageStretch(img) [img stretchableImageWithLeftCapWidth:img.size.width / 2 topCapHeight:img.size.height / 2]

@interface QRView ()

@property (nonatomic, strong) UIImageView *scanLineView;
@end

@implementation QRView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        _imageView.alpha = 0.4;
        UIImage *img = [UIImage imageNamed:@"qrcode_border"];
        _imageView.image = kImageStretch(img);
        _imageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self addSubview:_imageView];
        
        self.scanLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ff_QRCodeScanLine"]];
        _scanLineView.frame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _imageView.frame.size.width, 4);
        [self addSubview:_scanLineView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [UIView setAnimationRepeatCount:MAXFLOAT];
        _scanLineView.center = CGPointMake(_imageView.center.x, _imageView.frame.origin.y + _imageView.frame.size.height);
        [UIView commitAnimations];
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(context, rect);
    CGContextClearRect(context, _imageView.frame);
    CGContextStrokePath(context);
}
@end
