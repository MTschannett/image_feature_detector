package com.matas.image_feature_detector;

import org.bytedeco.javacpp.Loader;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

// Needed for migration
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;

/**
 * ImageFeatureDetectorPlugin
 */
public class ImageFeatureDetectorPlugin implements MethodCallHandler, FlutterPlugin {

  // Create private variables
  // in order to also work with pre 1.12 android versions.
  private Context applicationContext;
  private MethodChannel channel;

  /**
   * Registers the Plugin.
   */
  private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
    Loader.load(org.bytedeco.javacpp.opencv_java.class);

    channel = new MethodChannel(messenger, "image_feature_detector");
    channel.setMethodCallHandler(new ImageFeatureDetectorPlugin());
  }

  /**
   * Plugin registration.
   * 
   * @see https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration#upgrade-steps
   * @deprecated
   */
  @SuppressWarnings("deprecation")
  public static void registerWith(Registrar registrar) {
    final ImageFeatureDetectorPlugin instance = new ImageFeatureDetectorPlugin();
    instance.onAttachedToEngine(registrar.context(), registrar.messenger());
  }

  /**
   * Plugin registration. For post 1.12 Android projects.
   */
  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
    applicationContext = null;
    channel.setMethodCallHandler(null);
    channel = null;
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
      result.success(ImageDetector.detectRectangles((String) call.argument("filePath")));
    case "detectAndTransformRectangle":
      result.success(ImageDetector.detectAndTransformRectangleInImage((String) call.argument("filePath")));
    default:
      result.notImplemented();
    }
  }
}
