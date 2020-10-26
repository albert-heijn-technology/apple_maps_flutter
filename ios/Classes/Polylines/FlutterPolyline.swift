//
//  FlutterPolyline.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 07.03.20.
//

import Foundation
import MapKit

class FlutterPolyline: MKPolyline {
    var color: UIColor?
    var isConsumingTapEvents: Bool?
    var width: CGFloat?
    var isVisible: Bool?
    var id: String?
    var capType: String?
    var pattern: NSArray?
    var lineJoin: Int?
    var zIndex: Int? = -1
    
    convenience init(fromDictionaray polylineData: Dictionary<String, Any>) {
        let points = polylineData["points"] as! NSArray
        var _points: [CLLocationCoordinate2D] = []
        for point in points {
           if let _point: NSArray = point as? NSArray {
               _points.append(CLLocationCoordinate2D.init(latitude: _point[0] as! CLLocationDegrees, longitude: _point[1] as! CLLocationDegrees))
           }
        }
        self.init(coordinates: _points, count: points.count)
        self.color = JsonConversions.convertColor(data: polylineData["color"] as! NSNumber)
        self.isConsumingTapEvents = polylineData["consumeTapEvents"] as? Bool
        self.width = polylineData["width"] as? CGFloat
        self.id = polylineData["polylineId"] as? String
        self.isVisible = polylineData["visible"] as? Bool
        self.capType = polylineData["polylineCap"] as? String
        self.pattern = polylineData["pattern"] as? NSArray
        self.lineJoin = polylineData["jointType"] as? Int
        self.zIndex = polylineData["zIndex"] as? Int
    }
    
    static func == (lhs: FlutterPolyline, rhs: FlutterPolyline) -> Bool {
        return lhs.color == rhs.color && lhs.isConsumingTapEvents == rhs.isConsumingTapEvents && lhs.width ==  rhs.width
            && lhs.isVisible == rhs.isVisible && lhs.capType == rhs.capType && lhs.pattern == rhs.pattern && lhs.lineJoin == rhs.lineJoin && rhs.zIndex == lhs.zIndex && lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    static func != (lhs: FlutterPolyline, rhs: FlutterPolyline) -> Bool {
        return !(lhs == rhs)
    }
}

public extension MKPolyline {
    // maxMeters is the preferred distance offset from the polyline to be acknowledged as a touch
    func contains(coordinate: CLLocationCoordinate2D, mapView: MKMapView , maxMeters: Int = 8) -> Bool {
        let distance: Double = distanceOf(pt: MKMapPoint.init(coordinate), toMultipPoint: self)
        return distance <= meters(fromPixel: maxMeters, at: coordinate, view: mapView)
    }
    
    private func distanceOf(pt: MKMapPoint, toMultipPoint multiPoint: MKMultiPoint) -> Double {
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
    
    private func meters(fromPixel pixel: Int, at touchCoordinate: CLLocationCoordinate2D, view: MKMapView) -> Double {
        let touchPoint: CGPoint = view.convert(touchCoordinate, toPointTo: view)
        let maxOffsetPoint = CGPoint(x: touchPoint.x + CGFloat(pixel), y: touchPoint.y)
        let maxOffsetCoordinate: CLLocationCoordinate2D = view.convert(maxOffsetPoint, toCoordinateFrom: view)
        return MKMapPoint.init(touchCoordinate).distance(to: MKMapPoint.init(maxOffsetCoordinate))
    }
}

