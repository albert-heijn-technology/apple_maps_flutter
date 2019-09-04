//
//  AppleMapController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 03.09.19.
//

import Foundation
import MapKit

public class AppleMapViewFactory: NSObject, FlutterPlatformViewFactory {
    
    var registrar: FlutterPluginRegistrar?
    
    public init(withRegistrar registrar: FlutterPluginRegistrar){
        super.init()
        self.registrar = registrar
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
//        var dictionary =  args as! Dictionary<String, Double>
        return AppleMapController(withFrame: CGRect(x: 0, y: 0,width: 0, height: 0), withRegistrar: registrar!,withId: viewId)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec(readerWriter: FlutterStandardReaderWriter())
    }
}

public class AppleMapController :NSObject,FlutterPlatformView {
    @IBOutlet var mapView: MKMapView!
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    
    public init(withFrame frame: CGRect, withRegistrar registrar: FlutterPluginRegistrar, withId id: Int64){
        self.registrar = registrar
        self.mapView = MKMapView(frame: frame)
        channel = FlutterMethodChannel(name: "plugins.flutter.io/apple_maps_\(id)", binaryMessenger: registrar.messenger())
    }
    
    
    public func view() -> UIView {
        return mapView
    }
}
