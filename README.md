Cocoa Crop Tool
===============

Simple Crop Image Component for iOS

## Installation

Simply copy PSCropToolComponent directory into your project

## Example of usage

```objC
PSCroopToolView croopTool = [[PSCroopToolView alloc] initWithFrame:CGRectMake(0, 0, 320, 230)];
[croopTool imageToCroop:[UIImage imageNamed:@"testImg.png"]]; //load image that you want to crop
croopTool.outputSize = CGSizeMake(640, 940); //choose your desire output size
croopTool.cropAreaFillFactor = 0.7; //scale of highlighted crop area
[croopTool setCropAreaBorderWidth:2.0];
[croopTool setCropAreaBorderColor:[UIColor yellowColor]];
[self.view addSubview:croopTool];
```

to get output image call

```
[croopTool getOutputImageAsync:^(UIImage *outputImage) {
    _outputImageView.image = outputImage;
}];
```

OR


```
UIImage *outputImage = [croopTool getOutputImage];
```