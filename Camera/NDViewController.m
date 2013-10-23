#import "NDViewController.h"

#import "NDCameraView.h"
#import "NDAutoCameraDelegate.h"
#import "NDAppDelegate.h"

#import "ImageActor.h"

@interface NDViewController ()

@end

@implementation NDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _photos = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickerButtonAction:(id)sender {
    if(!cameraView) cameraView = [[NDCameraView alloc] init];
    if(!autoTakeDelegate) autoTakeDelegate = [[NDAutoCameraDelegate alloc] init];
    
    // one
    autoTakeDelegate.camera = cameraView;
    cameraView.delegate = autoTakeDelegate;
    autoTakeDelegate.autoTakeImage = YES;
    
    // two
//    cameraView.delegate = self;
    
    cameraView.frame = CGRectMake(60, 10, 200, 200);
//    cameraView.bounds = self.view.bounds;
//    cameraView.center = [self.view convertPoint: self.view.center fromView:[self.view superview]];
    
    [self.view addSubview: cameraView];
    [cameraView startCamera];
    
}

- (IBAction)takeAction:(id)sender {
    [cameraView captureImage];
}

- (IBAction)startAction:(id)sender {
    isAutoTakeImage = YES;
//    [cameraView performSelector: @selector(captureImage) withObject:nil afterDelay:3];
}

- (IBAction)stopAction:(id)sender {
    isAutoTakeImage = NO;
//    [NSObject cancelPreviousPerformRequestsWithTarget: cameraView selector:@selector(captureImage) object:nil];
    
    [ImageActor getImagePathsInImagesDirectory:^(NSArray *imagePaths) {
        MWPhoto *photo = nil;
        [_photos removeAllObjects];
        for (NSString* path in imagePaths) {
            photo = [MWPhoto photoWithFilePath: path];
             [_photos addObject:photo];
        }
        
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        
        // Show browser
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:browser];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navigationController animated:YES completion:nil];
        [navigationController release];
        
    }];
    
    [cameraView stopCamera];
}

#pragma mark - CameraDelegate Methods

-(void) didSuccessTapFocus {
    NSLog(@"delegate didSuccessTapFocus");
    if (isAutoTakeImage) {
        [cameraView captureImage];
    }
}

-(void) didSuccessAutoFocus {
    NSLog(@"delegate didSuccessAutoFocus");
    if (isAutoTakeImage) {
        [cameraView captureImage];
    }
}

-(void) didCaputureImage: (UIImage*)image {
    NSLog(@"delegate didCaputureImage");
    self.captureImage.image = image;
    
    static int count = 0;
    count ++;
    NSString* countStr = [[NSNumber numberWithInt: count] stringValue];
    self.numLabel.text = countStr;
    
    [ImageActor saveImagesAsPNG: image imageName: countStr];
}

#pragma mark - MWPhotoBrowserDelegate Methods

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)dealloc {
    [_runButton release];
    [_takeButton release];
    [_startButton release];
    [_stopButton release];
    [_numLabel release];
    [_captureImage release];
    [_photos release];
    [super dealloc];
}

@end
