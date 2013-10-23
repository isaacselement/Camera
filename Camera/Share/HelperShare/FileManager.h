#import <Foundation/Foundation.h>

#define NSFileManager [NSFileManager defaultManager]

@interface FileManager : NSObject {
}

+(NSString*) documentPath;
+(BOOL) ifFileExist: (NSString*)fullPath ;
+(void) saveDataToDocumentWithSubPath: (NSString*)subPath data:(NSData*)_data ;

+(NSMutableArray*) getFilesPathsIn: (NSString*)directoryPath ;

    
@end
