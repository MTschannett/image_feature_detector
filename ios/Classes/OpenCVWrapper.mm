//
//  OpenCVWrapper.m
//  image_feature_detector
//
//  Created by Marco Tschannett on 14.04.19.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>

@implementation OpenCVWrapper
+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}
@end
