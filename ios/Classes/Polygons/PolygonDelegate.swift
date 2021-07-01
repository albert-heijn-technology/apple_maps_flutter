//
//  PolygonDelegate.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 01.07.21.
//

import Foundation
import MapKit

protocol PolygonDelegate {
    func polygonRenderer(overlay: MKOverlay) -> MKOverlayRenderer
    func addPolygons(polygonData data: NSArray)
    func changePolygons(polygonData data: NSArray)
    func removePolygons(polygonIds: NSArray)
    func removeAllPolygons()
}
