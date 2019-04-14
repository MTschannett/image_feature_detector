#import <Flutter/Flutter.h>

@interface ImageFeatureDetectorPlugin : NSObject<FlutterPlugin>
+ (NSString *)openCVVersionString;
+ (std::vector<NSString *>) findImageContour: (UIImage *) source;
+ (cv::Mat) _grayScale:(cv::Mat)source;
+ (cv::Mat) _imageToMat:(UIImage *) source;
+ (UIImage *) _matToImage:(cv::Mat) source;
+ (cv::Mat) _gaussianBlur: (cv::Mat)source;
+ (cv::Mat) _adaptiveThreshold: (cv::Mat) source;
@end
