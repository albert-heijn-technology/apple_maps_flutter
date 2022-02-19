//
//  AnnotationDelegate.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 01.07.21.
//

import Foundation
import MapKit

protocol AnnotationDelegate: AnyObject {
    func getAnnotationView(annotation: FlutterAnnotation) -> MKAnnotationView
    func annotationsToAdd(annotations :NSArray)
    func annotationsToChange(annotations: NSArray)
    func annotationsIdsToRemove(annotationIds: NSArray)
    func onAnnotationClick(annotation :MKAnnotation)
    func selectAnnotation(with id: String)
    func hideAnnotation(with id: String)
    func isAnnotationSelected(with id: String) -> Bool
    func removeAllAnnotations()
}
