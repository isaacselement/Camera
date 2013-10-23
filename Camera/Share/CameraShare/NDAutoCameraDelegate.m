#import "NDAutoCameraDelegate.h"

#import "ImageActor.h"

@implementation NDAutoCameraDelegate

-(void) didSuccessTapFocus {
    if (self.isAutoTakeImage) {
        [_camera captureImage];
    }
}

-(void) didSuccessAutoFocus {
    if (self.isAutoTakeImage) {
        [_camera captureImage];
    }
}

-(void) didCaputureImage: (UIImage*)image {
    [ImageActor saveImagesAsPNG: image imageName: [self stringFromDate: [NSDate date]]];
}

- (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH-mm-ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return destDate;
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return destDateString;
}

-(void)dealloc {
    _camera = nil;
    [super dealloc];
}

@end
