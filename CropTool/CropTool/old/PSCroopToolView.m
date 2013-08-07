//
//  PSCroopToolView.m
//  CropTool
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Pastez Design 2013 www.pastez.com. All rights reserved.
//

#import "PSCroopToolView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_OUTPUT_SIZE CGSizeMake(320, 480)
#define DEFAULT_CROP_AREA_FILL_FACTOR 0.95
#define DEFAULT_CROP_AREA_DEFAULT_BORDER_WIDTH 2
#define DEFAULT_CROP_AREA_DEFAULT_BORDER_COLOR [UIColor whiteColor].CGColor
#define DEFAULT_SHOW_QUEUE_INDICATOR YES

@interface PSCroopToolView()
{
    dispatch_queue_t creatingImageQueue;
    
    float cropAreaScale;
    CGSize cropAreaSize;
    CGPoint cropAreaTL;
    
    float lastScale;
    CGPoint lastPoint;
    
}

@property (strong,nonatomic) UIImage *sourceImage;
@property (strong,nonatomic) UIImageView *sourceImageView;
@property (strong,nonatomic) CALayer *cropAreaLayer;

@property (strong,nonatomic) UIActivityIndicatorView *imageProcessingIndicator;

@end

@implementation PSCroopToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.showQueueActivitiIndicator = DEFAULT_SHOW_QUEUE_INDICATOR;
        self.outputSize                 = DEFAULT_OUTPUT_SIZE;
        self.cropAreaFillFactor         = DEFAULT_CROP_AREA_FILL_FACTOR;
    }
    return self;
}

- (void)imageToCroop:(UIImage *)image
{
    self.sourceImage = image;
    if (!_sourceImageView)
    {
        creatingImageQueue = dispatch_queue_create("com.pas.imageCrop", 0);
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
        self.gestureRecognizers = @[panGestureRecognizer, pinchGestureRecognizer];
        
        self.sourceImageView = [[UIImageView alloc] init];
        [self insertSubview:_sourceImageView atIndex:0];
    }
    
    CGRect imageViewFrame;
    if (_sourceImage.size.width > CGRectGetWidth(self.frame) ||
        _sourceImage.size.height > CGRectGetHeight(self.frame)) {
        
        float diffWidth = _sourceImage.size.width - CGRectGetWidth(self.frame);
        float diffHeight = _sourceImage.size.height - CGRectGetHeight(self.frame);
        float scale;
        
        if (diffWidth >= diffHeight)
        {
            scale = CGRectGetWidth(self.frame) / _sourceImage.size.width;
        }
        else
        {
            scale = CGRectGetHeight(self.frame) / _sourceImage.size.height;
        }
        
        CGSize imageViewSize = CGSizeMake(_sourceImage.size.width * scale,
                                          _sourceImage.size.height * scale);
        imageViewFrame = CGRectMake(CGRectGetMidX(self.frame) - imageViewSize.width / 2.0f,
                                    CGRectGetMidY(self.frame) - imageViewSize.height / 2.0f,
                                    imageViewSize.width, imageViewSize.height);
        
        
    }else
    {
        imageViewFrame = CGRectMake(CGRectGetMidX(self.frame) - _sourceImage.size.width / 2.0f,
                                    CGRectGetMidY(self.frame) - _sourceImage.size.height / 2.0f,
                                    _sourceImage.size.width, _sourceImage.size.height);
    }
    
    
    _sourceImageView.frame = imageViewFrame;
    _sourceImageView.image = _sourceImage;
}

- (UIImage*)getOutputImage
{
    float sx = CGRectGetWidth(_sourceImageView.frame) / cropAreaSize.width;
    float sy = CGRectGetHeight(_sourceImageView.frame) / cropAreaSize.height;
    float destWidth = sx * _outputSize.width;
    float destHeight = sy * _outputSize.height;
    _sourceImageView.layer.anchorPoint = CGPointMake(.5f, .5f);
    float dx = (-cropAreaTL.x + CGRectGetMinX(_sourceImageView.frame)) * (_outputSize.width/cropAreaSize.width);
    float dy = (-cropAreaTL.y + CGRectGetMinY(_sourceImageView.frame)) * (_outputSize.height/cropAreaSize.height);
    
    UIImage *outputImage;
    UIGraphicsBeginImageContext(_outputSize);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextFillRect(c, CGRectMake(0, 0, _outputSize.width, _outputSize.height));
    
//    CGRect destinationRect = CGRectMake(0,0,destWidth,destHeight);
//    CGContextDrawImage(c, destinationRect, _sourceImage.CGImage);
    
    [_sourceImage drawInRect:CGRectMake(dx, dy, destWidth, destHeight)];
    
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

- (void)getOutputImageAsync:(void (^) (UIImage *outputImage))handler
{
    if (_showQueueActivitiIndicator && !_imageProcessingIndicator) {
        self.imageProcessingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _imageProcessingIndicator.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        _imageProcessingIndicator.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        [_imageProcessingIndicator startAnimating];
        [self addSubview:_imageProcessingIndicator];
    }
    
    dispatch_async(creatingImageQueue, ^{
        
        UIImage *outputImage = [self getOutputImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_showQueueActivitiIndicator) {
                [_imageProcessingIndicator stopAnimating];
                [_imageProcessingIndicator removeFromSuperview];
                self.imageProcessingIndicator = nil;
            }
            handler(outputImage);
        });
    });
}

- (void)onPan:(UIPanGestureRecognizer*)gesture
{
    static float beginX;
    static float beginY;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        beginX = _sourceImageView.center.x;
        beginY = _sourceImageView.center.y;
    }
    else if (gesture.state == UIGestureRecognizerStateRecognized || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:[_sourceImageView superview]];
        CGPoint center = _sourceImageView.center;
        center.x = beginX + translation.x;
        center.y = beginY + translation.y;
        _sourceImageView.center = center;
    }
    else if(gesture.state == UIGestureRecognizerStateEnded)
    {
        
    }
}

- (void)onPinch:(UIPinchGestureRecognizer*)sender
{    
    if ([sender numberOfTouches] < 2)
        return;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
        lastPoint = [sender locationInView:_sourceImageView];
    }
    
    // Scale
    CGFloat scale = 1.0 - (lastScale - sender.scale);
    [_sourceImageView.layer setAffineTransform:CGAffineTransformScale([_sourceImageView.layer affineTransform], scale, scale)];
    lastScale = sender.scale;
    
    // Translate
    CGPoint point = [sender locationInView:_sourceImageView];
    [_sourceImageView.layer setAffineTransform:CGAffineTransformTranslate([_sourceImageView.layer affineTransform], point.x - lastPoint.x, point.y - lastPoint.y)];
    lastPoint = [sender locationInView:_sourceImageView];
}

- (void)setCropAreaFillFactor:(CGFloat)cropAreaFillFactor
{
    _cropAreaFillFactor = cropAreaFillFactor;
    self.outputSize = _outputSize;
}

- (void)setOutputSize:(CGSize)outputSize
{
    _outputSize = outputSize;
    if (!_cropAreaLayer)
    {
        self.cropAreaLayer = [CALayer layer];
        _cropAreaLayer.borderWidth = DEFAULT_CROP_AREA_DEFAULT_BORDER_WIDTH;
        _cropAreaLayer.borderColor = DEFAULT_CROP_AREA_DEFAULT_BORDER_COLOR;
        [self.layer addSublayer:_cropAreaLayer];
    }
    
    if (_outputSize.width > CGRectGetWidth(self.frame) ||
        _outputSize.height > CGRectGetHeight(self.frame)) {
        
        float diffWidth = _outputSize.width - CGRectGetWidth(self.frame);
        float diffHeight = _outputSize.height - CGRectGetHeight(self.frame);
        
        if (diffWidth >= diffHeight)
        {
            cropAreaScale = CGRectGetWidth(self.frame) / outputSize.width;
        }
        else
        {
            cropAreaScale = CGRectGetHeight(self.frame) / outputSize.height;
        }
        
        cropAreaSize = CGSizeMake(_outputSize.width * cropAreaScale * _cropAreaFillFactor,
                                  _outputSize.height * cropAreaScale * _cropAreaFillFactor);
        
        
    }else
    {
        cropAreaSize = CGSizeMake(CGRectGetWidth(self.frame) * _cropAreaFillFactor, CGRectGetHeight(self.frame) * _cropAreaFillFactor);
    }
    
    _cropAreaLayer.frame = CGRectMake(CGRectGetMidX(self.frame) - cropAreaSize.width / 2,
                                      CGRectGetMidY(self.frame) - cropAreaSize.height / 2,
                                      cropAreaSize.width, cropAreaSize.height);
    cropAreaTL = CGPointMake(CGRectGetMinX(_cropAreaLayer.frame), CGRectGetMinY(_cropAreaLayer.frame));
}

- (void)setCropAreaBorderWidth:(CGFloat)width
{
    _cropAreaLayer.borderWidth = width;
}

- (void)setCropAreaBorderColor:(UIColor *)color
{
    _cropAreaLayer.borderColor = color.CGColor;
}

- (void)dealloc
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
