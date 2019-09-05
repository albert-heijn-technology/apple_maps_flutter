//
//  AppleMapController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 03.09.19.
//

import Foundation
import MapKit
import CoreLocation

public class AppleMapViewFactory: NSObject, FlutterPlatformViewFactory {
    
    var registrar: FlutterPluginRegistrar?
    
    public init(withRegistrar registrar: FlutterPluginRegistrar){
        super.init()
        self.registrar = registrar
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let argsDictionary =  args as! Dictionary<String, Any>
        
        return AppleMapController(withFrame: CGRect(x: 0, y: 0,width: 0, height: 0), withRegistrar: registrar!, withargs: argsDictionary ,withId: viewId)
        
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec(readerWriter: FlutterStandardReaderWriter())
    }
}


public class AppleMapController :NSObject,FlutterPlatformView {
    @IBOutlet var mapView: MKMapView!
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    
    let mapTypes: Array<MKMapType> = [
        MKMapType.standard,
        MKMapType.satellite,
        MKMapType.hybrid,
    ]
    
    let userTrackingModes: Array<MKUserTrackingMode> = [
        MKUserTrackingMode.none,
        MKUserTrackingMode.follow,
        MKUserTrackingMode.followWithHeading,
    ]
    
    public init(withFrame frame: CGRect, withRegistrar registrar: FlutterPluginRegistrar, withargs args: Dictionary<String, Any> ,withId id: Int64){
        self.registrar = registrar
        self.mapView = MKMapView(frame: frame)
        channel = FlutterMethodChannel(name: "plugins.flutter.io/apple_maps_\(id)", binaryMessenger: registrar.messenger())
        super.init()
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = userCoordinate
//        mapView.addAnnotation(annotation)
        

        if #available(iOS 9.0, *) {
            mapView.setCamera(cameraPosition(positionData: args["initialCameraPosition"]! as! Dictionary<String, Any>)!, animated: false)
            interprateOptions(options: args["options"] as! Dictionary<String, Any>)
        } else {
            // Fallback on earlier versions
        }

        print(args)
    }
    
    @available(iOS 9.0, *)
    private func cameraPosition(positionData: Dictionary<String, Any>) -> MKMapCamera? {
        let targetList :Array<CLLocationDegrees> = positionData["target"]! as! Array<CLLocationDegrees>
        let distance :CLLocationDistance =  positionData["distance"]! as! CLLocationDistance
        let pitch :CGFloat = positionData["pitch"]! as! CGFloat
        let heading :CLLocationDirection = positionData["heading"]! as! CLLocationDirection
        let userCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:  targetList[0], longitude: targetList[1])
        let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromDistance: distance, pitch: pitch, heading: heading)
        return mapCamera
    }
    
    @available(iOS 9.0, *)
    private func interprateOptions(options: Dictionary<String, Any>) {
        print(options)
        let isCompassEnabled :Bool = JsonConversion.toBool(jsonBool: options["compassEnabled"] as! NSNumber)
        mapView.showsCompass = isCompassEnabled
        
        let mapType :Int = JsonConversion.toInt(jsonInt : options["mapType"] as! NSNumber)
        mapView.mapType = mapTypes[mapType]
        
        let trafficEnabled :Bool = JsonConversion.toBool(jsonBool: options["trafficEnabled"] as! NSNumber)
        mapView.showsTraffic = trafficEnabled
        
        let rotateGesturesEnabled :Bool = JsonConversion.toBool(jsonBool: options["rotateGesturesEnabled"] as! NSNumber)
        mapView.isRotateEnabled = rotateGesturesEnabled
        
        let scrollGesturesEnabled :Bool = JsonConversion.toBool(jsonBool: options["scrollGesturesEnabled"] as! NSNumber)
        mapView.isScrollEnabled = scrollGesturesEnabled
        
        let pitchGesturesEnabled :Bool = JsonConversion.toBool(jsonBool: options["pitchGesturesEnabled"] as! NSNumber)
        mapView.isPitchEnabled = pitchGesturesEnabled
        
        let zoomGesturesEnabled :Bool = JsonConversion.toBool(jsonBool: options["zoomGesturesEnabled"] as! NSNumber)
        mapView.isZoomEnabled = zoomGesturesEnabled
        
        let myLocationEnabled :Bool = JsonConversion.toBool(jsonBool: options["myLocationEnabled"] as! NSNumber)
        setUserLocation(myLocationEnabled: myLocationEnabled)
        
        let userTackingMode :Int = JsonConversion.toInt(jsonInt: options["trackingMode"] as! NSNumber)
        mapView.setUserTrackingMode(userTrackingModes[userTackingMode], animated: false)
    }
    
    public func setUserLocation(myLocationEnabled :Bool) {
        if (myLocationEnabled) {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            
            mapView.showsUserLocation = myLocationEnabled
        }
    }
 
    
    public func view() -> UIView {
        return mapView
    }
}
