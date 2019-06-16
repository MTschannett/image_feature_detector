//
//  PerspectiveTransformation.h
//  image_feature_detector
//
//  Created by Marco Tschannett on 16.06.19.
//

#import <Foundation/Foundation.h>

#import <opencv2/opencv.hpp>
#include <vector>

NS_ASSUME_NONNULL_BEGIN

@interface PerspectiveTransformation : NSObject
+ (cv::Mat) transform: (cv::Mat) src withRectangle:(std::vector<cv::Point2f>) points;
+ (cv::Size) getRectangleSize: (std::vector<cv::Point2f>) rectangle;
+ (double) getDistance: (cv::Point) point andPoint: (cv::Point) point2;
+ (std::vector<cv::Point2f>) getOutline: (cv::Mat) image;
+ (std::vector<cv::Point2f>) sortCorners: (std::vector<cv::Point2f>) corners;
+ (cv::Point) getMassCenter: (std::vector<cv::Point2f>) points;
@end

NS_ASSUME_NONNULL_END
