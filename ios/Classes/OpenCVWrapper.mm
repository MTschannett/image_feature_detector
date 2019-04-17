//
//  OpenCVWrapper.m
//  image_feature_detector
//
//  Created by Marco Tschannett on 17.04.19.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

using namespace cv;
using namespace std;

class Contour {
public: string point;
};

@implementation OpenCVWrapper
+ (NSString *)getVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (NSString *) getBuildInformation {
    return @"Just a placeholder";
}

+ (NSString *) findImageContour:(NSString *) path {
    cv::Mat source =[OpenCVWrapper _loadImage:path];
    
    source = [OpenCVWrapper _grayScale:source];
    source = [OpenCVWrapper _gaussianBlur:source];
    source = [OpenCVWrapper _adaptiveThreshold:source];
    
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    
    findContours(source, contours, hierarchy, cv::RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    double maxArea = 0;
    vector<cv::Point> maxContour;
    
    for(size_t i = 0; i < contours.size(); i++) {
        double area = contourArea(contours[i]);
        
        if (area > maxArea) {
            maxArea = area;
            maxContour = contours[i];
        }
    }
    
    if (maxContour.empty()) {
        return {};
    }
    vector<cv::Point> approx;
    double peri = arcLength(maxContour, true);
    
    approxPolyDP(maxContour, approx, 0.04 * peri, true);
    
    if (!approx.empty() || approx.size() == 4) {
        // NSMutableDictionary *points = [[NSMutableDictionary alloc] init];
        NSMutableArray<NSMutableDictionary *> *points = [[NSMutableArray alloc] init];
        
        for(size_t j = 0; j < approx.size(); j++) {
            cv::Point p = approx[j];
            NSMutableDictionary *point = [[NSMutableDictionary alloc] init];
            
            point[@"x"] = [NSString stringWithFormat: @"%d", p.x];
            point[@"y"] = [NSString stringWithFormat: @"%d", p.y];
            
            [points addObject: point];
        }
        
        NSMutableDictionary *contour = [[NSMutableDictionary alloc] init];
        [contour setObject:points forKey: @"points"];
    
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: contour options:NSJSONWritingPrettyPrinted error:&err];
        
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return NULL;
}

+ (cv::Mat) _grayScale:(cv::Mat)source {
    Mat result;
    
    cvtColor(source, result, COLOR_BGR2GRAY);
    
    return result;
}

+ (cv::Mat) _loadImage:(NSString *) path {
    UIImage *source = [UIImage imageWithContentsOfFile:path];
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC1);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bitsPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context  = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bitsPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

+ (UIImage *) _matToImage:(cv::Mat) source {
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    
    CGImageRef image = CGImageCreate(source.cols
                                     , source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *result = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}

+ (cv::Mat) _gaussianBlur:(Mat)source {
    Mat result(source.rows, source.cols, CV_8UC1);
    cv::Size s = cv::Size(3, 3);
    
    GaussianBlur(source, result, s , 0);
    
    return result;
}

+ (cv::Mat) _adaptiveThreshold:(Mat)source {
    Mat result(source.rows, source.cols, CV_8UC1);
    
    adaptiveThreshold(source, result,255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY_INV, 15, 2);
    return result;
}
@end
