//
//  SnapshotOptions.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 06.07.21.
//

import Foundation

class SnapshotOptions {
    let showBuildings: Bool
    let showPointsOfInterest: Bool
    let showAnnotations: Bool
    let showOverlays: Bool
    
    init(options: Dictionary<String, Any>) {
        self.showBuildings = options["showBuildings"] as? Bool ?? true
        self.showPointsOfInterest = options["showPointsOfInterest"] as? Bool ?? true
        self.showAnnotations = options["showAnnotations"] as? Bool ?? true
        self.showOverlays = options["showOverlays"] as? Bool ?? true
    }
}
