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
        let annotation = FlutterAnnotation(fromDictionary: annotationData, registrar: self.registrar)
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
    var icon: AnnotationIcon
    var anchor: CGPoint
    
    public init(fromDictionary annotationData: Dictionary<String, Any>, registrar: FlutterPluginRegistrar) {
        let position :Array<Double> = annotationData["position"] as! Array<Double>
        let lat: Double = position[0]
        let long: Double = position[1]
        let id: String = annotationData["annotationId"] as! String
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let infoWindow :Dictionary<String, Any> = annotationData["infoWindow"] as! Dictionary<String, Any>
        self.title = infoWindow["title"] as? String
        self.subtitle = infoWindow["snippet"] as? String
        self.id = annotationData["annotationId"] as? String
        self.isVisible = annotationData["visible"] as? Bool
        let anchorData = annotationData["anchor"] as! Array<Float>
        self.anchor = CGPoint(x: CGFloat(anchorData[0]), y: CGFloat(anchorData[1]))
        if let alpha :Double = annotationData["alpha"] as? Double {
            self.alpha = alpha
        }
        self.icon = FlutterAnnotation.getAnnotationIcon(registrar: registrar, iconData: annotationData["icon"] as! Array<Any>, annotationId: id)
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
        let updatedIcon: AnnotationIcon = FlutterAnnotation.getAnnotationIcon(registrar: registrar, iconData: iconData, annotationId: self.id)
        let updatedVisibility: Bool = updatedAnnotationData["visible"] as! Bool
        let anchorData = updatedAnnotationData["anchor"] as! Array<Float>
        let updatedAnchor = CGPoint(x: CGFloat(anchorData[0]), y: CGFloat(anchorData[1]))
        
        if (updatedTitle != self.title) {
            self.title = updatedTitle
            didUpdate = true
        }
        
        if let oldIcon = self.icon as? PinAnnotationIcon,
            let newIcon = updatedIcon as? PinAnnotationIcon {
            if oldIcon != newIcon {
                self.icon = newIcon
                didUpdate = true
            }
        } else if let oldIcon = self.icon as? CustomAnnotationIcon,
            let newIcon = updatedIcon as? CustomAnnotationIcon {
            if oldIcon != newIcon {
                self.icon = newIcon
                didUpdate = true
            }
        } else {
            self.icon = updatedIcon
            didUpdate = true
        }
        
        if (updatedAnchor.x != self.anchor.x || updatedAnchor.y != self.anchor.y) {
            self.anchor = updatedAnchor
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
        if (self.isVisible != updatedVisibility) {
            self.isVisible = updatedVisibility
            didUpdate = true
        }
        return didUpdate
    }
    
    private static func getAnnotationIcon(registrar: FlutterPluginRegistrar, iconData: Array<Any>, annotationId: String) -> AnnotationIcon {
        let iconTypeMap: Dictionary<String, IconType> = ["fromAssetImage": IconType.CUSTOM, "defaultAnnotation": IconType.PIN]
        let iconType: IconType = iconTypeMap[iconData[0] as! String] ?? .PIN
       
        if (iconType == .CUSTOM) {
            let assetPath: String = iconData[1] as! String
            let scaleParam = iconData[2] as? Float ?? 1.0
            return CustomAnnotationIcon(named: registrar.lookupKey(forAsset: assetPath), id: annotationId, iconScale: scaleParam)
        } else {
            let pinColorData = iconData[1] as! Array<Any>
            let pinColorType = pinColorData[0] as! String
            var pinColor: PinColor = .RED
            var customColor: UIColor? = nil
            
            switch pinColorType {
            case "red":
                pinColor = .RED
            case "green":
                pinColor = .GREEN
            case "purple":
                pinColor = .PURPLE
            case "custom":
                pinColor = .CUSTOM
                customColor = JsonConversions.convertColor(data: pinColorData[1])
            default:
                pinColor = .RED
            }
            
            return PinAnnotationIcon(id: annotationId, pinColor: pinColor, customColor: customColor)
        }
    }
}

enum IconType {
    case PIN, STANDARD, CUSTOM
}

protocol AnnotationIcon {}

class PinAnnotationIcon : AnnotationIcon, Equatable {
    let id: String
    let pinColor: PinColor
    let customColor: UIColor?
    
    public init(id: String, pinColor: PinColor = .RED, customColor: UIColor? = nil) {
        self.id = id
        self.pinColor = pinColor
        self.customColor = customColor
    }
    
    static func == (lhs: PinAnnotationIcon, rhs: PinAnnotationIcon) -> Bool {
        return lhs.pinColor == rhs.pinColor && lhs.customColor == rhs.customColor
    }
}

class CustomAnnotationIcon : AnnotationIcon, Equatable {
    let id: String
    let image: UIImage?
    let name: String
    let iconScale: Float
    
    public init(named name: String, id: String, iconScale: Float? = 1.0) {
        self.id = id
        self.name = name
        self.iconScale = iconScale ?? 1.0
        
        if let uiImage: UIImage =  UIImage.init(named: name) {
            if let cgImage: CGImage = uiImage.cgImage {
                if (iconScale != nil && iconScale! - 1 > 0.001) {
                    let scaledImage: UIImage = UIImage.init(cgImage: cgImage, scale: CGFloat(iconScale! + 1) * CGFloat(uiImage.scale), orientation: uiImage.imageOrientation)
                    self.image = scaledImage
                } else {
                    self.image = uiImage
                }
            } else {
                self.image = uiImage
            }
        } else {
            self.image = nil
        }
    }
    
    static func == (lhs: CustomAnnotationIcon, rhs: CustomAnnotationIcon) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.iconScale == rhs.iconScale
    }
}

enum PinColor {
    case RED, GREEN, PURPLE, CUSTOM
}
