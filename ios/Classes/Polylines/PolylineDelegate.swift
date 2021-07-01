//
//  PolylineDelegate.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 01.07.21.
//

import Foundation
import MapKit

protocol PolylineDelegate {
    func polylineRenderer(overlay: MKOverlay) -> MKOverlayRenderer
    func addPolylines(polylineData data: NSArray)
    func changePolylines(polylineData data: NSArray)
    func removePolylines(polylineIds: NSArray)
    func removeAllPolylines()
}
