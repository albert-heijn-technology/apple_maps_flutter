import Flutter
import UIKit

public class SwiftAppleMapsFlutterPlugin: NSObject, FlutterPlugin {
    var factory: AppleMapViewFactory
    public init(with registrar: FlutterPluginRegistrar) {
        factory = AppleMapViewFactory(withRegistrar: registrar)
        registrar.register(factory, withId: "plugins.flutter.io/apple_maps")
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.addApplicationDelegate(SwiftAppleMapsFlutterPlugin(with: registrar))
    }
}
