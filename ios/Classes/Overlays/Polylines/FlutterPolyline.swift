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
    var capType: CGLineCap?
    var pattern: [NSNumber]?
    var lineJoin: CGLineJoin?
    var zIndex: Int? = -1
    var coordinates: [CLLocationCoordinate2D]?
    
    var caShapeLayerLineCap: CAShapeLayerLineCap {
        get {
            switch self.capType {
            case .butt:
                return CAShapeLayerLineCap.butt
            case .square:
                return CAShapeLayerLineCap.square
            case .round:
                return CAShapeLayerLineCap.square
            default:
                return CAShapeLayerLineCap.butt
            }
        }
    }
    
    var caShapeLayerLineJoin: CAShapeLayerLineJoin {
        get {
            switch self.lineJoin {
            case .round:
                return CAShapeLayerLineJoin.round
            case .bevel:
                return CAShapeLayerLineJoin.bevel
            case .miter:
                return CAShapeLayerLineJoin.miter
            default:
                return CAShapeLayerLineJoin.miter
            }
        }
    }
    
    private let availableCaps: Dictionary<String, CGLineCap> = [
        "buttCap": CGLineCap.butt,
        "roundCap": CGLineCap.round,
        "squareCap": CGLineCap.square
    ]
        
    private let availableJointTypes: Array<CGLineJoin> = [
        CGLineJoin.miter,
        CGLineJoin.bevel,
        CGLineJoin.round
    ]
    
    convenience init(fromDictionaray polylineData: Dictionary<String, Any>) {
        let points = polylineData["points"] as! NSArray
        let linePattern = polylineData["pattern"] as? NSArray
        var _points: [CLLocationCoordinate2D] = []
        for point in points {
           if let _point: NSArray = point as? NSArray {
               _points.append(CLLocationCoordinate2D.init(latitude: _point[0] as! CLLocationDegrees, longitude: _point[1] as! CLLocationDegrees))
           }
        }
        self.init(coordinates: _points, count: points.count)
        self.coordinates = _points
        self.color = JsonConversions.convertColor(data: polylineData["color"] as! NSNumber)
        self.isConsumingTapEvents = polylineData["consumeTapEvents"] as? Bool
        self.width = polylineData["width"] as? CGFloat
        self.id = polylineData["polylineId"] as? String
        self.isVisible = polylineData["visible"] as? Bool
        self.pattern = self.linePatternToArray(patternData: linePattern, lineWidth: self.width)
        if self.pattern != nil && self.pattern?.count != 0{
            self.capType = self.getLineCapForLinePattern(linePatternData: linePattern)
        } else {
            self.capType = self.availableCaps[polylineData["polylineCap"] as? String ?? "buttCap"]
        }
        self.lineJoin = self.availableJointTypes[polylineData["jointType"] as? Int ?? 2]
        self.zIndex = polylineData["zIndex"] as? Int
    }
    
    private func linePatternToArray(patternData: NSArray?, lineWidth: CGFloat?) -> [NSNumber] {
        var finalPattern: [NSNumber] = []
        var isDot: Bool = false
        if patternData == nil {
            return finalPattern
        }
        for pattern in patternData! {
            if let _pattern: NSArray = pattern as? NSArray {
                if _pattern.count > 0 {
                    if let identifier: String = _pattern[0] as? String {
                        if identifier == "dot" {
                            isDot = true
                            finalPattern.append(0)
                        } else if identifier == "dash" {
                            isDot = false
                            finalPattern.append(NSNumber(value: lround((_pattern[1] as! Double) * 1/3.5)))
                        } else if identifier == "gap" {
                            if let length = _pattern[1] as? Double {
                                if isDot {
                                    finalPattern.append(NSNumber(value: lround(Double((lineWidth ?? 0) * 1.5))))
                                } else {
                                    finalPattern.append(NSNumber(value: lround(length * 1/3.5)))
                                }
                            }
                        }
                    }
                }
            }
        }
        return finalPattern
    }
    
    private func getLineCapForLinePattern(linePatternData: NSArray?) -> CGLineCap {
        if linePatternData == nil {
            return CGLineCap.butt
        }
        for pattern in linePatternData! {
            if let _pattern = pattern as? NSArray {
                if _pattern.contains("dot") {
                    return CGLineCap.round
                } else if _pattern.contains("dash") {
                    return CGLineCap.butt
                }
            }
        }
        return CGLineCap.butt
    }
    
    static func == (lhs: FlutterPolyline, rhs: FlutterPolyline) -> Bool {
        return lhs.color == rhs.color && lhs.isConsumingTapEvents == rhs.isConsumingTapEvents && lhs.width ==  rhs.width
            && lhs.isVisible == rhs.isVisible && lhs.capType == rhs.capType && lhs.pattern == rhs.pattern && lhs.lineJoin == rhs.lineJoin && rhs.zIndex == lhs.zIndex && lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    static func != (lhs: FlutterPolyline, rhs: FlutterPolyline) -> Bool {
        return !(lhs == rhs)
    }
}

extension FlutterPolyline: FlutterOverlay {
    func getCAShapeLayer(snapshot: MKMapSnapshotter.Snapshot) -> CAShapeLayer {
        let path = UIBezierPath()
        let shapeLayer = CAShapeLayer()
        
        if !(self.isVisible ?? true) {
            return shapeLayer
        }
            

        // Thus we use snapshot.point() to save the pain.
        path.move(to: snapshot.point(for: self.coordinates![0]))
        for coordinate in self.coordinates! {
            path.addLine(to: snapshot.point(for: coordinate))
            path.move(to: snapshot.point(for: coordinate))
        }
        
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = self.width ?? 0
        shapeLayer.lineCap = self.caShapeLayerLineCap
        shapeLayer.lineJoin = self.caShapeLayerLineJoin
        shapeLayer.lineDashPattern = self.pattern
        shapeLayer.strokeColor = self.color?.cgColor ?? UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        return shapeLayer
    }
}

public extension MKPolyline {
    // maxMeters is the preferred distance offset from the self to be acknowledged as a touch
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

