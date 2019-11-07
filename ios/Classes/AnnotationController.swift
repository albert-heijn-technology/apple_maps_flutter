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
                if let oldFlutterAnnoation = oldAnnotation as? FlutterAnnotation {
                    if (oldFlutterAnnoation.id == (annotationData["annotationId"] as! String)) {
                        if (oldFlutterAnnoation.update(fromDictionary: annotationData, registrar: registrar)) {
                            updateAnnotationOnMap(annotation: oldFlutterAnnoation)
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
    var icon: AnnotationIcon = AnnotationIcon.init()
    
    public init(fromDictionary annotationData: Dictionary<String, Any>) {
        let position :Array<Double> = annotationData["position"] as! Array<Double>
        let lat: Double = position[0]
        let long: Double = position[1]
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let infoWindow :Dictionary<String, Any> = annotationData["infoWindow"] as! Dictionary<String, Any>
        self.title = infoWindow["title"] as? String
        self.subtitle = infoWindow["snippet"] as? String
        self.id = annotationData["annotationId"] as? String
        if let alpha :Double = annotationData["alpha"] as? Double {
            self.alpha = alpha
        }
    }
    
    public func update(fromDictionary updatedAnnotationData: Dictionary<String, Any>, registrar: FlutterPluginRegistrar) -> Bool {
        var didUpdate :Bool = false
        let updatedPosition :Array<Double> = updatedAnnotationData["position"] as! Array<Double>
        let lat: Double = updatedPosition[0]
        let long: Double = updatedPosition[1]
        
        let updatedInfoWindow :Dictionary<String, Any> = updatedAnnotationData["infoWindow"] as! Dictionary<String, Any>
        let updatedTitle = updatedInfoWindow["title"] as? String
        let updatedSubtitle = updatedInfoWindow["snippet"] as? String
        let updatedId = updatedAnnotationData["annotationId"] as? String
        let updatedAlpha: Double = updatedAnnotationData["alpha"] as! Double
        let updatedIsDraggable: Bool = updatedAnnotationData["draggable"] as! Bool
        let iconData: Array<Any> = updatedAnnotationData["icon"] as! Array<Any>
        let updatedIcon: AnnotationIcon = getAnnotationImage(registrar: registrar, iconData: iconData, annotationId: self.id)
        
        if (updatedTitle != self.title) {
            self.title = updatedTitle
            didUpdate = true
        }
        if (self.icon.iconType != updatedIcon.iconType) {
            self.icon = updatedIcon
            didUpdate = true
        }
        if (updatedSubtitle != self.subtitle) {
            self.subtitle = updatedSubtitle
            didUpdate = true
        }
        if (updatedId != self.id) {
            self.id = updatedId
            didUpdate = true
        }
        if (updatedAlpha != self.alpha) {
            self.alpha = updatedAlpha
            didUpdate = true
        }
        if (self.coordinate.latitude != lat || self.coordinate.longitude != long) {
            if (!self.wasDragged) {
                self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                didUpdate = true
            } else {
                wasDragged = false
            }
        }
        if (self.isDraggable != updatedIsDraggable) {
            self.isDraggable = updatedIsDraggable
            didUpdate = true
        }
        return didUpdate
    }
    
    private func getAnnotationImage(registrar: FlutterPluginRegistrar, iconData: Array<Any>, annotationId: String) -> AnnotationIcon {
        let iconTypeMap: Dictionary<String, IconType> = ["fromAssetImage": IconType.CUSTOM, "defaultAnnotation": IconType.PIN]
        var icon: AnnotationIcon
        let iconType: IconType = iconTypeMap[iconData[0] as! String] ?? .PIN
        var scaleParam: CGFloat?
       
        if (iconType == .CUSTOM) {
            let assetPath: String = iconData[1] as! String
            scaleParam = CGFloat(iconData[2] as? Double ?? 1.0)
            icon = AnnotationIcon(named: registrar.lookupKey(forAsset: assetPath), iconType: iconType, id: annotationId, iconScale: scaleParam)
        } else {
            icon = AnnotationIcon(named: "", iconType: iconType, id: annotationId)
        }
        return icon
    }
}

enum IconType {
    case PIN, STANDARD, CUSTOM
}

class AnnotationIcon {
    
    var iconType: IconType
    var id: String
    var image: UIImage?
    
    public init(named name: String, iconType type: IconType? = .PIN, id: String, iconScale: CGFloat? = 1.0) {
        if (type == .CUSTOM) {
            if let uiImage: UIImage =  UIImage.init(named: name) {
                if let cgImage: CGImage = uiImage.cgImage {
                    if (iconScale != nil && iconScale! - 1 > 0.001){
                        let scaledImage: UIImage = UIImage.init(cgImage: cgImage, scale: (iconScale! + 1) * CGFloat(uiImage.scale), orientation: uiImage.imageOrientation)
                        self.image = scaledImage
                    }
                } else {
                    self.image = uiImage
                }
            }
        }
        self.iconType = type ?? .PIN
        self.id = id
    }
    
    public convenience init() {
        self.init(named: "", id: "")
    }
    
}
