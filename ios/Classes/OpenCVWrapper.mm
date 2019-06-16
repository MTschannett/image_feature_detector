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
#import "RectFinder.h"
#import "PerspectiveTransformation.h"
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
    // TODO: Make this...
    return @"Just a placeholder";
}

+ (NSString *) detectAndTransformRectangleInImage: (NSString *) path {
    Mat source = [ImageHelper loadImage: path];
    
    vector<Point2f> rectangle = [RectFinder findRectangle:source];
    
    if (rectangle.empty()) {
        return NULL;
    }
    
    Mat destination = [PerspectiveTransformation transform:source withRectangle:rectangle];
    
    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    NSString *fileName = [NSString stringWithFormat: @"transformed-image%@.png", timestamp];
    
    NSString *outputPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent: fileName];
    UIImage *image = [ImageHelper matToImage:destination];
    NSData *binaryImageData = UIImagePNGRepresentation(image);
    
    [binaryImageData writeToFile:outputPath atomically:YES];
    
    NSMutableDictionary *resultData = [[NSMutableDictionary alloc] init];
    resultData[@"filePath"] = outputPath;
    resultData[@"foundFeatures"] = [OpenCVWrapper serializeContour:rectangle image:source];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultData options:NSJSONWritingPrettyPrinted error:&err];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)  findImageContour:(NSString *) path {
    cv::Mat source = [ImageHelper loadImage: path];

    vector<Point2f> rectangle = [RectFinder findRectangle:source];
    
    if (rectangle.empty()) {
        return NULL;
    }
    
    NSDictionary *contour =  [OpenCVWrapper serializeContour:rectangle image:source];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: contour options:NSJSONWritingPrettyPrinted error:&err];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSMutableDictionary*) serializeContour: (std::vector<cv::Point2f>) maxApprox image:(cv::Mat) source {
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

@end
