//
//  ImageHelper.h
//  image_feature_detector
//
//  Created by Marco Tschannett on 28.04.19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageHelper : NSObject
+ (UIImage *) adjustImageOrientationWithExif: (UIImage *) image;
@end

NS_ASSUME_NONNULL_END
