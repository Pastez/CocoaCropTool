//
//  PSCroopToolView.m
//  CroopTool
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Pastez Design 2013 www.pastez.com. All rights reserved.
//

#import "PSCroopToolView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_OUTPUT_SIZE CGSizeMake(320, 480)
#define DEFAULT_REQUIRED_FILL_FACTOR 1.0
#define DEFAULT_CROOP_AREA_FILL_FACTOR 0.95
#define DEFAULT_CROOP_AREA_DEFAULT_BORDER_WIDTH 2
#define DEFAULT_CROOP_AREA_DEFAULT_BORDER_COLOR [UIColor whiteColor].CGColor
#define DEFAULT_SHOW_QUEUE_INDICATOR YES

@interface PSCroopToolView()
{
    dispatch_queue_t creatingImageQueue;
    
    float croopAreaScale;
    CGSize croopAreaSize;
    CGPoint croopAreaTL;
    
    float lastScale;
    CGPoint lastPoint;
    
}

@property (strong,nonatomic) UIImage *sourceImage;
@property (strong,nonatomic) UIImageView *sourceImageView;
@property (strong,nonatomic) CALayer *croopAreaLayer;

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
        self.croopAreaFillFactor        = DEFAULT_CROOP_AREA_FILL_FACTOR;
        self.requiredFillFactor         = DEFAULT_REQUIRED_FILL_FACTOR;
    }
    return self;
}

- (void)imageToCroop:(UIImage *)image
{
    self.sourceImage = image;
    if (!_sourceImageView)
    {
        creatingImageQueue = dispatch_queue_create("com.pas.imageCroop", 0);
        
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
    float sx = CGRectGetWidth(_sourceImageView.frame) / croopAreaSize.width;
    float sy = CGRectGetHeight(_sourceImageView.frame) / croopAreaSize.height;
    float destWidth = sx * _outputSize.width;
    float destHeight = sy * _outputSize.height;
    _sourceImageView.layer.anchorPoint = CGPointMake(.5f, .5f);
    float dx = (-croopAreaTL.x + CGRectGetMinX(_sourceImageView.frame)) * (_outputSize.width/croopAreaSize.width);
    float dy = (-croopAreaTL.y + CGRectGetMinY(_sourceImageView.frame)) * (_outputSize.height/croopAreaSize.height);
    
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
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        [self applyFillFactor];
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

- (void)applyFillFactor
{
    if (_requiredFillFactor > 0.0) {
        [UIView animateWithDuration:0.4 animations:^{
            
            float ffPxWidth = croopAreaSize.width * _croopAreaFillFactor * .5f;
            float ffPxHeight = croopAreaSize.height * _croopAreaFillFactor * .5f;
            CGPoint center = _sourceImageView.center;
            if( CGRectGetMinX(_sourceImageView.frame) > CGRectGetMaxX(_croopAreaLayer.frame)-ffPxWidth)
            {
                center.x -= CGRectGetMinX(_sourceImageView.frame) - (CGRectGetMaxX(_croopAreaLayer.frame)-ffPxWidth);
            }
            if( CGRectGetMaxX(_sourceImageView.frame) < CGRectGetMinX(_croopAreaLayer.frame)+ffPxWidth)
            {
                center.x += (CGRectGetMinX(_croopAreaLayer.frame)+ffPxWidth) - CGRectGetMaxX(_sourceImageView.frame);
            }
            if( CGRectGetMinY(_sourceImageView.frame) > CGRectGetMaxY(_croopAreaLayer.frame)-ffPxHeight)
            {
                center.y -= CGRectGetMinY(_sourceImageView.frame) - (CGRectGetMaxY(_croopAreaLayer.frame)-ffPxWidth);
            }
            if( CGRectGetMaxY(_sourceImageView.frame) < CGRectGetMinY(_croopAreaLayer.frame)+ffPxWidth)
            {
                center.y += (CGRectGetMinY(_croopAreaLayer.frame)+ffPxWidth) - CGRectGetMaxY(_sourceImageView.frame);
            }
            
            _sourceImageView.center = center;
            
        }];
    }
}

- (void)setCroopAreaFillFactor:(CGFloat)croopAreaFillFactor
{
    _croopAreaFillFactor = croopAreaFillFactor;
    self.outputSize = _outputSize;
}

- (void)setOutputSize:(CGSize)outputSize
{
    _outputSize = outputSize;
    if (!_croopAreaLayer)
    {
        self.croopAreaLayer = [CALayer layer];
        _croopAreaLayer.borderWidth = DEFAULT_CROOP_AREA_DEFAULT_BORDER_WIDTH;
        _croopAreaLayer.borderColor = DEFAULT_CROOP_AREA_DEFAULT_BORDER_COLOR;
        [self.layer addSublayer:_croopAreaLayer];
    }
    
    if (_outputSize.width > CGRectGetWidth(self.frame) ||
        _outputSize.height > CGRectGetHeight(self.frame)) {
        
        float diffWidth = _outputSize.width - CGRectGetWidth(self.frame);
        float diffHeight = _outputSize.height - CGRectGetHeight(self.frame);
        
        if (diffWidth >= diffHeight)
        {
            croopAreaScale = CGRectGetWidth(self.frame) / outputSize.width;
        }
        else
        {
            croopAreaScale = CGRectGetHeight(self.frame) / outputSize.height;
        }
        
        croopAreaSize = CGSizeMake(_outputSize.width * croopAreaScale * _croopAreaFillFactor,
                                  _outputSize.height * croopAreaScale * _croopAreaFillFactor);
        
        
    }else
    {
        croopAreaSize = CGSizeMake(CGRectGetWidth(self.frame) * _croopAreaFillFactor, CGRectGetHeight(self.frame) * _croopAreaFillFactor);
    }
    
    _croopAreaLayer.frame = CGRectMake(CGRectGetMidX(self.frame) - croopAreaSize.width / 2,
                                      CGRectGetMidY(self.frame) - croopAreaSize.height / 2,
                                      croopAreaSize.width, croopAreaSize.height);
    croopAreaTL = CGPointMake(CGRectGetMinX(_croopAreaLayer.frame), CGRectGetMinY(_croopAreaLayer.frame));
}

- (void)setCroopAreaBorderWidth:(CGFloat)width
{
    _croopAreaLayer.borderWidth = width;
}

- (void)setCroopAreaBorderColor:(UIColor *)color
{
    _croopAreaLayer.borderColor = color.CGColor;
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
