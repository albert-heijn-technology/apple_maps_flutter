//
//  FlutterAppleMap.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.10.19.
//

import Foundation
import MapKit
import CoreLocation

private let MERCATOR_OFFSET: Double = 268435456.0
private let MERCATOR_RADIUS: Double = 85445659.44705395

class FlutterMapView: MKMapView, UIGestureRecognizerDelegate {
    
    var oldBounds: CGRect?
    var mapContainerView: UIView?
    var channel: FlutterMethodChannel?
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    var isMyLocationButtonShowing: Bool? = false
    
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
        if self.bounds != oldBounds {
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
        if oldBounds != CGRect.zero {
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
    
    public func setUserLocation(myLocationEnabled :Bool) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() ==  .authorizedWhenInUse {
            if (myLocationEnabled) {
               locationManager.requestWhenInUseAuthorization()
               locationManager.desiredAccuracy = kCLLocationAccuracyBest
               locationManager.distanceFilter = kCLDistanceFilterNone
               locationManager.startUpdatingLocation()
            } else {
               locationManager.stopUpdatingLocation()
            }
            self.showsUserLocation = myLocationEnabled
        }
    }
    
    // Functions used for the mapTrackingButton
    func mapTrackingButton(isVisible visible: Bool) {
        self.isMyLocationButtonShowing = visible
        if visible {
           let image = UIImage(named: "outline_near_me")
           let locationButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
           locationButton.tag = 100
           locationButton.layer.cornerRadius = 5
           locationButton.frame = CGRect(origin: CGPoint(x: self.bounds.width - 45, y: self.bounds.height - 45), size: CGSize(width: 40, height: 40))
           locationButton.setImage(image, for: .normal)
           locationButton.backgroundColor = .white
           locationButton.alpha = 0.8
           locationButton.addTarget(self, action: #selector(centerMapOnUserButtonClicked), for:.touchUpInside)
           self.addSubview(locationButton)
        } else {
           if let _locationButton = self.viewWithTag(100) {
               _locationButton.removeFromSuperview()
           }
        }
    }
    
    @objc func centerMapOnUserButtonClicked() {
       self.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
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

    @objc func onTap(tap: UITapGestureRecognizer) {
        let locationInView = tap.location(in: self)
        if tap.state == .recognized && tap.state == .recognized {
            // Get map coordinate from touch point
            let touchPt: CGPoint = tap.location(in: self)
            let coord: CLLocationCoordinate2D = self.convert(touchPt, toCoordinateFrom: self)
            let maxMeters: Double = meters(fromPixel: 10, at: touchPt)
            var nearestDistance: Float = MAXFLOAT
            var nearestPoly: FlutterPolyline? = nil
            for overlay: MKOverlay in self.overlays {
                if overlay is FlutterPolyline {
                    let distance: Float = Float(distanceOf(pt: MKMapPoint.init(coord), toPoly: overlay as! MKPolyline))
                    if distance < nearestDistance {
                        nearestDistance = distance
                        nearestPoly = (overlay as! FlutterPolyline)
                    }

                }
            }

            if Double(nearestDistance) <= maxMeters {
                if (nearestPoly?.isConsumingTapEvents ?? false) {
                    channel?.invokeMethod("polyline#onTap", arguments: ["polylineId": nearestPoly!.id])
                } else {
                    let locationOnMap = self.convert(locationInView, toCoordinateFrom: self)
                    channel?.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
                }
            } else {
                let locationOnMap = self.convert(locationInView, toCoordinateFrom: self)
                channel?.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
            }
        }
    }
    
    public func updateCameraValues() {
        if oldBounds != nil && oldBounds != CGRect.zero {
            self.updateStoredCameraValues(newZoomLevel: calculatedZoomLevel, newPitch: camera.pitch, newHeading: actualHeading)
        }
    }
    
    // Always allow multiple gestureRecognizers
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
        var distance: Double = Double(MAXFLOAT)
        for n in 0..<poly.pointCount - 1 {
            let ptA = poly.points()[n]
            let ptB = poly.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points must not be equal
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            }
            else if u > 1.0 {
                ptClosest = ptB
            }
            else {
                ptClosest = MKMapPoint.init(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }

            distance = min(distance, ptClosest.distance(to: pt))
        }
        return distance
    }

    func meters(fromPixel px: Int, at pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = self.convert(pt, toCoordinateFrom: self)
        let coordB: CLLocationCoordinate2D = self.convert(ptB, toCoordinateFrom: self)
        return MKMapPoint.init(coordA).distance(to: MKMapPoint.init(coordB))
    }
}
