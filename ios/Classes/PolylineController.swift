//
//  PolylineController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 12.11.19.
//

import Foundation
import MapKit

class PolylineController {
    
let availableCaps: Dictionary<String, CGLineCap> = [
        "buttCap": CGLineCap.butt,
        "roundCap": CGLineCap.round,
        "squareCap": CGLineCap.square
    ]
    
    var mapView: MKMapView
    var channel: FlutterMethodChannel
    var registrar: FlutterPluginRegistrar

    init(mapView: MKMapView, channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
        self.mapView = mapView
        self.channel = channel
        self.registrar = registrar
    }

    func polylineRenderer(overlay: MKOverlay) -> MKOverlayRenderer {
        // Make sure we are rendering a polyline.
        guard let polyline = overlay as? MKPolyline else {
           return MKOverlayRenderer()
        }
        let polylineRenderer = MKPolylineRenderer(overlay: polyline)

        if let flutterPolyline: FlutterPolyline = overlay as? FlutterPolyline {
            polylineRenderer.strokeColor = flutterPolyline.color
            polylineRenderer.lineWidth = flutterPolyline.width ?? 1.0
            polylineRenderer.lineCap = availableCaps[flutterPolyline.capType ?? "buttCap"]!
        }
        return polylineRenderer
    }

    func addPolylines(polylineData data: NSArray) {
        for _polyline in data {
            let polylineData :Dictionary<String, Any> = _polyline as! Dictionary<String, Any>
            let polyline = FlutterPolyline(fromDictionaray: polylineData)
            mapView.add(polyline)
        }
    }

    func changePolylines(polylineData data: NSArray) {
        let oldOverlays: [MKOverlay] = mapView.overlays
        for _polyline in data {
            let polylineData :Dictionary<String, Any> = _polyline as! Dictionary<String, Any>
            for oldOverlay in oldOverlays {
                if (oldOverlay is FlutterPolyline) {
                    let oldFlutterPolyline = oldOverlay as! FlutterPolyline
                    if (oldFlutterPolyline.id == (polylineData["polylineId"] as! String)) {
                        if (oldFlutterPolyline.update(fromDictionary: polylineData)) {
                            updatePolylinesOnMap(polyline: oldFlutterPolyline)
                        }
                    }
                }
            }
        }
    }

    func removePolylines(polylineIds: NSArray) {
        for overlay in mapView.overlays {
            if let polyline = overlay as? FlutterPolyline {
                if (polylineIds.contains(polyline.id!)) {
                    mapView.remove(polyline)
                }
            }
        }
    }
    
    private func updatePolylinesOnMap(polyline: FlutterPolyline) {
        mapView.remove(polyline)
        mapView.add(polyline)
    }
}

class FlutterPolyline: MKPolyline {
    var color: UIColor?
    var isConsumingTapEvents: Bool?
    var width: CGFloat?
    var isVisible: Bool?
    var id: String?
    var capType: String?
    
    convenience init(fromDictionaray polylineData: Dictionary<String, Any>) {
        let points = polylineData["points"] as! NSArray
        var _points: [CLLocationCoordinate2D] = []
               for point in points {
                   if let _point: NSArray = point as? NSArray {
                       _points.append(CLLocationCoordinate2D.init(latitude: _point[0] as! CLLocationDegrees, longitude: _point[1] as! CLLocationDegrees))
                   }
               }
        self.init(coordinates: _points, count: points.count)
        self.color = hexToUIColor(hexColor: polylineData["color"] as! NSNumber)
        self.isConsumingTapEvents = polylineData["consumeTapEvents"] as? Bool
        self.width = polylineData["width"] as? CGFloat
        self.id = polylineData["polylineId"] as? String
        self.isVisible = polylineData["visible"] as? Bool
        self.capType = polylineData["polylineCap"] as? String
    }
    
    public func update(fromDictionary updatedPolylineData: Dictionary<String,Any>) -> Bool {
        let uodatedColor: UIColor? = hexToUIColor(hexColor: updatedPolylineData["color"] as! NSNumber)
        let updatedIsConsumingTapEvents: Bool? = true
        let updatedWidth: CGFloat? = updatedPolylineData["width"] as? CGFloat
        let updatedIsVisible: Bool? = true
        let updatedCapType: String? = updatedPolylineData["polylineCap"] as? String
        var didUpdate = false
        
        if (self.color != uodatedColor) {
            self.color = uodatedColor
            didUpdate = true
        }
        if (self.isConsumingTapEvents != updatedIsConsumingTapEvents) {
            self.isConsumingTapEvents = updatedIsConsumingTapEvents
            didUpdate = true
        }
        if (self.width != updatedWidth) {
            self.width = updatedWidth
            didUpdate = true
        }
        if (self.isVisible != updatedIsVisible) {
            self.isVisible = updatedIsVisible
            didUpdate = true
        }
        if (self.capType != updatedCapType) {
            self.capType = updatedCapType
            didUpdate = true
        }
        return didUpdate
    }
    
    private func hexToUIColor(hexColor: NSNumber) -> UIColor {
        let value: CUnsignedLong = hexColor as! CUnsignedLong
        return UIColor(red: (CGFloat((value & 0xFF0000) >> 16) / 255.0), green: (CGFloat((value & 0xFF00) >> 8) / 255.0), blue: (CGFloat((value & 0xFF)) / 255.0), alpha: (CGFloat((value & 0xFF000000) >> 24)) / 255.0)
    }
}
