#import "ImageFeatureDetectorPlugin.h"
#import <image_feature_detector/image_feature_detector-Swift.h>

@implementation ImageFeatureDetectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImageFeatureDetectorPlugin registerWithRegistrar:registrar];
}
@end
