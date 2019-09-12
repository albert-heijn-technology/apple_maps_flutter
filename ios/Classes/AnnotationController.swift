//
//  AnnotationController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.09.19.
//

import Foundation
import MapKit

class AnnotationController: NSObject {
    
    let mapView: MKMapView
    let channel: FlutterMethodChannel
    
    public init(mapView :MKMapView, channel :FlutterMethodChannel) {
        self.mapView = mapView
        self.channel = channel
    }
    
    
    public func annotationsToAdd(annotations :NSArray) {
        for annotation in annotations {
            let annotationData :Dictionary<String, Any> = annotation as! Dictionary<String, Any>
            addAnnotation(annotationData: annotationData)
        }
    }
    
    
    public func annotationsToChange(annotations: NSArray) {
        let oldAnnotations :[FlutterAnnotation] = mapView.annotations as! [FlutterAnnotation]
        for annotation in annotations {
            let annotationData :Dictionary<String, Any> = annotation as! Dictionary<String, Any>
            for oldAnnotation in oldAnnotations {
                if (oldAnnotation.id == (annotationData["markerId"] as! String)) {
                    if (oldAnnotation.update(fromDictionary: annotationData)) {
                        updateAnnotationOnMap(annotation: oldAnnotation)
                    }
                }
            }
        }
    }
    
    
    public func annotationsIdsToRemove(annotationIds: NSArray) {
        for annotationId in annotationIds {
            if let _annotationId :String = annotationId as? String {
                removeAnnotation(id: _annotationId)
            }
        }
    }
    
    
    public func onAnnotationClick(annotation :MKAnnotation) {
        if let flutterAnnotation :FlutterAnnotation = annotation as? FlutterAnnotation {
            flutterAnnotation.wasDragged = true
            channel.invokeMethod("marker#onTap", arguments: ["markerId" : flutterAnnotation.id])
        }
    }
    
    
    private func removeAnnotation(id: String) {
        for annotation in mapView.annotations {
            if let flutterAnnotation :FlutterAnnotation = annotation as? FlutterAnnotation {
                if (flutterAnnotation.id == id) {
                    mapView.removeAnnotation(flutterAnnotation)
                }
            }
        }
    }
    
    
    private func updateAnnotationOnMap(annotation :FlutterAnnotation) {
        removeAnnotation(id: annotation.id)
        mapView.addAnnotation(annotation)
    }
    
    
    private func addAnnotation(annotationData: Dictionary<String, Any>) {
        let annotation :MKAnnotation = FlutterAnnotation(fromDictionary: annotationData)
        mapView.addAnnotation(annotation)
    }
}


class FlutterAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var id :String!
    var title: String?
    var subtitle: String?
    var image :UIImage?
    var alpha :Double?
    var isDraggable :Bool?
    var wasDragged :Bool = false
    
    public init(fromDictionary annotationData: Dictionary<String, Any>) {
        let position :Array<Double> = annotationData["position"] as! Array<Double>
        let lat: Double = position[0]
        let long: Double = position[1]
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let infoWindow :Dictionary<String, Any> = annotationData["infoWindow"] as! Dictionary<String, Any>
        self.title = infoWindow["title"] as? String
        self.subtitle = infoWindow["snippet"] as? String
        self.id = annotationData["markerId"] as? String
        if let alpha :NSNumber = annotationData["alpha"] as? NSNumber {
            self.alpha = JsonConversion.toDouble(jsonDouble: alpha)
        }
    }
    
    public func update(fromDictionary updatedAnnotationData: Dictionary<String, Any>) -> Bool {
        var didUpdate :Bool = false
        print(updatedAnnotationData)
        let updatedPosition :Array<Double> = updatedAnnotationData["position"] as! Array<Double>
        let lat: Double = updatedPosition[0]
        let long: Double = updatedPosition[1]
        
        let updatedInfoWindow :Dictionary<String, Any> = updatedAnnotationData["infoWindow"] as! Dictionary<String, Any>
        let updatedTitle = updatedInfoWindow["title"] as? String
        let updatedSubtitle = updatedInfoWindow["snippet"] as? String
        let updatedId = updatedAnnotationData["markerId"] as? String
        let updatedAlpha :Double = JsonConversion.toDouble(jsonDouble: updatedAnnotationData["alpha"] as! NSNumber)
        let updatedIsDraggable = JsonConversion.toBool(jsonBool: updatedAnnotationData["draggable"] as! NSNumber)
        if (updatedTitle != self.title) {
            self.title = updatedTitle
            didUpdate = true
        } else if (updatedSubtitle != self.subtitle) {
            self.subtitle = updatedSubtitle
            didUpdate = true
        } else if (updatedId != self.id) {
            self.id = updatedId
            didUpdate = true
        } else if (updatedAlpha != self.alpha) {
            self.alpha = updatedAlpha
            didUpdate = true
        } else if (self.coordinate.latitude != lat || self.coordinate.longitude != long) {
            if (!self.wasDragged) {
                self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                didUpdate = true
            } else {
                wasDragged = false
            }
        } else if (self.isDraggable != updatedIsDraggable) {
            self.isDraggable = updatedIsDraggable
            didUpdate = true
        }
        return didUpdate
    }
}
