#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@class AVCaptureConnection;
@class AVCaptureDeviceInput;
@class AVCaptureVideoPreviewLayer;

@interface NDCameraHelper : NSObject

+(AVCaptureVideoOrientation) getCaptureDeviceOrientation ;

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections ;


+(CGPoint) convertToPointOfInterestFromViewCoordinates: (CGPoint)coordinates view:(UIView*)view layer:(AVCaptureVideoPreviewLayer*)layer device:(AVCaptureDeviceInput*)device ;

@end
