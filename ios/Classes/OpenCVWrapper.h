//
//  OpenCVWrapper.h
//  image_feature_detector
//
//  Created by Marco Tschannett on 17.04.19.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#include <string>
#include <vector>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (NSString *) getVersionString;
+ (NSString *) getBuildInformation;
+ (NSString *) findImageContour: (NSString *) path;
+ (NSString *) detectAndTransformRectangleInImage: (NSString *) path;
+ (NSMutableDictionary*) serializeContour: (std::vector<cv::Point2f>) maxApprox image:(cv::Mat) source;
@end

NS_ASSUME_NONNULL_END
