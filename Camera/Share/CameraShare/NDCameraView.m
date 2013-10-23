#import "NDCameraView.h"
#import "NDCamera.h"
#import "NDCameraFocusSquare.h"

@implementation NDCameraView

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@synthesize delegate;
@synthesize supportFocusPrompt;

- (id)init {
    self = [super init];
    if (self) {
        
        camera = [[NDCamera alloc] init];

        supportFocusPrompt = YES;
        focusPrompt = [[NDCameraFocusSquare alloc] init];
        [self addSubview: focusPrompt];
        
        [self addObserver:self forKeyPath:@"camera.backCamera.adjustingFocus" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:AVCamFocusModeObserverContext];
        
        // Add a single tap gesture to focus on the point tapped, then lock focus
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
        [singleTap setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTap];
        
    }
    return self;
}

#pragma mark - Public Methods

-(void) startCamera {
    [camera show: self];
}

-(void) stopCamera {
    [camera remove];
}

-(void) captureImage {
    if (!camera.isReady) @throw [NSException exceptionWithName: @"CameraNotReady" reason:@"While capture image , you should wait camera is ready" userInfo:nil];
    [camera captureStillImage: ^(UIImage *image) {
        if (delegate && [delegate respondsToSelector: @selector(didCaputureImage:)]) {
            [delegate didCaputureImage: image];
        }
    }];
}

#pragma mark - Internal Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == AVCamFocusModeObserverContext) {
        // did successfully auto focus , notice about that when focused->noFocused would also callback
        BOOL kind = [[change objectForKey: @"kind"] boolValue] ;
        BOOL new = [[change objectForKey: @"new"] boolValue] ;
        BOOL old = [[change objectForKey: @"old"] boolValue] ;
        
        BOOL isFocusing = kind == YES && new == YES && old == NO;
        if (isFocusing && [self isSupportFocusPrompt]) {
            [camera isTapFocusMode] ? [focusPrompt show: focusPoint] : [focusPrompt show: [self convertPoint: self.center fromView:[self superview]]];
        }
        BOOL isSuccessDidFocus = kind == YES && new == NO && old == YES;
        
        if (isSuccessDidFocus) {
            if (delegate && [delegate respondsToSelector:@selector(didSuccessTapFocus)] && [camera isTapFocusMode]) [delegate didSuccessTapFocus];
            if (delegate && [delegate respondsToSelector:@selector(didSuccessAutoFocus)] && [camera isAutoFocusMode]) [delegate didSuccessAutoFocus];
            
            if ([camera isTapFocusMode]) {
//                NSLog(@":) chang to auto focus mode");
                [NSObject cancelPreviousPerformRequestsWithTarget: camera selector:@selector(switchToContinuousFocusMode) object:nil];
                [camera performSelector:@selector(switchToContinuousFocusMode) withObject:nil afterDelay:2.0];
            }
        }
	}
}


-(void) tapToAutoFocus: (UIGestureRecognizer*)gestureRecognizer {
    CGPoint tapPoint = [gestureRecognizer locationInView: self];
    focusPoint = tapPoint;
//        NSLog(@"Taped: %f, %f", tapPoint.x, tapPoint.y);
    
    if ([camera isFocusPointSupported]) {
        [camera switchToTapFocusMode: tapPoint view:self];
    }
}

-(void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    CGFloat size = frame.size.width/4;
    focusPrompt.frame = CGRectMake(0, 0, size, size);
}

-(void)dealloc {
    [camera release];
    [focusPrompt release];
    delegate = nil;
    [super dealloc];
}

@end
