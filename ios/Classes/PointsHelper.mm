//
//  PointsHelper.m
//  image_feature_detector
//
//  Created by Marco Tschannett on 02.05.19.
//

#import "PointsHelper.h"

using namespace cv;
using namespace std;

// https://de.cppreference.com/w/cpp/algorithm/find

@implementation PointsHelper
+(void) sortPoints: (std::vector<cv::Point>)unsortedPoints withList:(cv::Point2f[]) baseList {
    [PointsHelper getTopLeftPoint:unsortedPoints addToList:baseList];
    [PointsHelper getTopRightPoint:unsortedPoints addToList:baseList];
    [PointsHelper getBottomRightPoint:unsortedPoints addToList:baseList];
    [PointsHelper getBottomLeftPoint:unsortedPoints addToList:baseList];
}

+(void) getTopLeftPoint:  (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list {
    auto it = min_element(points.begin(), points.end(), [](const cv::Point p1, const cv::Point p2) {
        double first = p1.x + p1.y;
        double second = p2.x + p2.y;
        
        return first < second;
    });
    
    list[0].x = it->x;
    list[0].y = it->y;
}

+(void) getBottomLeftPoint: (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list {
    auto it = min_element(points.begin(), points.end(), [](const cv::Point p1, const cv::Point p2) {
        double first = p1.x - p1.y;
        double second = p2.x - p2.y;
        
        return first < second;
    });
    
    list[3].x = it->x;
    list[3].y = it->y;
}

+(void) getTopRightPoint: (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list {
    auto it = max_element(points.begin(), points.end(), [](const cv::Point p1, const cv::Point p2) {
        double first = p1.x - p1.y;
        double second = p2.x - p2.y;
        
        return first < second;
    });
    
    list[1].x = it->x;
    list[1].y = it->y;
}
+(void) getBottomRightPoint: (std::vector<cv::Point>) points addToList:(cv::Point2f[]) list {
    auto it = max_element(points.begin(), points.end(), [](const cv::Point p1, const cv::Point p2) {
        double first = p1.x + p1.y;
        double second = p2.x + p2.y;
        
    
        return first < second;
    });
    
    list[2].x = it->x;
    list[2].y = it->y;
}
@end
