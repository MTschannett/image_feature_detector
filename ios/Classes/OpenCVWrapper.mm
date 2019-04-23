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

    source = [self _grayScale:source];
    source = [self _gaussianBlur:source];
    source = [self _adaptiveThreshold:source];
    
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
            
            point[@"x"] = [[NSNumber alloc] initWithDouble: p.x];
            point[@"y"] = [[NSNumber alloc] initWithDouble: p.y];
            
            [points addObject: point];
        }
        
        NSMutableDictionary *contour = [[NSMutableDictionary alloc] init];
        [contour setObject:points forKey: @"contour"];
    
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: contour options:NSJSONWritingPrettyPrinted error:&err];
        
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return NULL;
}

+ (cv::Mat) _grayScale:(cv::Mat)source {
    Mat result = Mat(source.rows, source.cols, CV_8UC1);
    
    cvtColor(source, result, COLOR_BGR2GRAY);
    
    return result;
}

+ (cv::Mat) _loadImage:(NSString *) path {
    UIImage *source = [UIImage imageWithContentsOfFile: path];
    
    if (source == nil) {
        NSException *exception = [NSException
                                  exceptionWithName:@"File Not Found"
                                  reason: @"Image seems to be empty or not existent"
                                  userInfo: nil];
        
        @throw exception;
    }
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(source.CGImage);
    CGFloat cols = source.size.width;
    CGFloat rows = source.size.height;
    
    Mat result(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(result.data, cols, rows, 8, result.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), source.CGImage);
    CGContextRelease(contextRef);
    
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
    Mat result = Mat(source.rows, source.cols, CV_8UC1);
    cv::Size s = cv::Size(3, 3);
    
    GaussianBlur(source, result, s , 0);
    
    return result;
}

+ (cv::Mat) _adaptiveThreshold:(Mat)source {
    Mat result = Mat(source.rows, source.cols, CV_8UC1);
    
    adaptiveThreshold(source, result,255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY_INV, 15, 2);
    return result;
}
@end
