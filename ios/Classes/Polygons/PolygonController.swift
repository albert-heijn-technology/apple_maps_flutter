//
//  PolygonController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 07.03.20.
//


import Foundation
import MapKit

class PolygonController {
    
    var mapView: MKMapView
    var channel: FlutterMethodChannel
    var registrar: FlutterPluginRegistrar

    init(mapView: MKMapView, channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
        self.mapView = mapView
        self.channel = channel
        self.registrar = registrar
    }

    func polygonRenderer(overlay: MKOverlay) -> MKOverlayRenderer {
        // Make sure we are rendering a polygon.
        guard let polygon = overlay as? MKPolygon else {
           return MKOverlayRenderer()
        }
        let polygonRenderer = MKPolygonRenderer(overlay: polygon)

        if let flutterPolygon: FlutterPolygon = overlay as? FlutterPolygon {
            if flutterPolygon.isVisible! {
                polygonRenderer.strokeColor = flutterPolygon.strokeColor
                polygonRenderer.fillColor = flutterPolygon.fillColor
                polygonRenderer.lineWidth = flutterPolygon.width ?? 1.0
            } else {
                polygonRenderer.strokeColor = UIColor.clear
                polygonRenderer.lineWidth = 0.0
            }
        }
        return polygonRenderer
    }

    func addPolygons(polygonData data: NSArray) {
        for _polygon in data {
            let polygonData :Dictionary<String, Any> = _polygon as! Dictionary<String, Any>
            let polygon = FlutterPolygon(fromDictionaray: polygonData)
            addPolygon(polygon: polygon)
        }
    }
    
    private func addPolygon(polygon: FlutterPolygon) {
        if polygon.zIndex == nil || polygon.zIndex == -1 {
            mapView.addOverlay(polygon)
        } else {
            mapView.insertOverlay(polygon, at: polygon.zIndex ?? 0)
        }
    }

    func changePolygons(polygonData data: NSArray) {
        let oldOverlays: [MKOverlay] = mapView.overlays
        for oldOverlay in oldOverlays {
            if oldOverlay is FlutterPolygon {
                let oldFlutterPolygon = oldOverlay as! FlutterPolygon
                for _polygon in data {
                    let polygonData :Dictionary<String, Any> = _polygon as! Dictionary<String, Any>
                    if oldFlutterPolygon.id == (polygonData["polygonId"] as! String) {
                        let newPolygon = FlutterPolygon.init(fromDictionaray: polygonData)
                        if oldFlutterPolygon != newPolygon {
                            updatePolygonsOnMap(oldPolygon: oldFlutterPolygon, newPolygon: newPolygon)
                        }
                    }
                }
            }
        }
    }

    func removePolygons(polygonIds: NSArray) {
        for overlay in mapView.overlays {
            if let polygon = overlay as? FlutterPolygon {
                if polygonIds.contains(polygon.id!) {
                    mapView.removeOverlay(polygon)
                }
            }
        }
    }
    
    private func updatePolygonsOnMap(oldPolygon: FlutterPolygon, newPolygon: FlutterPolygon) {
        mapView.removeOverlay(oldPolygon)
        addPolygon(polygon: newPolygon)
    }
}
