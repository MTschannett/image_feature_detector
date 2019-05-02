//
//  PointsHelper.h
//  image_feature_detector
//
//  Created by Marco Tschannett on 02.05.19.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

#include <vector>

NS_ASSUME_NONNULL_BEGIN

@interface PointsHelper : NSObject
+(vector<cv::Point>*) sortPoints: (vector<cv::Point>)unsortedPoints;
- (cv::Point*) getTopLeftPoint: (vector<cv::Point>)unsortedPoints;
- (cv::Point*) getTopRightPoint: (vector<cv::Point>)unsortedPoints;
- (cv::Point*) getBottomRightPoint: (vector<cv::Point>)unsortedPoints;
- (cv::Point*) getBottomLeftPoint: (vector<cv::Point>)unsortedPoints;

@end

NS_ASSUME_NONNULL_END
