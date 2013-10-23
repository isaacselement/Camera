#import <Foundation/Foundation.h>

@class AVCaptureDevice;
@class AVCaptureSession;
@class AVCaptureVideoPreviewLayer;

@interface NDCamera : NSObject {
    NSMutableDictionary* ioDevicesMap;
}

@property (assign, nonatomic) BOOL isReady;
@property (assign) AVCaptureDevice* backCamera; //for KVO, has a copy in ioDevicesMap
@property (retain, nonatomic) AVCaptureSession* cameraSession;
@property (retain, nonatomic) AVCaptureVideoPreviewLayer* cameraPreviewLayer;


-(void) scaleToFitDevice ;

-(void) show: (UIView*)parentView ;
-(void) remove ;

-(void) captureStillImage: (void (^)(UIImage* image))completeHandler ;

-(BOOL) isTapFocusMode ;
-(BOOL) isAutoFocusMode ;
-(BOOL) isFocusPointSupported ;
-(void) switchToContinuousFocusMode ;
-(void) switchToTapFocusMode: (CGPoint)tapPoint view:(UIView*)parentView ;

@end
