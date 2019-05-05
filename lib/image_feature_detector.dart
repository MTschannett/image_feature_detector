import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image_feature_detector/entity/contour.dart';

import 'entity/image_dimensions.dart';
import 'entity/transformed_image.dart';

export './entity/contour.dart';
export './relative_coordinate_helper.dart';
export './entity/image_dimensions.dart';
export './entity/transformed_image.dart';

/// Entry class to image feature detector
class ImageFeatureDetector {
  static const MethodChannel _channel =
      const MethodChannel('image_feature_detector');

  /// Returns the used version of opencv
  static Future<String> get getVersionString async {
    final String version = await _channel.invokeMethod('getVersionString');
    return version;
  }

  /// Detects a rectangle in a image
  static Future<Contour> detectRectangles(String filePath) async {
    String data = await _channel
        .invokeMethod<String>("detectRectangles", {"filePath": filePath});

    if (data != null) {
      return Contour.fromJson(json.decode(data));
    }

    return Contour([], ImageDimensions(0, 0));
  }

  /// Detects the largest contour and returns a perspective transformed image of that area
  static Future<TransformedImage> detectAndTransformRectangle(
      String filePath) async {
    String data = await _channel
        .invokeMethod("detectAndTransformRectangle", {"filePath": filePath});

    if (data != null) {
      return TransformedImage.fromJson(json.decode(data));
    }

    return new TransformedImage(Contour(null, null), "");
  }
}
