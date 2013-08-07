//
//  PSCroopToolView.h
//  CropTool
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Pastez Design 2013 www.pastez.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSCroopToolView : UIView

@property (readwrite,nonatomic) CGFloat cropAreaFillFactor;
@property (readwrite,nonatomic) CGSize outputSize;
@property (readwrite,nonatomic) BOOL showQueueActivitiIndicator;

- (void)imageToCroop:(UIImage*)image;
- (UIImage*)getOutputImage;
- (void)getOutputImageAsync:(void (^) (UIImage *outputImage))handler;

- (void)setCropAreaBorderWidth:(CGFloat)width;
- (void)setCropAreaBorderColor:(UIColor*)color;

@end
