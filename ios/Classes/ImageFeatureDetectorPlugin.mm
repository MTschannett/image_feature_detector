#import "ImageFeatureDetectorPlugin.h"
#import <image_feature_detector/image_feature_detector-Swift.h>
#import <opencv2/opencv.hpp>
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"


using namespace cv;
using namespace std;

@implementation ImageFeatureDetectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImageFeatureDetectorPlugin registerWithRegistrar:registrar];
}

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (void) findImageContour:(string)fileName{
    Mat canny_output;
    vector<vector<cv::Point>> contours;
    
}
@end

// Mat canny_output;
// vector<vector<cv::Point>> contours;
// vector<Vec4i> hierarchy;

// Mat src = imread(fileName)

// cvtColor(<#InputArray src#>, <#OutputArray dst#>, <#int code#>)
