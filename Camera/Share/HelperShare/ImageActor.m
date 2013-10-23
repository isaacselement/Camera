#import "ImageActor.h"

#import "FileManager.h"

#define ImagesDir @"images/"

@implementation ImageActor

+(void) saveImagesAsPNG:(UIImage *)image imageName:(NSString*)imageName {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* subPath = [NSString stringWithFormat: @"%@%@%@", ImagesDir, imageName, @".png"];
        [FileManager saveDataToDocumentWithSubPath: subPath data: UIImagePNGRepresentation(image)];
    });
}

+(void) getImagePathsInImagesDirectory: (void (^)(NSArray* imagePaths))handler {
    NSString* imageDirectory = [[FileManager documentPath] stringByAppendingPathComponent: ImagesDir];
    NSMutableArray* filePaths = [FileManager getFilesPathsIn: imageDirectory];
    NSArray* temp = [NSArray arrayWithArray: filePaths];
    for(NSString* path in temp) {
        NSString* fileType = [[path pathExtension] lowercaseString];
        if (![fileType isEqualToString:@"png"]) [filePaths removeObject: path];
    }
    handler(filePaths);
}


// to be removed
+(UIImage*) scaleImage:(UIImage *)image toSize:(CGSize)size {
    // Create a graphics image context
    UIGraphicsBeginImageContext(size);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    return newImage;
}

@end
