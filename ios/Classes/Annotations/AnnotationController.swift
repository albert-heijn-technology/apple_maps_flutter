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
    let registrar: FlutterPluginRegistrar
    
    public init(mapView :MKMapView, channel :FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
        self.mapView = mapView
        self.channel = channel
        self.registrar = registrar
    }
    
    
    public func annotationsToAdd(annotations :NSArray) {
        for annotation in annotations {
            let annotationData :Dictionary<String, Any> = annotation as! Dictionary<String, Any>
            addAnnotation(annotationData: annotationData)
        }
    }
    
    
    public func annotationsToChange(annotations: NSArray) {
        let oldAnnotations :[MKAnnotation] = mapView.annotations
        for annotation in annotations {
            let annotationData :Dictionary<String, Any> = annotation as! Dictionary<String, Any>
            for oldAnnotation in oldAnnotations {
                if let oldFlutterAnnotation = oldAnnotation as? FlutterAnnotation {
                    if oldFlutterAnnotation.id == (annotationData["annotationId"] as! String) {
                        let newAnnotation = FlutterAnnotation.init(fromDictionary: annotationData, registrar: registrar)
                        if oldFlutterAnnotation != newAnnotation {
                            if !oldFlutterAnnotation.wasDragged {
                                updateAnnotationOnMap(oldAnnotation: oldFlutterAnnotation, newAnnotation: newAnnotation)
                            } else {
                                oldFlutterAnnotation.wasDragged = false
                            }
                        } 
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
            channel.invokeMethod("annotation#onTap", arguments: ["annotationId" : flutterAnnotation.id])
        }
    }
    
    
    private func removeAnnotation(id: String) {
        for annotation in mapView.annotations {
            if let flutterAnnotation :FlutterAnnotation = annotation as? FlutterAnnotation {
                if flutterAnnotation.id == id {
                    mapView.removeAnnotation(flutterAnnotation)
                }
            }
        }
    }
    
    
    private func updateAnnotationOnMap(oldAnnotation: FlutterAnnotation, newAnnotation :FlutterAnnotation) {
        removeAnnotation(id: oldAnnotation.id)
        mapView.addAnnotation(newAnnotation)
    }
    
    
    private func addAnnotation(annotationData: Dictionary<String, Any>) {
        let annotation :MKAnnotation = FlutterAnnotation(fromDictionary: annotationData, registrar: registrar)
        mapView.addAnnotation(annotation)
    }
}
