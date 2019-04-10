package com.matas.image_feature_detector;

import org.bytedeco.javacpp.Loader;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ImageFeatureDetectorPlugin
 */
public class ImageFeatureDetectorPlugin implements MethodCallHandler {
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    Loader.load(org.bytedeco.javacpp.opencv_java.class);

    final MethodChannel channel = new MethodChannel(registrar.messenger(), "image_feature_detector");
    channel.setMethodCallHandler(new ImageFeatureDetectorPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "getVersionString":
        result.success(ImageDetector.getVersionString());
        break;
      case "getBuildInformation":
        result.success(ImageDetector.getBuildInformation());
        break;
      case "detectRectangles":
        String path = call.argument("filePath");
        try {
          result.success(ImageDetector.detectRectangles(path));
        } catch (Exception e) {
          result.error("error happened", e.getMessage(), e);
        }
      default:
        result.notImplemented();

    }
  }
}
