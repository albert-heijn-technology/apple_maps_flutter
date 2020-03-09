//
//  FlutterPolygon.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 07.03.20.
//

import Foundation
import MapKit

class FlutterPolygon: MKPolygon {
    var strokeColor: UIColor?
    var fillColor: UIColor?
    var isConsumingTapEvents: Bool?
    var width: CGFloat?
    var isVisible: Bool?
    var id: String?
    
    convenience init(fromDictionaray polygonData: Dictionary<String, Any>) {
        let points = polygonData["points"] as! NSArray
        var _points: [CLLocationCoordinate2D] = []
        for point in points {
           if let _point: NSArray = point as? NSArray {
               _points.append(CLLocationCoordinate2D.init(latitude: _point[0] as! CLLocationDegrees, longitude: _point[1] as! CLLocationDegrees))
           }
        }
        self.init(coordinates: _points, count: points.count)
        self.strokeColor = JsonConversions.convertColor(data: polygonData["strokeColor"] as! NSNumber)
        self.fillColor = JsonConversions.convertColor(data: polygonData["fillColor"] as! NSNumber)
        self.isConsumingTapEvents = polygonData["consumeTapEvents"] as? Bool
        self.width = polygonData["strokeWidth"] as? CGFloat
        self.id = polygonData["polygonId"] as? String
        self.isVisible = polygonData["visible"] as? Bool
    }
    
    static func == (lhs: FlutterPolygon, rhs: FlutterPolygon) -> Bool {
        return lhs.strokeColor == rhs.strokeColor && lhs.fillColor == rhs.fillColor && lhs.isConsumingTapEvents == rhs.isConsumingTapEvents && lhs.width ==  rhs.width && lhs.isVisible == rhs.isVisible
    }
    
    static func != (lhs: FlutterPolygon, rhs: FlutterPolygon) -> Bool {
        return !(lhs == rhs)
    }
}


