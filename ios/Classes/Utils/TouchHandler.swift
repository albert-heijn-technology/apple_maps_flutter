//
//  TouchHandler.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.03.20.
//

import Foundation
import MapKit

class TouchHandler {
    
    static func handleOverlayTouch(tap: UITapGestureRecognizer, overlays: [MKOverlay], channel: FlutterMethodChannel?, _in view: MKMapView) {
        let locationInView = tap.location(in: view)
        let touchPt: CGPoint = tap.location(in: view)
        let coord: CLLocationCoordinate2D = view.convert(touchPt, toCoordinateFrom: view)
        let maxMeters: Double = meters(fromPixel: 6, at: touchPt, view: view)
        var nearestDistance: Float = MAXFLOAT
        var nearestPolyline: FlutterPolyline?
        var nearestPolygon: FlutterPolygon?
        var nearestCircle: FlutterCircle?
        for overlay: MKOverlay in overlays {
            if overlay is FlutterPolyline {
                let distance: Float = Float(distanceOf(pt: MKMapPoint.init(coord), toMultipPoint: overlay as! MKPolyline))
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestPolyline = (overlay as! FlutterPolyline)
                }
            } else if overlay is FlutterPolygon {
                let distance: Float = Float(distanceOf(pt: MKMapPoint.init(coord), toMultipPoint: overlay as! MKPolygon))
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestPolygon = (overlay as! FlutterPolygon)
                }
            } else if overlay is FlutterCircle {
                nearestCircle = (overlay as! FlutterCircle)
            }
        }
        if Double(nearestDistance) <= maxMeters {
            if nearestPolyline?.isConsumingTapEvents ?? false {
                channel?.invokeMethod("polyline#onTap", arguments: ["polylineId": nearestPolyline!.id])
            } else if  nearestPolygon?.isConsumingTapEvents ?? false {
                channel?.invokeMethod("polygon#onTap", arguments: ["polygonId": nearestPolygon!.id])
            } else if (nearestCircle == nil){
                let locationOnMap = view.convert(locationInView, toCoordinateFrom: view)
                channel?.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
            }
        } else if nearestCircle != nil && distanceOf(pt: MKMapPoint.init(coord), toCircle: nearestCircle!) {
            if  nearestCircle?.isConsumingTapEvents ?? false {
                channel?.invokeMethod("circle#onTap", arguments: ["circleId": nearestCircle!.id])
            }
        } else {
            let locationOnMap = view.convert(locationInView, toCoordinateFrom: view)
            channel?.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
        }
    }
    
    private static func distanceOf(pt: MKMapPoint, toMultipPoint multiPoint: MKMultiPoint) -> Double {
        var distance: Double = Double(MAXFLOAT)
        for n in 0..<multiPoint.pointCount - 1 {
            let ptA = multiPoint.points()[n]
            let ptB = multiPoint.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points must not be equal
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            }
            else if u > 1.0 {
                ptClosest = ptB
            }
            else {
                ptClosest = MKMapPoint.init(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }

            distance = min(distance, ptClosest.distance(to: pt))
        }
        return distance
    }
    
    private static func distanceOf(pt: MKMapPoint, toCircle circle: MKCircle) -> Bool {
        let circleCenter: CLLocationCoordinate2D = circle.coordinate
        return pt.distance(to: MKMapPoint.init(circleCenter)) < circle.radius
    }

    private static func meters(fromPixel px: Int, at pt: CGPoint, view: MKMapView) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = view.convert(pt, toCoordinateFrom: view)
        let coordB: CLLocationCoordinate2D = view.convert(ptB, toCoordinateFrom: view)
        return MKMapPoint.init(coordA).distance(to: MKMapPoint.init(coordB))
    }
    
}
