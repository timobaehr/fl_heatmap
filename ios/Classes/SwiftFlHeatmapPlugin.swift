import Flutter
import UIKit

public class SwiftFlHeatmapPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fl_heatmap", binaryMessenger: registrar.messenger())
    let instance = SwiftFlHeatmapPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("not implemented")
  }
}
