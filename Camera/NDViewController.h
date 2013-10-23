#import <UIKit/UIKit.h>

#import "NDCameraView.h"
#import "MWPhotoBrowser.h"

@class NDAutoCameraDelegate;

@interface NDViewController : UIViewController <NDCameraViewDelegate, MWPhotoBrowserDelegate> {
    NDCameraView* cameraView;
    
    NDAutoCameraDelegate* autoTakeDelegate;
    
    BOOL isAutoTakeImage;
}

@property (nonatomic, retain) NSMutableArray *photos;

@property (retain, nonatomic) IBOutlet UIButton *runButton;
@property (retain, nonatomic) IBOutlet UIButton *takeButton;
@property (retain, nonatomic) IBOutlet UIButton *startButton;
@property (retain, nonatomic) IBOutlet UIButton *stopButton;
@property (retain, nonatomic) IBOutlet UILabel *numLabel;
@property (retain, nonatomic) IBOutlet UIImageView *captureImage;

- (IBAction)pickerButtonAction:(id)sender;
- (IBAction)takeAction:(id)sender;
- (IBAction)startAction:(id)sender;
- (IBAction)stopAction:(id)sender;

@end
