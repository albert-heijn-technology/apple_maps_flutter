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


public class AppleMapController :NSObject, FlutterPlatformView, MKMapViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var mapView: MKMapView!
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    var annotationController :AnnotationController
    
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
        annotationController = AnnotationController(mapView: mapView, channel: channel)
        super.init()
        
        if let annotationsToAdd :NSArray = args["markersToAdd"] as? NSArray {
            annotationController.annotationsToAdd(annotations: annotationsToAdd)
        }
        initialiseTapGestureRecognizers()
        if #available(iOS 9.0, *) {
            mapView.setCamera(cameraPosition(positionData: args["initialCameraPosition"]! as! Dictionary<String, Any>)!, animated: false)
            interprateOptions(options: args["options"] as! Dictionary<String, Any>)
        } else {
            // Fallback on earlier versions
        }
        mapView.delegate = self
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
        if let isCompassEnabled :Any = options["compassEnabled"]  {
            let _isCompassEnabled :Bool = JsonConversion.toBool(jsonBool: isCompassEnabled as! NSNumber)
            mapView.showsCompass = _isCompassEnabled
        }
        
        if let mapType :Any = options["mapType"] {
            let _mapType :Int = JsonConversion.toInt(jsonInt : mapType as! NSNumber)
            mapView.mapType = mapTypes[_mapType]
        }
        
        if let trafficEnabled :Any = options["trafficEnabled"] {
            let _trafficEnabled :Bool = JsonConversion.toBool(jsonBool: trafficEnabled as! NSNumber)
            mapView.showsTraffic = _trafficEnabled
            
        }
        
        if let rotateGesturesEnabled :Any = options["rotateGesturesEnabled"] {
            let _rotateGesturesEnabled :Bool = JsonConversion.toBool(jsonBool: rotateGesturesEnabled as! NSNumber)
            mapView.isRotateEnabled = _rotateGesturesEnabled
        }
        
        if let scrollGesturesEnabled :Any = options["scrollGesturesEnabled"] {
            let _scrollGesturesEnabled :Bool = JsonConversion.toBool(jsonBool:scrollGesturesEnabled as! NSNumber)
            mapView.isScrollEnabled = _scrollGesturesEnabled
        }
        
        if let pitchGesturesEnabled :Any = options["pitchGesturesEnabled"] {
            let _pitchGesturesEnabled :Bool = JsonConversion.toBool(jsonBool: pitchGesturesEnabled as! NSNumber)
            mapView.isPitchEnabled = _pitchGesturesEnabled
        }
        
        if let zoomGesturesEnabled :Any = options["zoomGesturesEnabled"] {
            let _zoomGesturesEnabled :Bool = JsonConversion.toBool(jsonBool: zoomGesturesEnabled as! NSNumber)
            mapView.isZoomEnabled = _zoomGesturesEnabled
        }
        
        
        if let myLocationEnabled :Any = options["myLocationEnabled"] {
            let _myLocationEnabled :Bool = JsonConversion.toBool(jsonBool: myLocationEnabled as! NSNumber)
            setUserLocation(myLocationEnabled: _myLocationEnabled)
        }
        
        if let myLocationButtonEnabled :Any = options["myLocationButtonEnabled"] {
            let _myLocationButtonEnabled :Bool = JsonConversion.toBool(jsonBool: myLocationButtonEnabled as! NSNumber)
            mapTrackingButton(isVisible: _myLocationButtonEnabled)
        }
        
        if let userTackingMode :Any = options["trackingMode"] {
            let _userTackingMode :Int = JsonConversion.toInt(jsonInt: userTackingMode as! NSNumber)
            mapView.setUserTrackingMode(userTrackingModes[_userTackingMode], animated: false)
        }
    }
    
    public func setUserLocation(myLocationEnabled :Bool) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() ==   .authorizedWhenInUse {
            if (myLocationEnabled) {
                locationManager.requestWhenInUseAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.distanceFilter = kCLDistanceFilterNone
                locationManager.startUpdatingLocation()
            } else {
                locationManager.stopUpdatingLocation()
            }
            mapView.showsUserLocation = myLocationEnabled
        }
    }
    
    
    // on idle? check for animation
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        channel.invokeMethod("camera#onIdle", arguments: "")
    }
    
    // onMoveStarted
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        channel.invokeMethod("camera#onMoveStarted", arguments: "")
    }
    
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)  {
        if let annotation :FlutterAnnotation = view.annotation as? FlutterAnnotation  {
            annotationController.onAnnotationClick(annotation: annotation)
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else if let flutterAnnotation = annotation as? FlutterAnnotation {
            return getAnnotationView(annotation: flutterAnnotation)
        }
        return nil
    }
    
    private func getAnnotationView(annotation: FlutterAnnotation) -> MKAnnotationView{
        let identifier :String = annotation.id
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        annotationView!.alpha = CGFloat(annotation.alpha ?? 1.00)
        annotationView!.isDraggable = annotation.isDraggable ?? false
        return annotationView!
    }
    
    
    
    private func initialiseTapGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onMapGesture))
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onMapGesture))
        pinchGesture.delegate = self
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(onMapGesture))
        rotateGesture.delegate = self
        let tiltGesture = UISwipeGestureRecognizer(target: self, action: #selector(onMapGesture))
        tiltGesture.numberOfTouchesRequired = 2
        tiltGesture.direction = .up
        tiltGesture.direction = .down
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: nil)
        doubleTapGesture.numberOfTapsRequired = 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGesture.require(toFail: doubleTapGesture)  // Make sure to not detect double taps, as they are used for zooming.
        mapView.addGestureRecognizer(panGesture)
        mapView.addGestureRecognizer(pinchGesture)
        mapView.addGestureRecognizer(rotateGesture)
        mapView.addGestureRecognizer(tiltGesture)
        mapView.addGestureRecognizer(longTapGesture)
        mapView.addGestureRecognizer(doubleTapGesture)
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func onMapGesture(sender: UIGestureRecognizer) {
        let locationInView = sender.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        let distance = mapView.camera.altitude
        let pitch = mapView.camera.pitch
        let heading = mapView.camera.heading
        channel.invokeMethod("camera#onMove", arguments: ["position": ["heading": heading, "target":  [locationOnMap.latitude, locationOnMap.longitude], "pitch": pitch, "distance": distance]])
    }

    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            channel.invokeMethod("map#onLongPress", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
        }
    }
    
    @objc func onTap(sender: UIGestureRecognizer){
        let locationInView = sender.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        channel.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
    }
    
    func mapTrackingButton(isVisible visible: Bool){
        if (visible) {
            let image = UIImage(named: "outline_near_me")
            let locationButton = UIButton(type: UIButtonType.custom) as UIButton
            locationButton.tag = 100
            locationButton.layer.cornerRadius = 5
            locationButton.frame = CGRect(origin: CGPoint(x: 300 - 45, y: 5), size: CGSize(width: 40, height: 40))
            locationButton.setImage(image, for: .normal)
            locationButton.backgroundColor = .white
            locationButton.addTarget(self, action: #selector(centerMapOnUserButtonClicked), for:.touchUpInside)
            mapView.addSubview(locationButton)
        } else {
            if let _locationButton = mapView.viewWithTag(100) {
                _locationButton.removeFromSuperview()
            }
        }
       
    }
    
   
    @objc func centerMapOnUserButtonClicked() {
        self.mapView.setUserTrackingMode( MKUserTrackingMode.follow, animated: true)
    }
    
    public func view() -> UIView {
        channel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult) -> Void in
            let args :Dictionary<String, Any> = call.arguments as! Dictionary<String,Any>
            switch(call.method){
            case "markers#update":
                self.annotationController.annotationsToAdd(annotations: args["markersToAdd"]! as! NSArray)
                self.annotationController.annotationsToChange(annotations: args["markersToChange"] as! NSArray)
                self.annotationController.annotationsIdsToRemove(annotationIds: args["markerIdsToRemove"] as! NSArray)
            case "map#setStyle":
                print("styyyyyle")
            case "map#update":
                if #available(iOS 9.0, *) {
                    self.interprateOptions(options: args["options"] as! Dictionary<String, Any>)
                } else {
                    result(FlutterError(code: "404", message: "Only available on iOS 9 or newer s", details: ""))
                }
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        return mapView
    }
    
    // Always allow multiple gestureRecognizers
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            return true
    }
}
