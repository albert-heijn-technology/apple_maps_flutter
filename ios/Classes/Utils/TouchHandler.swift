//
//  TouchHandler.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.03.20.
//

import Foundation
import MapKit

class TouchHandler {
    
    static func handleMapTaps(tap: UITapGestureRecognizer, overlays: [MKOverlay], channel: FlutterMethodChannel?, in view: MKMapView) {
        let locationInView = tap.location(in: view)
        let touchPt: CGPoint = tap.location(in: view)
        let coord: CLLocationCoordinate2D = view.convert(touchPt, toCoordinateFrom: view)
        var didOverlayConsumeTapEvent: Bool = false
        for overlay: MKOverlay in overlays {
            if let flutterPolyline: FlutterPolyline = overlay as?  FlutterPolyline {
                if  flutterPolyline.isConsumingTapEvents ?? false && flutterPolyline.contains(coordinate: coord, mapView: view) {
                    channel?.invokeMethod("polyline#onTap", arguments: ["polylineId": flutterPolyline.id])
                    didOverlayConsumeTapEvent = true
                }
            } else if let flutterPolygon: FlutterPolygon = overlay as?  FlutterPolygon {
                if  flutterPolygon.isConsumingTapEvents ?? false && flutterPolygon.contains(coordinate: coord) {
                    channel?.invokeMethod("polygon#onTap", arguments: ["polygonId": flutterPolygon.id])
                    didOverlayConsumeTapEvent = true
                }
            } else if let flutterCircle: FlutterCircle = overlay as?  FlutterCircle {
                if  flutterCircle.isConsumingTapEvents ?? false && flutterCircle.contains(coordinate: coord) {
                    channel?.invokeMethod("circle#onTap", arguments: ["circleId": flutterCircle.id])
                    didOverlayConsumeTapEvent = true
                }
            }
        }
        if !didOverlayConsumeTapEvent {
            let locationOnMap = view.convert(locationInView, toCoordinateFrom: view)
            channel?.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
        }
    }
}
