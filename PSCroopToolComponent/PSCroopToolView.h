//
//  PSCroopToolView.h
//  CroopTool
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Pastez Design 2013 www.pastez.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSCroopToolView : UIView

@property (readwrite,nonatomic) CGFloat croopAreaFillFactor;
@property (readwrite,nonatomic) CGFloat requiredFillFactor;
@property (readwrite,nonatomic) CGSize outputSize;
@property (readwrite,nonatomic) BOOL showQueueActivitiIndicator;

- (void)imageToCroop:(UIImage*)image;
- (UIImage*)getOutputImage;
- (void)getOutputImageAsync:(void (^) (UIImage *outputImage))handler;

- (void)setCroopAreaBorderWidth:(CGFloat)width;
- (void)setCroopAreaBorderColor:(UIColor*)color;

@end
