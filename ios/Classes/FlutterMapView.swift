//
//  FlutterAppleMap.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.10.19.
//

import Foundation
import MapKit

private let MERCATOR_OFFSET: Double = 268435456.0
private let MERCATOR_RADIUS: Double = 85445659.44705395

class FlutterMapView: MKMapView, UIGestureRecognizerDelegate {
    
    var oldBounds: CGRect?
    var mapContainerView: UIView?
    var channel: FlutterMethodChannel?
    
    convenience init(channel: FlutterMethodChannel) {
        self.init(frame: CGRect.zero)
        self.channel = channel
        initialiseTapGestureRecognizers()
    }
    
    var actualHeading: CLLocationDirection {
        get {
            if mapContainerView != nil {
                var heading: CLLocationDirection = fabs(180 * asin(Double(mapContainerView!.transform.b)) / .pi)
                if mapContainerView!.transform.b <= 0 {
                    if mapContainerView!.transform.a >= 0 {
                        // do nothing
                    } else {
                        heading = 180 - heading
                    }
                } else {
                    if mapContainerView!.transform.a <= 0 {
                        heading = heading + 180
                    } else {
                        heading = 360 - heading
                    }
                }
                return heading
            }
            return CLLocationDirection.zero
        }
    }
    
    // To calculate the displayed region we have to get the layout bounds.
    // Because the mapView is layed out using an auto layout we have to call
    // setCenterCoordinate after the mapView was layed out.
    override func layoutSubviews() {
        super.layoutSubviews()
        // Only update the centerCoordinate in layoutSubviews if the bounds changed
        if (self.bounds != oldBounds) {
            if #available(iOS 9.0, *) {
                setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel, animated: false)
                mapContainerView = self.findViewOfType("MKScrollContainerView", inView: self)
            } else {
                setCenterCoordinateRegion(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel, animated: false)
            }
        }
        oldBounds = self.bounds
    }
    
    
    override func didMoveToSuperview() {
        if (oldBounds != CGRect.zero) {
            oldBounds = CGRect.zero
        }
    }
    
    private func findViewOfType(_ viewType: String, inView view: UIView) -> UIView? {
      // function scans subviews recursively and returns
      // reference to the found one of a type
      if view.subviews.count > 0 {
        for v in view.subviews {
          let valueDescription = v.description
          let keywords = viewType
          if valueDescription.range(of: keywords) != nil {
            return v
          }
          if let inSubviews = self.findViewOfType(viewType, inView: v) {
            return inSubviews
          }
        }
        return nil
      } else {
        return nil
      }
    }
    
    // Functions used for GestureRecognition
    private func initialiseTapGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onMapGesture))
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onMapGesture))
        pinchGesture.delegate = self
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(onMapGesture))
        rotateGesture.delegate = self
        let tiltGesture = UISwipeGestureRecognizer(target: self, action: #selector(onMapGesture))
        tiltGesture.numberOfTouchesRequired = 2
        tiltGesture.direction = .up
        tiltGesture.direction = .down
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: nil)
        doubleTapGesture.numberOfTapsRequired = 2
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGesture.require(toFail: doubleTapGesture)    // only recognize taps that are not involved in zooming
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(pinchGesture)
        self.addGestureRecognizer(rotateGesture)
        self.addGestureRecognizer(tiltGesture)
        self.addGestureRecognizer(longTapGesture)
        self.addGestureRecognizer(doubleTapGesture)
        self.addGestureRecognizer(tapGesture)
    }
       
    @objc func onMapGesture(sender: UIGestureRecognizer) {
        let locationOnMap = self.region.center // mapView.convert(locationInView, toCoordinateFrom: mapView)
        let zoom = self.calculatedZoomLevel
        let pitch = self.camera.pitch
        let heading = self.actualHeading
        self.updateCameraValues()
        channel?.invokeMethod("camera#onMove", arguments: ["position": ["heading": heading, "target":  [locationOnMap.latitude, locationOnMap.longitude], "pitch": pitch, "zoom": zoom]])
    }

    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
           let locationInView = sender.location(in: self)
           let locationOnMap = self.convert(locationInView, toCoordinateFrom: self)
           
           channel?.invokeMethod("map#onLongPress", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
        }
    }

    @objc func onTap(sender: UIGestureRecognizer) {
        let locationInView = sender.location(in: self)
        let locationOnMap = self.convert(locationInView, toCoordinateFrom: self)

        channel?.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
    }
    
    public func updateCameraValues() {
        if (oldBounds != nil && oldBounds != CGRect.zero) {
            self.updateStoredCameraValues(newZoomLevel: calculatedZoomLevel, newPitch: camera.pitch, newHeading: actualHeading)
        }
    }
    
    // Always allow multiple gestureRecognizers
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
