//
//  JsonConversion.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 26.11.19.
//

import Foundation
import MapKit

class JsonConversions {
    
    static func convertLocation(data: Any?) -> CLLocationCoordinate2D? {
        if let updatedPosition = data as? Array<CLLocationDegrees> {
            let lat: Double = updatedPosition[0]
            let lon: Double = updatedPosition[1]

            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    static func convertColor(data: Any?) -> UIColor? {
        if let value = data as? CUnsignedLong {
            return UIColor(red: CGFloat(Float(((value & 0xFF0000) >> 16)) / 255.0),
                           green: CGFloat(Float(((value & 0xFF00) >> 8)) / 255.0),
                           blue: CGFloat(Float(((value & 0xFF))) / 255.0),
                           alpha: CGFloat(Float(((value & 0xFF000000) >> 24)) / 255.0)
            )
        }
        return nil
    }
}
