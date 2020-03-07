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
    }
    
    static func == (lhs: FlutterPolyline, rhs: FlutterPolyline) -> Bool {
        return lhs.color == rhs.color && lhs.isConsumingTapEvents == rhs.isConsumingTapEvents && lhs.width ==  rhs.width
            && lhs.isVisible == rhs.isVisible && lhs.capType == rhs.capType && lhs.pattern == rhs.pattern && lhs.lineJoin == rhs.lineJoin
    }
    
    static func != (lhs: FlutterPolyline, rhs: FlutterPolyline) -> Bool {
        return !(lhs == rhs)
    }
}

