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
    var circleRadius: Double?
    
    convenience init(fromDictionaray circleData: Dictionary<String, Any>) {
        let _center = circleData["center"] as! NSArray
        let centerCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: _center[0] as! CLLocationDegrees, longitude: _center[1] as! CLLocationDegrees)
        let radius = circleData["radius"] as? Double ?? 10
        self.init(center: centerCoordinates, radius: radius)
        self.circleRadius = radius
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

extension FlutterCircle: FlutterOverlay {
    func getCAShapeLayer(snapshot: MKMapSnapshotter.Snapshot) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        
        if !(self.isVisible ?? true) {
            return shapeLayer
        }
        
        let centerPoint = snapshot.point(for: self.coordinate)
        
        let offsetPoint = snapshot.point(for: Utils.coordinateWithLAtitudeOffset(coordinate: self.coordinate, meters: radius))
        
        let radius = centerPoint.y - offsetPoint.y
        
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        // Thus we use snapshot.point() to save the pain.
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = self.strokeWidth ?? 0
        shapeLayer.strokeColor = self.strokeColor?.cgColor ?? UIColor.clear.cgColor
        shapeLayer.fillColor = self.fillColor?.cgColor ?? UIColor.clear.cgColor
        
        return shapeLayer
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
