//
//  FlutterOverlay.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 13.02.22.
//

import Foundation
import MapKit

protocol FlutterOverlay: MKOverlay {
    func getCAShapeLayer(snapshot: MKMapSnapshotter.Snapshot) -> CAShapeLayer;
}
