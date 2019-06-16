//
//  ImageHelper.h
//  image_feature_detector
//
//  Created by Marco Tschannett on 28.04.19.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

NS_ASSUME_NONNULL_BEGIN

@interface ImageHelper : NSObject
+ (UIImage *) adjustImageOrientationWithExif: (UIImage *) image;
+ (cv::Mat) loadImage:(NSString *) path;
+ (UIImage *) matToImage:(cv::Mat) source;
@end

NS_ASSUME_NONNULL_END
