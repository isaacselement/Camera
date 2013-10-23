#import <UIKit/UIKit.h>

@class CABasicAnimation;

@interface NDCameraFocusSquare : UIView {
    CABasicAnimation* selectionAnimation;
}

-(void) show: (CGPoint)tapPoint ;

@end
