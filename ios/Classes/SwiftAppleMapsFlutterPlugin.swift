import Flutter
import UIKit

public class SwiftAppleMapsFlutterPlugin: NSObject, FlutterPlugin {
    var factory: AppleMapViewFactory
    public init(with registrar: FlutterPluginRegistrar) {
        factory = AppleMapViewFactory(withRegistrar: registrar)
        registrar.register(factory, withId: "apple_maps_plugin.luisthein.de/apple_maps", gestureRecognizersBlockingPolicy:FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.addApplicationDelegate(SwiftAppleMapsFlutterPlugin(with: registrar))
    }
}
