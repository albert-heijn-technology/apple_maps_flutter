//
//  AppleMapController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 03.09.19.
//

import Foundation
import MapKit

public class AppleMapViewFactory: NSObject, FlutterPlatformViewFactory {
    
    var registrar: FlutterPluginRegistrar
    
    public init(withRegistrar registrar: FlutterPluginRegistrar){
        self.registrar = registrar
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let argsDictionary =  args as! Dictionary<String, Any>
        
        return AppleMapController(withFrame: frame, withRegistrar: registrar, withargs: argsDictionary, withId: viewId)
        
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec(readerWriter: FlutterStandardReaderWriter())
    }
}


public class AppleMapController : NSObject, FlutterPlatformView, MKMapViewDelegate {
    var mapView: FlutterMapView!
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    var annotationController: AnnotationController
    var polylineController: PolylineController
    var polygonController: PolygonController
    var circleController: CircleController
    var initialCameraPosition: [String: Any]
    var options: [String: Any]
    var onCalloutTapGestureRecognizer: UITapGestureRecognizer?
    var currentlySelectedAnnotation: String?
    
    public init(withFrame frame: CGRect, withRegistrar registrar: FlutterPluginRegistrar, withargs args: Dictionary<String, Any> ,withId id: Int64) {
        self.options = args["options"] as! [String: Any]
        self.channel = FlutterMethodChannel(name: "apple_maps_plugin.luisthein.de/apple_maps_\(id)", binaryMessenger: registrar.messenger())
        
        self.mapView = FlutterMapView(channel: channel, options: options)
        self.registrar = registrar
        
        self.annotationController = AnnotationController(mapView: mapView, channel: channel, registrar: registrar)
        self.polylineController = PolylineController(mapView: mapView, channel: channel, registrar: registrar)
        self.polygonController = PolygonController(mapView: mapView, channel: channel, registrar: registrar)
        self.circleController = CircleController(mapView: mapView, channel: channel, registrar: registrar)
        self.initialCameraPosition = args["initialCameraPosition"]! as! Dictionary<String, Any>
        
        super.init()
        
        self.mapView.delegate = self
        self.mapView.setCenterCoordinate(initialCameraPosition, animated: false)
        self.setMethodCallHandlers()
        
        if let annotationsToAdd: NSArray = args["annotationsToAdd"] as? NSArray {
            self.annotationController.annotationsToAdd(annotations: annotationsToAdd)
        }
        if let polylinesToAdd: NSArray = args["polylinesToAdd"] as? NSArray {
            self.polylineController.addPolylines(polylineData: polylinesToAdd)
        }
        if let polygonsToAdd: NSArray = args["polygonsToAdd"] as? NSArray {
            self.polygonController.addPolygons(polygonData: polygonsToAdd)
        }
        if let circlesToAdd: NSArray = args["circlesToAdd"] as? NSArray {
            self.circleController.addCircles(circleData: circlesToAdd)
        }
        
        self.onCalloutTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.calloutTapped(_:)))
    }
    
    public func view() -> UIView {
        return mapView
    }
    
    // onIdle
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.channel.invokeMethod("camera#onIdle", arguments: "")
    }
    
    // onMoveStarted
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.channel.invokeMethod("camera#onMoveStarted", arguments: "")
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)  {
        if let annotation :FlutterAnnotation = view.annotation as? FlutterAnnotation  {
            if annotation.infoWindowConsumesTapEvents {
                view.addGestureRecognizer(self.onCalloutTapGestureRecognizer!)
            }
            self.currentlySelectedAnnotation = annotation.id
            self.annotationController.onAnnotationClick(annotation: annotation)
        }
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.currentlySelectedAnnotation = nil
        view.removeGestureRecognizer(self.onCalloutTapGestureRecognizer!)
    }

    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else if let flutterAnnotation = annotation as? FlutterAnnotation {
            return self.annotationController.getAnnotationView(annotation: flutterAnnotation)
        }
        return nil
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is FlutterPolyline {
            return polylineController.polylineRenderer(overlay: overlay)
        } else if overlay is FlutterPolygon {
            return polygonController.polygonRenderer(overlay: overlay)
        } else if overlay is FlutterCircle {
            return circleController.circleRenderer(overlay: overlay)
        }
        return MKOverlayRenderer()
    }
    
    @objc func calloutTapped(_ sender: UITapGestureRecognizer? = nil) {
        if self.currentlySelectedAnnotation != nil {
            self.channel.invokeMethod("infoWindow#onTap", arguments: ["annotationId": self.currentlySelectedAnnotation!])
        }
    }
    
    private func setMethodCallHandlers() {
        channel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult) -> Void in
            if let args :Dictionary<String, Any> = call.arguments as? Dictionary<String,Any> {
                switch(call.method) {
                case "annotations#update":
                    if let annotationsToAdd = args["annotationsToAdd"] as? NSArray {
                        if annotationsToAdd.count > 0 {
                            self.annotationController.annotationsToAdd(annotations: annotationsToAdd)
                        }
                    }
                    if let annotationsToChange = args["annotationsToChange"] as? NSArray {
                        if annotationsToChange.count > 0 {
                            self.annotationController.annotationsToChange(annotations: annotationsToChange)
                        }
                    }
                    if let annotationsToDelete = args["annotationIdsToRemove"] as? NSArray {
                        if annotationsToDelete.count > 0 {
                            self.annotationController.annotationsIdsToRemove(annotationIds: annotationsToDelete)
                        }
                    }
                    result(nil)
                case "annotations#showInfoWindow":
                    self.annotationController.showAnnotation(with: args["annotationId"] as! String)
                case "annotations#hideInfoWindow":
                    self.annotationController.hideAnnotation(with: args["annotationId"] as! String)
                case "annotations#isInfoWindowShown":
                    result(self.annotationController.isAnnotationSelected(with: args["annotationId"] as! String))
                case "polylines#update":
                    if let polylinesToAdd: NSArray = args["polylinesToAdd"] as? NSArray {
                        self.polylineController.addPolylines(polylineData: polylinesToAdd)
                    }
                    if let polylinesToChange: NSArray = args["polylinesToChange"] as? NSArray {
                        self.polylineController.changePolylines(polylineData: polylinesToChange)
                    }
                    if let polylinesToRemove: NSArray = args["polylineIdsToRemove"] as? NSArray {
                        self.polylineController.removePolylines(polylineIds: polylinesToRemove)
                    }
                    result(nil);
                case "polygons#update":
                    if let polyligonsToAdd: NSArray = args["polygonsToAdd"] as? NSArray {
                        self.polygonController.addPolygons(polygonData: polyligonsToAdd)
                    }
                    if let polygonsToChange: NSArray = args["polygonsToChange"] as? NSArray {
                        self.polygonController.changePolygons(polygonData: polygonsToChange)
                    }
                    if let polygonsToRemove: NSArray = args["polygonIdsToRemove"] as? NSArray {
                        self.polygonController.removePolygons(polygonIds: polygonsToRemove)
                    }
                    result(nil);
                case "circles#update":
                    if let circlesToAdd: NSArray = args["circlesToAdd"] as? NSArray {
                        self.circleController.addCircles(circleData: circlesToAdd)
                    }
                    if let circlesToChange: NSArray = args["circlesToChange"] as? NSArray {
                        self.circleController.changeCircles(circleData: circlesToChange)
                    }
                    if let circlesToRemove: NSArray = args["circleIdsToRemove"] as? NSArray {
                        self.circleController.removeCircles(circleIds: circlesToRemove)
                    }
                    result(nil);
                case "map#update":
                    self.mapView.interpretOptions(options: args["options"] as! Dictionary<String, Any>)
                case "camera#animate":
                    let positionData :Dictionary<String, Any> = self.toPositionData(data: args["cameraUpdate"] as! Array<Any>, animated: true)
                    if !positionData.isEmpty {
                        guard let _ = positionData["moveToBounds"] else {
                            self.mapView.setCenterCoordinate(positionData, animated: true)
                            return
                        }
                        self.mapView.setBounds(positionData, animated: true)
                    }
                    result(nil)
                case "camera#move":
                    let positionData :Dictionary<String, Any> = self.toPositionData(data: args["cameraUpdate"] as! Array<Any>, animated: false)
                    if !positionData.isEmpty {
                        guard let _ = positionData["moveToBounds"] else {
                            self.mapView.setCenterCoordinate(positionData, animated: false)
                            return
                        }
                        self.mapView.setBounds(positionData, animated: false)
                    }
                    result(nil)
                case "camera#convert":
                    guard let annotation = args["annotation"] as? Array<Double> else {
                        result(nil)
                        return
                    }
                    let point = self.mapView.convert(CLLocationCoordinate2D(latitude: annotation[0] , longitude: annotation[1]), toPointTo: self.view())
                    result(["point": [point.x, point.y]])
                default:
                    result(FlutterMethodNotImplemented)
                    return
                }
            } else {
                switch call.method {
                case "map#getVisibleRegion":
                    result(self.mapView.getVisibleRegion())
                case "map#isCompassEnabled":
                    if #available(iOS 9.0, *) {
                        result(self.mapView.showsCompass)
                    } else {
                        result(false)
                    }
                case "map#isPitchGesturesEnabled":
                    result(self.mapView.isPitchEnabled)
                case "map#isScrollGesturesEnabled":
                    result(self.mapView.isScrollEnabled)
                case "map#isZoomGesturesEnabled":
                    result(self.mapView.isZoomEnabled)
                case "map#isRotateGesturesEnabled":
                    result(self.mapView.isRotateEnabled)
                case "map#isMyLocationButtonEnabled":
                    result(self.mapView.isMyLocationButtonShowing ?? false)
                case "map#getMinMaxZoomLevels":
                    result([self.mapView.minZoomLevel, self.mapView.maxZoomLevel])
                case "camera#getZoomLevel":
                    result(self.mapView.calculatedZoomLevel)
                default:
                    result(FlutterMethodNotImplemented)
                    return
                }
            }
        })
    }
    
    private func toPositionData(data: Array<Any>, animated: Bool) -> Dictionary<String, Any> {
        var positionData: Dictionary<String, Any> = [:]
        if let update: String = data[0] as? String {
            switch(update) {
            case "newCameraPosition":
                if let _positionData : Dictionary<String, Any> = data[1] as? Dictionary<String, Any> {
                    positionData = _positionData
                }
            case "newLatLng":
                if let _positionData : Array<Any> = data[1] as? Array<Any> {
                    positionData = ["target": _positionData]
                }
            case "newLatLngZoom":
                if let _positionData: Array<Any> = data[1] as? Array<Any> {
                    let zoom: Double = data[2] as? Double ?? 0
                    positionData = ["target": _positionData, "zoom": zoom]
                }
            case "newLatLngBounds":
                if let _positionData: Array<Any> = data[1] as? Array<Any> {
                    let padding: Double = data[2] as? Double ?? 0
                    positionData = ["target": _positionData, "padding": padding, "moveToBounds": true]
                }
            case "zoomBy":
                if let zoomBy: Double = data[1] as? Double {
                    mapView.zoomBy(zoomBy: zoomBy, animated: animated)
                }
            case "zoomTo":
                if let zoomTo: Double = data[1] as? Double {
                    mapView.zoomTo(newZoomLevel: zoomTo, animated: animated)
                }
            case "zoomIn":
                mapView.zoomIn(animated: animated)
            case "zoomOut":
                mapView.zoomOut(animated: animated)
            default:
                positionData = [:]
            }
            return positionData
        }
        return [:]
    }
}
