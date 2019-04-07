import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_feature_detector/image_feature_detector.dart';

void main() {
  const MethodChannel channel = MethodChannel('image_feature_detector');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ImageFeatureDetector.getVersionString, '42');
  });
}
