#import "NDCameraFocusSquare.h"

#import <QuartzCore/QuartzCore.h>

#define AnimationKey @"animationKey"

@implementation NDCameraFocusSquare

- (id)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor clearColor].CGColor];
        
        selectionAnimation = [[CABasicAnimation animationWithKeyPath:@"borderColor"] retain];
        selectionAnimation.fromValue = (id)[UIColor greenColor].CGColor;
        selectionAnimation.toValue = (id)[UIColor clearColor].CGColor;
        selectionAnimation.repeatCount = 4;
        selectionAnimation.delegate = self;
    }
    return self;
}

-(void) show: (CGPoint)tapPoint {
    self.center = tapPoint;
    [self.layer removeAnimationForKey: AnimationKey];
    [self.layer addAnimation:selectionAnimation forKey:AnimationKey];
}

#pragma mark - CAAnimationDelegate Methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self.layer removeAnimationForKey: AnimationKey];
    }
}

-(void)dealloc {
    [selectionAnimation release];
    [super dealloc];
}

@end
