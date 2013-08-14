Cocoa Crop Tool
===============

Simple Cropping Image Component for iOS

## Installation

Simply copy PSCropToolComponent directory into your project

## Example of usage

```objC
self.croppingTool = [[PSCropToolView alloc] initWithFrame:CGRectMake(0, 0, 320, 230)];
[self.croppingTool imageToCrop:[UIImage imageNamed:@"testImg.png"]];
self.croppingTool.outputSize = CGSizeMake(640, 940);
self.croppingTool.cropAreaFillFactor = 0.7;
[self.croppingTool setCropAreaBorderWidth:2.0];
[self.croppingTool setCropAreaBorderColor:[UIColor yellowColor]];
[self.view addSubview:self.croppingTool];
```

to get output image call

```
[self.croppingTool getOutputImageAsync:^(UIImage *outputImage) {
    _outputImageView.image = outputImage;
}];
```

OR


```
UIImage *outputImage = [self.croppingTool getOutputImage];
```