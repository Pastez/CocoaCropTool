//
//  PSCroopToolView.h
//  CroopTool
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Pastez Design 2013 www.pastez.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSCroopToolView : UIView

@property (readwrite,nonatomic) CGFloat croopAreaFillFactor;            // scale of crop area from 0 to 1. 1 is full component frame
@property (readwrite,nonatomic) CGFloat requiredFillFactor;             // minimal area of image in croop area
@property (readwrite,nonatomic) CGSize outputSize;                      // designated output image size
@property (readwrite,nonatomic) BOOL showQueueActivitiIndicator;        // show UIActivitiIndicatorView when doing getOutputImageAsync

- (void)imageToCroop:(UIImage*)image;                                   // sets source image
- (UIImage*)getOutputImage;                                             // returns output croped image
- (void)getOutputImageAsync:(void (^) (UIImage *outputImage))handler;   // returns output croped image, croping is made in bacground queue

- (void)setCroopAreaBorderWidth:(CGFloat)width;                         // sets croop area border size
- (void)setCroopAreaBorderColor:(UIColor*)color;                        // sets croop area border color

@end
