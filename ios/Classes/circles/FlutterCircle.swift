//
//  FlutterCircle.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 08.03.20.
//

import Foundation
import MapKit

class FlutterCircle: MKCircle {
    var strokeColor: UIColor?
    var fillColor: UIColor?
    var isConsumingTapEvents: Bool?
    var strokeWidth: CGFloat?
    var isVisible: Bool?
    var id: String?
    var zIndex: Int? = -1
    
    convenience init(fromDictionaray circleData: Dictionary<String, Any>) {
        let _center = circleData["center"] as! NSArray
        let center: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: _center[0] as! CLLocationDegrees, longitude: _center[1] as! CLLocationDegrees)
        let radius = circleData["radius"] as? Double ?? 10
        self.init(center: center, radius: radius)
        self.strokeColor = JsonConversions.convertColor(data: circleData["strokeColor"] as! NSNumber)
        self.fillColor = JsonConversions.convertColor(data: circleData["fillColor"] as! NSNumber)
        self.isConsumingTapEvents = circleData["consumeTapEvents"] as? Bool
        self.strokeWidth = circleData["strokeWidth"] as? CGFloat
        self.id = circleData["circleId"] as? String
        self.isVisible = circleData["visible"] as? Bool
        self.zIndex = circleData["zIndex"] as? Int
    }
    
    static func == (lhs: FlutterCircle, rhs: FlutterCircle) -> Bool {
        return lhs.strokeColor == rhs.strokeColor && lhs.fillColor == rhs.fillColor && lhs.isConsumingTapEvents == rhs.isConsumingTapEvents && lhs.strokeWidth ==  rhs.strokeWidth && lhs.isVisible == rhs.isVisible && lhs.zIndex == rhs.zIndex && lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    static func != (lhs: FlutterCircle, rhs: FlutterCircle) -> Bool {
        return !(lhs == rhs)
    }
}

public extension MKCircle {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let circleRenderer = MKCircleRenderer(circle: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coordinate)
        let circleViewPoint: CGPoint = circleRenderer.point(for: currentMapPoint)
        if circleRenderer.path == nil {
          return false
        } else{
            return circleRenderer.path.contains(circleViewPoint)
        }
    }
}
