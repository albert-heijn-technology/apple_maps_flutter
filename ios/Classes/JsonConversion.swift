//
//  JsonConversion.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 04.09.19.
//

import Foundation

class JsonConversion{
    
    static func toBool(jsonBool bool: NSNumber) -> Bool {
       return bool.boolValue
    }
    
    static func toInt(jsonInt int: NSNumber) -> Int {
        return int.intValue
    }
    
    static func toDouble(jsonDouble double: NSNumber) -> Double {
        return double.doubleValue
    }
    
}
