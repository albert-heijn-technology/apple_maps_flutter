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


class FlutterAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var id :String!
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var alpha: Double?
    var isDraggable: Bool?
    var wasDragged: Bool = false
    var isVisible: Bool? = true
    var icon: AnnotationIcon = AnnotationIcon.init()
    
    public init(fromDictionary annotationData: Dictionary<String, Any>, registrar: FlutterPluginRegistrar) {
        let position :Array<Double> = annotationData["position"] as! Array<Double>
        let infoWindow :Dictionary<String, Any> = annotationData["infoWindow"] as! Dictionary<String, Any>
        let lat: Double = position[0]
        let long: Double = position[1]
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = infoWindow["title"] as? String
        self.subtitle = infoWindow["snippet"] as? String
        self.id = annotationData["annotationId"] as? String
        self.isVisible = annotationData["visible"] as? Bool
        self.isDraggable = annotationData["draggable"] as? Bool
        if let alpha: Double = annotationData["alpha"] as? Double {
            self.alpha = alpha
        }
        if let iconData: Array<Any> = annotationData["icon"] as? Array<Any> {
            self.icon = FlutterAnnotation.getAnnotationIcon(iconData: iconData, registrar: registrar, annotationId: id)
        }
    }
    
    static private func getAnnotationIcon(iconData: Array<Any>, registrar: FlutterPluginRegistrar, annotationId: String) -> AnnotationIcon {
        let iconTypeMap: Dictionary<String, IconType> = ["fromAssetImage": IconType.CUSTOM, "defaultAnnotation": IconType.PIN]
        var icon: AnnotationIcon
        let iconType: IconType = iconTypeMap[iconData[0] as! String] ?? .PIN
        var scaleParam: CGFloat?
       
        if iconType == .CUSTOM {
            let assetPath: String = iconData[1] as! String
            scaleParam = CGFloat(iconData[2] as? Double ?? 1.0)
            icon = AnnotationIcon(named: registrar.lookupKey(forAsset: assetPath), iconType: iconType, id: annotationId, iconScale: scaleParam)
        } else {
            icon = AnnotationIcon(named: "", iconType: iconType, id: annotationId)
        }
        return icon
    }
    
    static func == (lhs: FlutterAnnotation, rhs: FlutterAnnotation) -> Bool {
        return  lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.image == rhs.image && lhs.alpha == rhs.alpha
            && lhs.isDraggable == rhs.isDraggable && lhs.wasDragged == rhs.wasDragged && lhs.isVisible == rhs.isVisible && lhs.icon == rhs.icon
            && lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    static func != (lhs: FlutterAnnotation, rhs: FlutterAnnotation) -> Bool {
        return !(lhs == rhs)
    }
}

enum IconType {
    case PIN, STANDARD, CUSTOM
}

class AnnotationIcon: Equatable {
    
    var iconType: IconType
    var id: String
    var image: UIImage?
    
    public init(named name: String, iconType type: IconType? = .PIN, id: String, iconScale: CGFloat? = 1.0) {
        if type == .CUSTOM {
            if let uiImage: UIImage =  UIImage.init(named: name) {
                if let cgImage: CGImage = uiImage.cgImage {
                    if iconScale != nil && iconScale! - 1 > 0.001 {
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
    
    static func == (lhs: AnnotationIcon, rhs: AnnotationIcon) -> Bool {
        return lhs.iconType == rhs.iconType && lhs.id == rhs.id && lhs.image == rhs.image
    }
    
    static func != (lhs: AnnotationIcon, rhs: AnnotationIcon) -> Bool {
        return !(lhs == rhs)
    }
}
