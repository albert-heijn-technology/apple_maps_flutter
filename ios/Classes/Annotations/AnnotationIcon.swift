//
//  AnnotationIcon.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 07.03.20.
//

import Foundation

enum IconType {
    case PIN, MARKER, CUSTOM
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
        self.iconType = type!
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
