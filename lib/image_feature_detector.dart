import 'dart:async';

import 'package:flutter/services.dart';

class ImageFeatureDetector {
  static const MethodChannel _channel =
      const MethodChannel('image_feature_detector');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
