//
//  PSCroopToolView.h
//  CropTool
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Tomasz Kwolek 2013 www.pastez.com.
//

#import <UIKit/UIKit.h>

@interface PSCropToolView : UIView

@property (readwrite,nonatomic) CGFloat cropAreaFillFactor;             // scale of crop area from 0 to 1. 1 is full component frame
@property (readwrite,nonatomic) CGFloat requiredFillFactor;             // minimal area of image in cropping area
@property (readwrite,nonatomic) CGSize outputSize;                      // designated output image size
@property (readwrite,nonatomic) BOOL showQueueActivitiIndicator;        // show UIActivitiIndicatorView when doing getOutputImageAsync

- (void)imageToCrop:(UIImage*)image;                                    // sets source image
- (UIImage*)getOutputImage;                                             // returns output cropped image
- (void)getOutputImageAsync:(void (^) (UIImage *outputImage))handler;   // returns output cropped image, cropping is made in bacground queue

- (void)setCropAreaBorderWidth:(CGFloat)width;                          // sets crop area border size
- (void)setCropAreaBorderColor:(UIColor*)color;                         // sets crop area border color

@end
