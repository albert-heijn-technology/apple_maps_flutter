//
//  AnnotationIcon.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 07.03.20.
//

import Foundation

enum IconType {
    case PIN, MARKER, CUSTOM_FROM_ASSET, CUSTOM_FROM_BYTES
}

class AnnotationIcon: Equatable {
    
    var iconType: IconType
    var id: String
    var image: UIImage?
    
    public init(id: String, iconType: IconType) {
        self.iconType = iconType
        self.id = id
    }
    
    public init(named name: String, id: String, iconScale: CGFloat? = 1.0) {
        self.iconType = .CUSTOM_FROM_ASSET
        self.id = id
        if let uiImage: UIImage =  UIImage.init(named: name) {
            self.image = self.scaleImage(image: uiImage, scale: iconScale!)
        }
    }
    
    public init(fromBytes bytes: FlutterStandardTypedData, id: String) {
        let screenScale = UIScreen.main.scale
        let image = UIImage.init(data: bytes.data, scale: screenScale)
        self.image = image
        self.iconType = .CUSTOM_FROM_BYTES
        self.id = id
    }
    
    public convenience init() {
        self.init(id: "", iconType: .PIN)
    }
    
    private func scaleImage(image: UIImage, scale: CGFloat) -> UIImage {
        guard let cgImage = image.cgImage else {
            return image
        }
        guard abs(scale - 1) >= 0 else {
            return image
        }
        return UIImage.init(cgImage: cgImage, scale: 4.0, orientation: image.imageOrientation)
    }
    
    static func == (lhs: AnnotationIcon, rhs: AnnotationIcon) -> Bool {
        return lhs.iconType == rhs.iconType && lhs.id == rhs.id && lhs.image == rhs.image
    }
    
    static func != (lhs: AnnotationIcon, rhs: AnnotationIcon) -> Bool {
        return !(lhs == rhs)
    }
}
