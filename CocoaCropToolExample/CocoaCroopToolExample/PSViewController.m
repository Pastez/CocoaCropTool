//
//  PSViewController.m
//  CocoaCropToolExample
//
//  Created by Tomasz Kwolek on 07.08.2013.
//  Copyright (c) 2013 Tomasz Kwolek 2013 www.pastez.com.
//

#import "PSViewController.h"
#import "PSCropToolView.h"

@interface PSViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    CGRect normalOutputFrame;
}

@property (strong,nonatomic) PSCropToolView *croppingTool;
@property (strong,nonatomic) UIImageView *outputImageView;

@end

@implementation PSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //crop tool initialization
    self.croppingTool = [[PSCropToolView alloc] initWithFrame:CGRectMake(0, 0, 320, 230)];
    [self.croppingTool imageToCrop:[UIImage imageNamed:@"testImg.png"]];
    self.croppingTool.outputSize = CGSizeMake(640, 940);
    self.croppingTool.cropAreaFillFactor = 0.7;
    [self.croppingTool setCropAreaBorderWidth:2.0];
    [self.croppingTool setCropAreaBorderColor:[UIColor yellowColor]];
    [self.view addSubview:self.croppingTool];
    
    UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sourceButton setTitle:@"SOURCE" forState:UIControlStateNormal];
    [sourceButton addTarget:self action:@selector(getInputImage:) forControlEvents:UIControlEventTouchUpInside];
    sourceButton.frame = CGRectMake(0, CGRectGetHeight(self.croppingTool.frame)+2, 160, 33);
    [self.view addSubview:sourceButton];
    
    UIButton *croopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [croopButton setTitle:@"CROOP IMAGE" forState:UIControlStateNormal];
    [croopButton addTarget:self action:@selector(getOutputImage:) forControlEvents:UIControlEventTouchUpInside];
    croopButton.frame = CGRectMake(160, CGRectGetHeight(self.croppingTool.frame)+2, 160, 33);
    [self.view addSubview:croopButton];
    
    UITapGestureRecognizer *outputTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outputImageTap:)];
    normalOutputFrame = croopButton.frame;
    normalOutputFrame.origin.x = 0;
    normalOutputFrame.origin.y += croopButton.frame.size.height+2;
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
    [self.croppingTool getOutputImageAsync:^(UIImage *outputImage) {
        _outputImageView.image = outputImage;
        NSLog(@"croop complete image size:%@",CGSizeCreateDictionaryRepresentation(outputImage.size));
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
    [self.croppingTool imageToCrop:[info objectForKey:UIImagePickerControllerOriginalImage]];
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
