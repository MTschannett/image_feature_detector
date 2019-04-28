import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image_feature_detector/entity/contour.dart';

import 'entity/image_dimensions.dart';

export './entity/contour.dart';
export './relative_coordinate_helper.dart';
export './entity/image_dimensions.dart';

class ImageFeatureDetector {
  static const MethodChannel _channel =
      const MethodChannel('image_feature_detector');

  static Future<String> get getVersionString async {
    final String version = await _channel.invokeMethod('getVersionString');
    return version;
  }

  static Future<Contour> detectRectangles(String filePath) async {
    String data = await _channel
        .invokeMethod<String>("detectRectangles", {"filePath": filePath});

    if (data != null) {
      return Contour.fromJson(json.decode(data));
    }

    return Contour([], ImageDimensions(0, 0));
  }
}
