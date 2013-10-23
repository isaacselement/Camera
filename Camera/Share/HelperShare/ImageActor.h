#import <Foundation/Foundation.h>

@interface ImageActor : NSObject

+(void) saveImagesAsPNG:(UIImage *)image imageName:(NSString*)imageName ;
+(void) getImagePathsInImagesDirectory: (void (^)(NSArray* imagePaths))handler ;

@end
