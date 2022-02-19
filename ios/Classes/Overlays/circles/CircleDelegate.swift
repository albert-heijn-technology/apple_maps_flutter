//
//  CircleDelegate.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 01.07.21.
//

import Foundation
import MapKit

protocol CircleDelegate {
    func circleRenderer(overlay: MKOverlay) -> MKOverlayRenderer
    func addCircles(circleData data: NSArray)
    func changeCircles(circleData data: NSArray)
    func removeCircles(circleIds: NSArray)
    func removeAllCircles()
}
