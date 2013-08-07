//
//  PSViewController.m
//  CropTool
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Pastez Design 2013 www.pastez.com. All rights reserved.
//

#import "PSViewController.h"
#import "PSCroopToolView.h"

@interface PSViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    CGRect normalOutputFrame;
}

@property (strong,nonatomic) PSCroopToolView *croopTool;
@property (strong,nonatomic) UIImageView *outputImageView;

@end

@implementation PSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.croopTool = [[PSCroopToolView alloc] initWithFrame:CGRectMake(0, 0, 320, 230)];
    [_croopTool imageToCroop:[UIImage imageNamed:@"testImg.png"]];
    _croopTool.outputSize = CGSizeMake(640, 940);
    _croopTool.cropAreaFillFactor = 0.7;
    [_croopTool setCropAreaBorderWidth:2.0];
    [_croopTool setCropAreaBorderColor:[UIColor yellowColor]];
    [self.view addSubview:_croopTool];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sourceButton setTitle:@"SOURCE" forState:UIControlStateNormal];
    [sourceButton addTarget:self action:@selector(getInputImage:) forControlEvents:UIControlEventTouchUpInside];
    sourceButton.frame = CGRectMake(0, CGRectGetHeight(_croopTool.frame)+2, 160, 33);
    [self.view addSubview:sourceButton];
    
    UIButton *cropButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cropButton setTitle:@"CROP IMAGE" forState:UIControlStateNormal];
    [cropButton addTarget:self action:@selector(getOutputImage:) forControlEvents:UIControlEventTouchUpInside];
    cropButton.frame = CGRectMake(160, CGRectGetHeight(_croopTool.frame)+2, 160, 33);
    [self.view addSubview:cropButton];
    
    UITapGestureRecognizer *outputTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outputImageTap:)];
    normalOutputFrame = cropButton.frame;
    normalOutputFrame.origin.x = 0;
    normalOutputFrame.origin.y += cropButton.frame.size.height+2;
    normalOutputFrame.size.width = 320;
    normalOutputFrame.size.height = CGRectGetHeight(self.view.frame)-normalOutputFrame.origin.y;
    self.outputImageView = [[UIImageView alloc] initWithFrame:normalOutputFrame];
    _outputImageView.gestureRecognizers = @[outputTapGesture];
    _outputImageView.userInteractionEnabled = YES;
    _outputImageView.backgroundColor = [UIColor blackColor];
    _outputImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_outputImageView];
}

- (void)getInputImage:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        //
    }];
}

- (void)getOutputImage:(id)sender
{
    [_croopTool getOutputImageAsync:^(UIImage *outputImage) {
        _outputImageView.image = outputImage;
        NSLog(@"crop complete image size:%@",CGSizeCreateDictionaryRepresentation(outputImage.size));
    }];
}

- (void)outputImageTap:(id)sender
{
    [UIView animateWithDuration:.4f animations:^{
        CGRect fsFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        if (CGRectEqualToRect(fsFrame, _outputImageView.frame)) {
            _outputImageView.frame = normalOutputFrame;
        }else
        {
            _outputImageView.frame = fsFrame;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_croopTool imageToCroop:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
