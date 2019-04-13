#import <Flutter/Flutter.h>

@interface ImageFeatureDetectorPlugin : NSObject<FlutterPlugin>
+ (NSString *)openCVVersionString;
+ (void) findImageContour(string fileName);
@end
