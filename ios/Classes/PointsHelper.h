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
+(void) sortPoints: (std::vector<cv::Point>)unsortedPoints withList:(cv::Point2f[]) baseList;
+(void) getTopLeftPoint: (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list;
+(void) getBottomLeftPoint: (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list;
+(void) getTopRightPoint: (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list;
+(void) getBottomRightPoint: (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list;
@end

NS_ASSUME_NONNULL_END
