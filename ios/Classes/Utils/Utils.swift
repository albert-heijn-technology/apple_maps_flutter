//
//  Converter.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 19.02.22.
//

import Foundation
import CoreLocation

enum MapViewConstants: Double {
    case MERCATOR_OFFSET = 268435456.0
    case MERCATOR_RADIUS = 85445659.44705395
}

class  Utils {
    static func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(MapViewConstants.MERCATOR_OFFSET.rawValue + MapViewConstants.MERCATOR_RADIUS.rawValue * longitude * .pi / 180.0)
    }
    
    static func latitudeToPixelSpaceY(latitude: Double) -> Double {
        return round(Double(Float(MapViewConstants.MERCATOR_OFFSET.rawValue) - Float(MapViewConstants.MERCATOR_RADIUS.rawValue) * logf((1 + sinf(Float(latitude * .pi / 180.0))) / (1 - sinf(Float(latitude * .pi / 180.0)))) / Float(2.0)))
    }
    
    static func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - MapViewConstants.MERCATOR_OFFSET.rawValue) / MapViewConstants.MERCATOR_RADIUS.rawValue) * 180.0 / .pi
    }
    
    static func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MapViewConstants.MERCATOR_OFFSET.rawValue) / MapViewConstants.MERCATOR_RADIUS.rawValue))) * 180.0 / .pi
    }
    
    static func coordinateWithLAtitudeOffset(coordinate: CLLocationCoordinate2D, meters: Double) -> CLLocationCoordinate2D {

        // number of km per degree = ~111km (111.32 in google maps, but range varies
        // between 110.567km at the equator and 111.699km at the poles)
        // 1km in degree = 1 / 111.32km = 0.0089
        // 1m in degree = 0.0089 / 1000 = 0.0000089
        let dLat = meters * 0.0000089

        // OffsetPosition, decimal degrees
        let latO = coordinate.latitude + dLat
        
        return CLLocationCoordinate2D(latitude: latO, longitude: coordinate.longitude)
    }
    
    static func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }
    
    static func deg2rad(_ number: Double) -> Float {
        return Float(number * .pi / 180)
    }
    
    static func roundToTwoDecimalPlaces(number: Double) -> Double {
        let doubleStr = String(format: "%.2f", ceil(number*100)/100)
        return Double(doubleStr)!
    }
}
