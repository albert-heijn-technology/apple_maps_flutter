//
//  MapViewExtension.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 22.09.19.
//

import Foundation
import UIKit
import MapKit

private let MERCATOR_OFFSET: Double = 268435456.0
private let MERCATOR_RADIUS: Double = 85445659.44705395

public extension MKMapView {
    
    private struct Holder {
        static var _desiredZoomLevel = Int(0)
        static var _desiredPitch = CGFloat(0)
        static var _desiredHeading = CLLocationDirection(0)
        static var _oldBounds = CGRect()
    }
    
    // To calculate the displayed region we have to get the layout bounds.
    // Because the mapView is layed out using an auto layout we have to call
    // setCenterCoordinate after the mapView was layed out.
    override func layoutSubviews() {
        super.layoutSubviews()
        // Only update the centerCoordinate in layoutSubviews if the bounds changed
        if (self.bounds != Holder._oldBounds) {
            self.setCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: Holder._desiredZoomLevel, animated: false)
        }
        Holder._oldBounds = self.bounds
    }
  
    var zoomLevel: Int {
        get {
            let centerPixelSpaceX = self.longitudeToPixelSpaceX(longitude: self.centerCoordinate.longitude)

            let lonLeft = self.centerCoordinate.longitude - (self.region.span.longitudeDelta / 2)

            let leftPixelSpaceX = self.longitudeToPixelSpaceX(longitude: lonLeft)
            let pixelSpaceWidth = abs(centerPixelSpaceX - leftPixelSpaceX) * 2

            let zoomScale = pixelSpaceWidth / Double(self.bounds.size.width)

            let zoomExponent = self.logC(val: zoomScale, forBase: 2)

            let zoomLevel = round(20 - zoomExponent)
          
            return Int(zoomLevel)
        }
        set (newZoomLevel) {
            Holder._desiredZoomLevel = newZoomLevel
        }
    }
    
    func setCenterCoordinate(_ positionData: Dictionary<String, Any>, animated: Bool) {
        let targetList :Array<CLLocationDegrees> = positionData["target"] as? Array<CLLocationDegrees> ?? [self.camera.centerCoordinate.latitude, self.camera.centerCoordinate.longitude]
        let zoom :Int = positionData["zoom"] as? Int ?? Holder._desiredZoomLevel
        Holder._desiredZoomLevel = zoom
        if let pitch :CGFloat = positionData["pitch"] as? CGFloat {
            Holder._desiredPitch = pitch
        }
        if let heading :CLLocationDirection = positionData["heading"] as? CLLocationDirection {
            Holder._desiredHeading = heading
        }
        let centerCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:  targetList[0], longitude: targetList[1])
        if #available(iOS 9.0, *) {
            self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: zoom, animated: animated)
        } else {
            self.setCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: zoom, animated: animated)
        }
    }
    
    func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * .pi / 180.0);
    }
    
    func latitudeToPixelSpaceY(latitude: Double) -> Double {
        return round(Double(Float(MERCATOR_OFFSET) - Float(MERCATOR_RADIUS) * logf((1 + sinf(Float(latitude * .pi / 180.0))) / (1 - sinf(Float(latitude * .pi / 180.0)))) / Float(2.0)))
    }
    
    func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / .pi;
    }
    
    func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / .pi;
    }
    
    func coordinateSpanWithMapView(mapView: MKMapView, centerCoordinate: CLLocationCoordinate2D, zoomLevel: Int) -> MKCoordinateSpan  {
        // convert center coordiate to pixel space
        let centerPixelX = self.longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = self.latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent = Double(21 - max(zoomLevel, 1))
        let zoomScale = pow(2.0, zoomExponent)

        // scale the map’s size in pixel space
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale;
    
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
        // find delta between left and right longitudes
        let minLng = self.pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = self.pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng;
    
        // find delta between top and bottom latitudes
        let minLat = self.pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = self.pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
    
        // create and return the lat/lng span
        return MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
    }
    
    func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }
    
    func setCenterCoordinate(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        // clamp large numbers to 28
        let zoomL = min(zoomLevel, 28);
    
        // use the zoom level to compute the region
        let span = self.coordinateSpanWithMapView(mapView: self, centerCoordinate: centerCoordinate, zoomLevel: zoomL)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        
        // set the region like normal
        self.setRegion(region, animated: animated)
        
        // Setting the pitch/heading doesn't work while animating yet.
        // The animation will stop if the you change camera properties while it's running.
        if (!animated) {
            self.camera.pitch = Holder._desiredPitch
            self.camera.heading = Holder._desiredHeading
        }
    }
    
    @available(iOS 9.0, *)
    func setCenterCoordinateWithAltitude(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        // clamp large numbers to 28
        let zoomL = min(zoomLevel, 28);
    
        // let c = Float(Double.pi * 2 * 6378137)
        
        // let altitude = Float(6378137) + ( c * cosf(Float(centerCoordinate.latitude)) / powf(2, Float(zoomL)))
        // let altitude = Int(591657550.500000 / 2)^(zoomL-1)
        //this equation is a transformation of the angular size equation solving for D. See: http://en.wikipedia.org/wiki/Forced_perspective
        let firstPartOfEq = (0.05 * ((591657550.5/(powf(2,(Float(zoomL-1)))))/2)) //amount displayed is .05 meters and map scale =591657550.5/(Math.pow(2,(mapzoom-1))))
        //this bit ^ essentially gets the h value in the angular size eq then divides it by 2
        let altitude = firstPartOfEq * (cosf(deg2rad(85.362/2))) / sinf(deg2rad(85.362/2))  //85.362 is angle which google maps displays on a 5cm wide screen
        self.setCamera(MKMapCamera(lookingAtCenter: centerCoordinate, fromDistance: CLLocationDistance(altitude), pitch: Holder._desiredPitch, heading: Holder._desiredHeading), animated: animated)
    }
    
    func deg2rad(_ number: Double) -> Float {
        return Float(number * .pi / 180)
    }
    
    
    
    func zoomIn(animated: Bool) {
        zoomLevel += 1
        if #available(iOS 9.0, *) {
            self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: Holder._desiredZoomLevel, animated: animated)
        } else {
            self.setCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: Holder._desiredZoomLevel, animated: animated)
        }
    }
    
    func zoomOut(animated: Bool) {
        zoomLevel -= 1
        if #available(iOS 9.0, *) {
            self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: Holder._desiredZoomLevel, animated: animated)
        } else {
            self.setCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: Holder._desiredZoomLevel, animated: animated)
        }
    }
    
    func zoomTo(zoomLevel: Int, animated: Bool) {
         if #available(iOS 9.0, *) {
                   self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel, animated: animated)
               } else {
                   self.setCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel, animated: animated)
               }
    }
    
    func updateCameraValues() {
        Holder._desiredZoomLevel = zoomLevel
        Holder._desiredPitch = camera.pitch
        Holder._desiredHeading = camera.heading
    }
}
