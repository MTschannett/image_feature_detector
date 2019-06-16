//
//  RectFinder.m
//  image_feature_detector
//
//  Created by Marco Tschannett on 16.06.19.
//

#import "RectFinder.h"
#include "opencv2/imgproc/imgproc.hpp"
#import "ImageHelper.h"

using namespace cv;
using namespace std;

@implementation RectFinder
+ (vector<cv::Point2f>) findRectangle: (cv::Mat) src {
    double ratio = 600.0 / MAX(src.cols, src.rows);
    cv::Size downscaledSize =  cv::Size(src.cols * ratio, src.rows * ratio);
    cv::Mat downscaled = cv::Mat(downscaledSize, src.type());
    resize(src, downscaled, downscaledSize);
    
    UIImage *i = [ImageHelper matToImage:downscaled];
    
    vector<vector<cv::Point2f>> rectangles = [self findAllRectangles:downscaled];
    
    if (rectangles.size() == 0) {
        return vector<Point2f>();
    }
    
    auto it =  max_element(rectangles.begin(), rectangles.end(), [](const vector<Point2f> v1, const vector<Point2f> v2) {
        double area1 = contourArea(v1);
        double area2 = contourArea(v2);
        
        return area1 > area2;
    });
    
    vector<cv::Point2f> largest =  (*it);
    
    vector<cv::Point2f> result = [self scaleRectangle:largest withScale:ratio];
    
    return result;
}

+ (vector<vector<cv::Point2f>>) findAllRectangles: (cv::Mat) src {
//    cv::Mat s = src;
//    s = [self _grayScale:s];
//    UIImage *i = [ImageHelper matToImage:s];
//    s = [self _gaussianBlur:s];
//    UIImage *a = [ImageHelper matToImage:s];
//    s = [self _cannyEdgeDetect:s];
//    UIImage *d = [ImageHelper matToImage:s];
    
    cv::Mat grey = cv::Mat();
    cvtColor(src, grey, COLOR_BGR2GRAY);
    
    cv::Mat blur = Mat(grey.size(), CV_8U);
    GaussianBlur(grey, blur, cv::Size(5,5), 0);
    
    cv::Mat edged = Mat(blur.size(), CV_8U);
    Canny(blur, edged, 75, 200);
    
    UIImage *i = [ImageHelper matToImage:edged];
    
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    
    findContours(edged, contours, hierarchy, cv::RETR_LIST, CHAIN_APPROX_SIMPLE);
    
    vector<vector<cv::Point2f>> rectangles;
    
    for(size_t i = 0; i < contours.size(); i++) {
        vector<cv::Point2f> c = [RectFinder convertPointstoPoint2fVector:contours[i]];
        vector<cv::Point2f> approx;
        double peri = arcLength(c, true);
        
        approxPolyDP(c, approx, 0.02 * peri, true);
        
        if (approx.size() == 4 && isContourConvex(c)) {
            rectangles.push_back(approx);
        }
    }
    
    return rectangles;
}

+ (std::vector<Point2f>) convertPointstoPoint2fVector: (std::vector<cv::Point>) points {
    std::vector<Point2f> result;
    
    for(size_t i = 0; i < points.size(); i++) {
        cv::Point p = points[i];
        
        result.push_back(Point2f(p.x * 1.0, p.y * 1.0));
    }
    
    return result;
}

+ (cv::Mat) _gaussianBlur:(Mat)source {
    Mat result = Mat(source.rows, source.cols, CV_8U);
    cv::Size s = cv::Size(5,5);
    
    GaussianBlur(source, result, s , 0);
    
    return result;
}

+ (Mat) _cannyEdgeDetect:(Mat) source {
    Mat result = Mat(source.rows, source.cols, CV_8U);
    
    Canny(source, result, 75, 200);
    
    return result;
}

+ (cv::Mat) _grayScale:(cv::Mat)source {
    Mat result = Mat(source.rows, source.cols, CV_8U);
    
    cvtColor(source, result, COLOR_BGR2GRAY);
    
    return result;
}

+ (std::vector<cv::Point2f>) scaleRectangle: (std::vector<cv::Point2f>) points withScale:(double) scale {
    vector<cv::Point2f> result;
    
    for(size_t i = 0; i < points.size(); i++) {
        Point2f p = points[i];
        result.push_back(Point2f(p.x * scale, p.y * scale));
    }
    
    return result;
}
@end
