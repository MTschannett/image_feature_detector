import Flutter
import UIKit

public class SwiftImageFeatureDetectorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "image_feature_detector", binaryMessenger: registrar.messenger())
    let instance = SwiftImageFeatureDetectorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    ImageFeatureDetectorPlugin.openCVVersionString()
    result("iOS " + UIDevice.current.systemVersion)
  }
}
