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
#import "ImageHelper.h"
#import "PointsHelper.h"
#include "math.h"

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

+ (NSString *) detectAndTransformRectangleInImage: (NSString *) path {
    Mat source = [OpenCVWrapper _loadImage: path];
    
    vector<cv::Point> maxApprox = [OpenCVWrapper findContourInImage:source];
    
    if (maxApprox.empty()) {
        return NULL;
    }
    
    vector<cv::Point> temp = maxApprox;
    cv::Point2f src[4], dest[4];
    
    [PointsHelper sortPoints:temp withList:src];
    
    cv::Point2f tl = src[0];
    cv::Point2f tr = src[1];
    cv::Point2f br = src[2];
    cv::Point2f bl = src[3];
    
    
    double widthA = sqrt(pow((br.x - bl.x), 2) + pow(br.y - bl.y, 2));
    double widthB = sqrt(pow(tr.x - tl.y, 2) + pow(tr.y - tl.y, 2));
    int maxWidth = (int)fmax(widthA, widthB);
    
    double heightA = sqrt(pow(tr.x - br.x, 2) + pow(tr.y - br.y, 2));
    double heightB = sqrt(pow(tl.x - bl.x, 2) + pow(tl.y - bl.y, 2));;
    int maxHeight = (int)fmax(heightA, heightB);
    
    dest[0] = cv::Point2f(0, 0);
    
    dest[1] = cv::Point2f(maxWidth -1, 0);
    dest[2] = cv::Point2f(maxWidth -1, maxHeight -1);
    dest[3] = cv::Point2f(0, maxHeight -1);
    
    Mat matrix = getPerspectiveTransform(src, dest);
    Mat destination = cv::Mat(maxWidth, maxHeight, CV_8UC4);
    warpPerspective(source, destination, matrix, cv::Size(maxWidth, maxHeight));
    
    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    NSString *fileName = [NSString stringWithFormat: @"transformed-image%@.png", timestamp];
    
    NSString *outputPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent: fileName];
    UIImage *image = [OpenCVWrapper _matToImage:destination];
    NSData *binaryImageData = UIImagePNGRepresentation(image);
    
    [binaryImageData writeToFile:outputPath atomically:YES];
    
    NSMutableDictionary *resultData = [[NSMutableDictionary alloc] init];
    resultData[@"filePath"] = outputPath;
    resultData[@"foundFeatures"] = [OpenCVWrapper serializeContour:maxApprox image:source];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultData options:NSJSONWritingPrettyPrinted error:&err];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)  findImageContour:(NSString *) path {
    cv::Mat source =[OpenCVWrapper _loadImage:path];

    vector<cv::Point> maxApprox = [OpenCVWrapper findContourInImage:source];
    
    if (maxApprox.empty()) {
        return NULL;
    }
    
    NSDictionary *contour =  [OpenCVWrapper serializeContour:maxApprox image:source];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: contour options:NSJSONWritingPrettyPrinted error:&err];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (std::vector<cv::Point>) findContourInImage: (cv::Mat)source {
    cv::Mat s = source;
    s = [self _grayScale:s];
    s = [self _transformSobel:s];
    s = [self _cannyEdgeDetect:s];
    s = [self _gaussianBlur:s];
    
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    
    findContours(s, contours, hierarchy, cv::RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    double maxArea = 0;
    vector<cv::Point> maxContour;
    vector<cv::Point> maxApprox;
    
    for(size_t i = 0; i < contours.size(); i++) {
        vector<cv::Point> approx;
        double peri = arcLength(contours[i], true);
        
        approxPolyDP(contours[i], approx, 0.04 * peri, true);
        if (approx.size() == 4) {
            
            double area = contourArea(contours[i]);
            
            if (area > maxArea) {
                maxArea = area;
                maxContour = contours[i];
                maxApprox = approx;
            }
        }
    }
    
    return maxApprox;
}

+ (NSMutableDictionary*) serializeContour: (std::vector<cv::Point>) maxApprox image:(cv::Mat) source {
    NSMutableArray<NSMutableDictionary*> *points = [[NSMutableArray alloc] init];
    
    for(size_t j = 0; j < maxApprox.size(); j++) {
        cv::Point p = maxApprox[j];
        NSMutableDictionary *point = [[NSMutableDictionary alloc] init];
        double relativeX = (double)p.x / (double)source.cols;
        double relativeY = (double)p.y / (double)source.rows;
        point[@"x"] = [[NSNumber alloc] initWithDouble: relativeX];
        point[@"y"] = [[NSNumber alloc] initWithDouble: relativeY];
        
        [points addObject: point];
    }
    
    NSMutableDictionary *contour = [[NSMutableDictionary alloc] init];
    [contour setObject:points forKey: @"contour"];
    
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc] init];
    [dimensions setObject: [NSNumber numberWithInteger: source.cols] forKey:@"width"];
    [dimensions setObject: [NSNumber numberWithInteger:source.rows] forKey: @"height"];
    
    [contour setObject:dimensions forKey: @"dimensions"];
    
    return contour;
}

+ (cv::Mat) _grayScale:(cv::Mat)source {
    Mat result = Mat(source.rows, source.cols, CV_8UC1);
    
    cvtColor(source, result, COLOR_BGR2GRAY);
    
    return result;
}

+ (cv::Mat) _loadImage:(NSString *) path {
    UIImage *source = [UIImage imageWithContentsOfFile: path];
    
    source = [ImageHelper adjustImageOrientationWithExif:source];
    
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

+ (cv::Mat) _transformSobel:(cv::Mat)source {
    int width = source.cols;
    int height = source.rows;
    
    Mat destination = Mat(width, height, CV_8UC1);
    
    Mat sobelX  =Mat(width, height, CV_8UC1);
    Mat sobelY = Mat(width, height, CV_8UC1);
    Mat absSobelX = Mat(width, height, CV_8UC1);
    Mat absSobelY = Mat(width, height, CV_8UC1);
    
    Sobel(source, sobelX, CV_16S, 1, 0);
    Sobel(source, sobelY, CV_16S, 0, 1);
    
    convertScaleAbs(sobelX, absSobelX);
    convertScaleAbs(sobelY, absSobelY);
    
    addWeighted(absSobelX, 0.5, absSobelY, 0.5, 0, destination);
    
    return destination;
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

+ (Mat) _cannyEdgeDetect:(Mat) source {
    Mat result = Mat(source.rows, source.cols, CV_8UC1);
    
    Canny(source, result, 10, 100);
    
    return result;
}
@end
