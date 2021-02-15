//
//  ClusteredAnnotationView.swift
//  apple_maps_flutter
//
//  Created by sarupu on 15.02.2021.
//

import MapKit

@available(iOS 11.0, *)
class ClusterableAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            guard let mapItem = annotation as? FlutterAnnotation else { return }
            clusteringIdentifier = "MapItem"
            image = mapItem.icon.image
        }
    }
}

@available(iOS 11.0, *)
final class ClusterAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation, let firstAnnotation = cluster.memberAnnotations.first as? FlutterAnnotation else { return }
            displayPriority = .defaultHigh
            image = firstAnnotation.image
        }
    }
}
