#import "FileManager.h"

#define Document @"Documents"
#define Home NSHomeDirectory()

@implementation FileManager

+(NSString*) documentPath {
    return [NSHomeDirectory() stringByAppendingPathComponent: Document];
}

+(BOOL) ifFileExist: (NSString*)fullPath {
    return ([NSFileManager fileExistsAtPath:fullPath]);
}

+(void) saveDataToDocumentWithSubPath: (NSString*)subPath data:(NSData*)_data {
    NSString* fullPath = [[self documentPath] stringByAppendingPathComponent: subPath];
    [self saveDataToFile: fullPath data:_data];
}

+(NSMutableArray*) getFilesPathsIn: (NSString*)fullPath {
    NSArray* files = [self listFileAtPath: fullPath];
    NSMutableArray* filePaths = [NSMutableArray array];
    for (NSString* file in files) {
        NSString* path = [fullPath stringByAppendingPathComponent: file];
        if (path) [filePaths addObject: path];
    }
    return filePaths;
}


#pragma mark - Not Explicit	Public Methods

+(NSArray *)listFileAtPath:(NSString *)directoryPath {
    int count;
    NSArray *directoryContent = [NSFileManager contentsOfDirectoryAtPath:directoryPath error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++) {
//        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

+(void) saveDataToFile: (NSString*)fullPath data:(NSData*)_data {
    [self checkOrCreateFolder:fullPath];
//    [fileManager createFileAtPath:fullPath contents:_data attributes:nil];
    [_data writeToFile: fullPath atomically:NO];
}

+(void) checkOrCreateFolder: (NSString*)fullPath {
    NSError* error = nil;
    
    if(![self ifFileExist: fullPath]) {
        // file not exists
        NSString* directoryPath = [fullPath stringByDeletingLastPathComponent];
        if(![NSFileManager fileExistsAtPath:directoryPath]) {
            // dir not exists
            [NSFileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }
}


@end
