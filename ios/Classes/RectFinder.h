//
//  RectFinder.h
//  image_feature_detector
//
//  Created by Marco Tschannett on 16.06.19.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#include <string>
#include <vector>

NS_ASSUME_NONNULL_BEGIN

@interface RectFinder : NSObject
+ (std::vector<cv::Point2f>) findRectangle: (cv::Mat) src;
+ (std::vector<std::vector<cv::Point2f>>) findAllRectangles: (cv::Mat) src;
+ (cv::Mat) _grayScale:(cv::Mat)source;
+ (cv::Mat) _gaussianBlur: (cv::Mat)source;
+ (cv::Mat) _cannyEdgeDetect: (cv::Mat) source;
+ (std::vector<cv::Point2f>) scaleRectangle: (std::vector<cv::Point2f>) points withScale:(double) scale;
+ (std::vector<cv::Point2f>) convertPointstoPoint2fVector: (std::vector<cv::Point>) points;
@end

NS_ASSUME_NONNULL_END
