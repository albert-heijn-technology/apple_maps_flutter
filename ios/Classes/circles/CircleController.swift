//
//  CircleController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 08.03.20.
//

import Foundation
import MapKit

class CircleController {
    
    var mapView: MKMapView
    var channel: FlutterMethodChannel
    var registrar: FlutterPluginRegistrar

    init(mapView: MKMapView, channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
        self.mapView = mapView
        self.channel = channel
        self.registrar = registrar
    }

    func circleRenderer(overlay: MKOverlay) -> MKOverlayRenderer {
        // Make sure we are rendering a circle.
        guard let circle = overlay as? MKCircle else {
           return MKOverlayRenderer()
        }
        let circleRenderer = MKCircleRenderer(overlay: circle)

        if let flutterCircle: FlutterCircle = overlay as? FlutterCircle {
            if flutterCircle.isVisible! {
                circleRenderer.strokeColor = flutterCircle.strokeColor
                circleRenderer.fillColor = flutterCircle.fillColor
                circleRenderer.lineWidth = flutterCircle.strokeWidth ?? 1.0
            } else {
                circleRenderer.strokeColor = UIColor.clear
                circleRenderer.lineWidth = 0.0
            }
        }
        return circleRenderer
    }

    func addCircles(circleData data: NSArray) {
        for _circle in data {
            let circleData :Dictionary<String, Any> = _circle as! Dictionary<String, Any>
            let circle = FlutterCircle(fromDictionaray: circleData)
            addCircle(circle: circle)
        }
    }
    
    private func addCircle(circle: FlutterCircle) {
        if circle.zIndex == nil || circle.zIndex == -1 {
            mapView.addOverlay(circle)
        } else {
            mapView.insertOverlay(circle, at: circle.zIndex ?? 0)
        }
    }

    func changeCircles(circleData data: NSArray) {
        let oldOverlays: [MKOverlay] = mapView.overlays
        for oldOverlay in oldOverlays {
            if oldOverlay is FlutterCircle {
                let oldFlutterCircle = oldOverlay as! FlutterCircle
                for _circle in data {
                    let circleData :Dictionary<String, Any> = _circle as! Dictionary<String, Any>
                    if oldFlutterCircle.id == (circleData["circleId"] as! String) {
                        let newCircle = FlutterCircle.init(fromDictionaray: circleData)
                        if oldFlutterCircle != newCircle {
                            updateCirclesOnMap(oldCircle: oldFlutterCircle, newCircle: newCircle)
                        }
                    }
                }
            }
        }
    }

    func removeCircles(circleIds: NSArray) {
        for overlay in mapView.overlays {
            if let circle = overlay as? FlutterCircle {
                if circleIds.contains(circle.id!) {
                    mapView.removeOverlay(circle)
                }
            }
        }
    }
    
    private func updateCirclesOnMap(oldCircle: FlutterCircle, newCircle: FlutterCircle) {
        mapView.removeOverlay(oldCircle)
        addCircle(circle: newCircle)
    }
}

