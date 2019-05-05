#import "ImageFeatureDetectorPlugin.h"
#import "OpenCVWrapper.h"


@implementation ImageFeatureDetectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"image_feature_detector"
            binaryMessenger:[registrar messenger]];
  ImageFeatureDetectorPlugin* instance = [[ImageFeatureDetectorPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getVersionString" isEqualToString:call.method]) {
    result([OpenCVWrapper getVersionString]);
  } else if([@"getBuildInformation" isEqualToString: call.method]){
      result([OpenCVWrapper getBuildInformation]);
  } else if([@"detectRectangles" isEqualToString:call.method]){
      NSString * path = call.arguments[@"filePath"];
      result([OpenCVWrapper findImageContour: path]);
  } else if([@"detectAndTransformRectangle" isEqualToString:call.method]) {
      result([OpenCVWrapper detectAndTransformRectangleInImage: call.arguments[@"filePath"]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
