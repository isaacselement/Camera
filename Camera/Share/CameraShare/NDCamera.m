#import "NDCamera.h"

#import "NDCameraHelper.h"

#import <AVFoundation/AVFoundation.h>

#define VideoInput @"videoInput"
#define AudioInput @"audioInput"
#define ImageOutput @"imageOutput"


@implementation NDCamera

@synthesize isReady;
@synthesize backCamera;
@synthesize cameraSession;
@synthesize cameraPreviewLayer;

- (id)init {
    self = [super init];
    if (self) {
        ioDevicesMap = [[NSMutableDictionary alloc] init];
        
        [self setupSession];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraDidReady:) name:AVCaptureSessionDidStartRunningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraNotReady:) name:AVCaptureSessionDidStopRunningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraNotReady:) name:AVCaptureSessionWasInterruptedNotification object:nil];
    }
    return self;
}

-(void) setupSession {
    // get the references of all devices
    AVCaptureDevice* audioDevice = [self audioDevice];
    AVCaptureDevice* backFacingCamera = [self backFacingCamera];
    AVCaptureDevice* frontFacintCamera = [self frontFacingCamera];
    
	// Set torch and flash mode to auto
    [self setTorchFlashAuto: backFacingCamera];
    [self setTorchFlashAuto: frontFacintCamera];
	
    
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:nil];
    AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    
	
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [newStillImageOutput setOutputSettings:outputSettings];
    [outputSettings release];
    
    
    // Create session (use default AVCaptureSessionPresetHigh)
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddInput:newAudioInput]) {
        [newCaptureSession addInput:newAudioInput];
    }
    if ([newCaptureSession canAddOutput:newStillImageOutput]) {
        [newCaptureSession addOutput:newStillImageOutput];
    }
    
    
    // create preview layer
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:newCaptureSession];
    if (newCaptureVideoPreviewLayer.connection.isVideoOrientationSupported) {
        newCaptureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // set the properties
    self.cameraSession = newCaptureSession;
    self.cameraPreviewLayer = newCaptureVideoPreviewLayer;
    [ioDevicesMap setObject: newVideoInput forKey:VideoInput];
    [ioDevicesMap setObject: newAudioInput forKey:AudioInput];
    [ioDevicesMap setObject: newStillImageOutput forKey:ImageOutput];
    
    
    // release
    [newStillImageOutput release];
    [newVideoInput release];
    [newAudioInput release];
    [newCaptureSession release];
    [newCaptureVideoPreviewLayer release];
    
    
    // add did auto focus observer
    self.backCamera = backFacingCamera;
}

#pragma mark - Public Methods

-(void) show: (UIView*)parentView {
    CALayer* parentLayer = parentView.layer;
    parentLayer.masksToBounds = YES;
    cameraPreviewLayer.bounds = parentLayer.bounds;
    cameraPreviewLayer.anchorPoint = CGPointMake(0,0);
    [parentLayer insertSublayer:cameraPreviewLayer below:[[parentLayer sublayers] objectAtIndex:0]];
    
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.cameraSession startRunning];
    });
}

-(void) remove {
    [cameraPreviewLayer removeFromSuperlayer];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.cameraSession stopRunning];
    });
}

-(void) scaleToFitDevice {
    // Device's screen size (ignoring rotation intentionally):
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    // iOS is going to calculate a size which constrains the 4:3 aspect ratio
    // to the screen size. We're basically mimicking that here to determine
    // what size the system will likely display the image at on screen.
    // NOTE: screenSize.width may seem odd in this calculation - but, remember,
    // the devices only take 4:3 images when they are oriented *sideways*.
    float cameraAspectRatio = 4.0 / 3.0;
    float imageWidth = floorf(screenSize.width * cameraAspectRatio);
    float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
    cameraPreviewLayer.affineTransform = CGAffineTransformMakeScale(scale, scale+0.05);
}

-(BOOL) isReady {
    return isReady && cameraSession.isRunning && !cameraSession.interrupted;
}

-(BOOL) isFocusPointSupported {
    return [[self getDeviceByKey: VideoInput] isFocusPointOfInterestSupported];
}

-(BOOL) isTapFocusMode {
    AVCaptureDevice *device = [self getDeviceByKey: VideoInput];
    return device.focusMode == AVCaptureFocusModeAutoFocus;
}

-(BOOL) isAutoFocusMode {
    AVCaptureDevice *device = [self getDeviceByKey: VideoInput];
    return device.focusMode == AVCaptureFocusModeContinuousAutoFocus;
}

-(void) switchToTapFocusMode: (CGPoint)tapPoint view:(UIView*)parentView {
    CGPoint convertedFocusPoint = [NDCameraHelper convertToPointOfInterestFromViewCoordinates: tapPoint view:parentView layer:cameraPreviewLayer device:[ioDevicesMap objectForKey:VideoInput]];
//    NSLog(@"Converted: %f, %f", convertedFocusPoint.x, convertedFocusPoint.y);
    [self switchToTapFocusModeAtPoint: convertedFocusPoint];
}

// Switch to tap auto focus mode at the specified point
-(void) switchToTapFocusModeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self getDeviceByKey: VideoInput];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
//            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) [device setExposureMode:AVCaptureExposureModeAutoExpose];
            [device unlockForConfiguration];
        } else {
        }
    }
}

-(void) switchToContinuousFocusMode {
    [self continuousFocusAtPoint: CGPointMake(.5f, .5f)];
}

// Switch to continuous auto focus mode at the specified point
-(void) continuousFocusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self getDeviceByKey: VideoInput];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
		}
	}
}

// capture an image
-(void) captureStillImage: (void (^)(UIImage* image))completeHandler {
    AVCaptureStillImageOutput* stillImageOutput = [ioDevicesMap objectForKey:ImageOutput];
    AVCaptureConnection *stillImageConnection = [NDCameraHelper connectionWithMediaType:AVMediaTypeVideo fromConnections:[stillImageOutput connections]];
    
    if ([stillImageConnection isVideoOrientationSupported]) [stillImageConnection setVideoOrientation:[NDCameraHelper getCaptureDeviceOrientation]];
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                      if (imageDataSampleBuffer != NULL) {
                                                          NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                          UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                          completeHandler(image);
                                                          [image release];
                                                      }
                                                  }];
}

#pragma mark - Internal Methods

-(void) cameraDidReady:(NSNotification *)notification {
    self.isReady = YES;
}
-(void) cameraNotReady:(NSNotification *)notification {
    self.isReady = NO;
}

// Get the capure device object from we stored dic
-(AVCaptureDevice*) getDeviceByKey: (NSString*)key {
    AVCaptureDeviceInput* videoInput = [ioDevicesMap objectForKey: key];
    AVCaptureDevice *device = [videoInput device];
    return device;
}

// Set torch and flash mode to auto
-(void) setTorchFlashAuto: (AVCaptureDevice*)device {
    if (device.hasFlash) {
		if ([device lockForConfiguration:nil]) {
			if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[device setFlashMode:AVCaptureFlashModeAuto];
			}
			[device unlockForConfiguration];
		}
	}
}

// Find and return an audio device, returning nil if one is not found
-(AVCaptureDevice *) audioDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) return [devices objectAtIndex:0];
    return nil;
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
-(AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) return device;
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
-(AVCaptureDevice *) frontFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
-(AVCaptureDevice *) backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


-(void)dealloc {
    [ioDevicesMap release];
    [cameraSession release];
    [cameraPreviewLayer release];
    [super dealloc];
}

@end
