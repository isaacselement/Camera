#import <UIKit/UIKit.h>

@class NDCamera;
@class NDCameraFocusSquare;

@protocol NDCameraViewDelegate;

@interface NDCameraView : UIView {
    NDCamera* camera ;
    
    CGPoint focusPoint;
    NDCameraFocusSquare* focusPrompt;
}

@property (assign, nonatomic) id<NDCameraViewDelegate> delegate;
@property (assign, nonatomic, getter = isSupportFocusPrompt) BOOL supportFocusPrompt;

-(void) stopCamera ;
-(void) startCamera ;
-(void) captureImage ;

@end


@protocol NDCameraViewDelegate <NSObject>

@optional
-(void) didSuccessTapFocus ;
-(void) didSuccessAutoFocus ;
-(void) didCaputureImage: (UIImage*)image;

@end
