#import <Foundation/Foundation.h>

#import "NDCameraView.h"

@interface NDAutoCameraDelegate : NSObject <NDCameraViewDelegate> {
}

@property (assign, nonatomic, getter = isAutoTakeImage) BOOL autoTakeImage;
@property (assign, nonatomic) NDCameraView* camera;

@end
