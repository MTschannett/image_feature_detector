//
//  PerspectiveTransformation.m
//  image_feature_detector
//
//  Created by Marco Tschannett on 16.06.19.
//

#import "PerspectiveTransformation.h"

using namespace cv;
using namespace std;

#include "opencv2/imgproc/imgproc.hpp"

@implementation PerspectiveTransformation
+ (cv::Mat) transform: (cv::Mat) src withRectangle:(std::vector<cv::Point2f>) points {
    vector<Point2f> sorted =  [self sortCorners: points];
    cv::Size size = [self getRectangleSize:sorted];
    
    Mat result = Mat::zeros(size, src.type());
    vector<Point2f> outline = [self getOutline:result];
    
    Mat transformation = getPerspectiveTransform(sorted, outline);
    warpPerspective(src, result, transformation, size);
    
    return result;
}

+ (cv::Size) getRectangleSize: (std::vector<cv::Point2f>) rectangle {
    double top = [self getDistance: rectangle[0] andPoint: rectangle[1]];
    double right = [self getDistance: rectangle[1] andPoint: rectangle[2]];
    double bottom = [self getDistance: rectangle[2] andPoint: rectangle[3]];
    double left = [self getDistance:rectangle[3] andPoint: rectangle[0]];
    
    double averageWidth = (top + bottom) / 2.0;
    double averageHeight = (right + left) / 2.0;
    
    return cv::Size(cv::Point(averageWidth, averageHeight));
}

+ (double) getDistance: (cv::Point) point andPoint: (cv::Point) point2 {
    double dx = point2.x - point.x;
    double dy = point2.y - point.y;
    return sqrt(dx * dx + dy * dy);
}

+ (std::vector<cv::Point2f>) getOutline: (cv::Mat) image {
    vector<Point2f> result;
    
    // top left point
    result.push_back(cv::Point(0, 0));
    // top right point
    result.push_back(cv::Point(image.cols, 0));
    // bottom right point
    result.push_back(cv::Point(image.cols, image.rows));
    // bottom left point
    result.push_back(cv::Point(0, image.rows));
    
    return result;
}

+ (std::vector<cv::Point2f>) sortCorners: (std::vector<Point2f>) corners {
    cv::Point center = [self getMassCenter:corners];
    vector<Point2f> result;
    
    std::vector<Point2f> topPoints;
    std::vector<Point2f> bottomPoints;
    
    for(size_t i = 0; i < corners.size(); i++) {
        Point2f p = corners[i];
        if (p.y < center.y) {
            topPoints.push_back(p);
        } else {
            bottomPoints.push_back(p);
        }
    }
    
    // top left point
    result.push_back(topPoints[0].x > topPoints[1].x ? topPoints[1] : topPoints[0]);
    // top right point
    result.push_back(topPoints[0].x > topPoints[1].x ? topPoints[0] : topPoints[1]);
    // bottom right point
    result.push_back(bottomPoints[0].x > bottomPoints[1].x ? bottomPoints[1] : bottomPoints[0]);
    // bottom left point
    result.push_back(bottomPoints[0].x > bottomPoints[1].x ? bottomPoints[0] : bottomPoints[1]);
    
    return result;
}

+ (cv::Point) getMassCenter: (std::vector<cv::Point2f>) points {
    double xSum = 0;
    double ySum = 0;
    
    for (size_t i = 0; i < points.size(); i++) {
        Point2f p = points[i];
        
        xSum += p.x;
        ySum += p.y;
    }
    
    return cv::Point(xSum / points.size(), ySum / points.size());
}
@end
