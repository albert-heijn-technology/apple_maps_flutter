//
//  FlutterAppleMap.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.10.19.
//

import Foundation
import MapKit
import CoreLocation

enum BUTTON_IDS: Int {
    case LOCATION = 100
}


class FlutterMapView: MKMapView, UIGestureRecognizerDelegate {
    var oldBounds: CGRect?
    var mapContainerView: UIView?
    var channel: FlutterMethodChannel?
    var options: Dictionary<String, Any>?
    var isMyLocationButtonShowing: Bool? = false
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    
    let mapTypes: Array<MKMapType> = [
        MKMapType.standard,
        MKMapType.satellite,
        MKMapType.hybrid,
    ]
    
    let userTrackingModes: Array<MKUserTrackingMode> = [
        MKUserTrackingMode.none,
        MKUserTrackingMode.follow,
        MKUserTrackingMode.followWithHeading,
    ]
    
    convenience init(channel: FlutterMethodChannel, options: Dictionary<String, Any>) {
        self.init(frame: CGRect.zero)
        self.channel = channel
        self.options = options
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
    // Because the self is layed out using an auto layout we have to call
    // setCenterCoordinate after the self was layed out.
    override func layoutSubviews() {
        // Only update the map in layoutSubviews if the bounds changed
        if self.bounds != oldBounds {
            if self.options != nil {
                self.interpretOptions(options: self.options!)
            }
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
    
    func interpretOptions(options: Dictionary<String, Any>) {
        if let isCompassEnabled: Bool = options["compassEnabled"] as? Bool {
            if #available(iOS 9.0, *) {
                self.showsCompass = isCompassEnabled
            }
        }

        if let padding: Array<Any> = options["padding"] as? Array<Any> {
            var margins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            
            if padding.count >= 1, let top: Double = padding[0] as? Double {
                margins.top = CGFloat(top)
            }
            
            if padding.count >= 2, let left: Double = padding[1] as? Double {
                margins.left = CGFloat(left)
            }
            
            if padding.count >= 3, let bottom: Double = padding[2] as? Double {
                margins.bottom = CGFloat(bottom)
            }
            
            if padding.count >= 4, let right: Double = padding[3] as? Double {
                margins.right = CGFloat(right)
            }
            
            self.layoutMargins = margins
        }
        
        if let mapType: Int = options["mapType"] as? Int {
            self.mapType = self.mapTypes[mapType]
        }
        
        if let trafficEnabled: Bool = options["trafficEnabled"] as? Bool {
            if #available(iOS 9.0, *) {
                self.showsTraffic = trafficEnabled
            } else {
                // do nothing
            }
        }
        
        if let rotateGesturesEnabled: Bool = options["rotateGesturesEnabled"] as? Bool {
            self.isRotateEnabled = rotateGesturesEnabled
        }
        
        if let scrollGesturesEnabled: Bool = options["scrollGesturesEnabled"] as? Bool {
            self.isScrollEnabled = scrollGesturesEnabled
        }
        
        if let pitchGesturesEnabled: Bool = options["pitchGesturesEnabled"] as? Bool {
            self.isPitchEnabled = pitchGesturesEnabled
        }
        
        if let zoomGesturesEnabled: Bool = options["zoomGesturesEnabled"] as? Bool{
            self.isZoomEnabled = zoomGesturesEnabled
        }
        
        if let myLocationEnabled: Bool = options["myLocationEnabled"] as? Bool {
            if (myLocationEnabled) {
                self.setUserLocation()
            } else {
                self.removeUserLocation()
            }
            
        }
        
        if let myLocationButtonEnabled: Bool = options["myLocationButtonEnabled"] as? Bool {
            self.mapTrackingButton(isVisible: myLocationButtonEnabled)
        }
        
        if let userTackingMode: Int = options["trackingMode"] as? Int {
            self.setUserTrackingMode(self.userTrackingModes[userTackingMode], animated: false)
        }
        
        if let minMaxZoom: Array<Any> = options["minMaxZoomPreference"] as? Array<Any>{
            if let _minZoom: Double = minMaxZoom[0] as? Double {
                self.minZoomLevel = _minZoom
            }
            if let _maxZoom: Double = minMaxZoom[1] as? Double {
                self.maxZoomLevel = _maxZoom
            }
        }
    }
    
    public func setUserLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() ==  .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            self.showsUserLocation = true
        }
    }
    
    public func removeUserLocation() {
        locationManager.stopUpdatingLocation()
        self.showsUserLocation = false
    }
    
    // Functions used for the mapTrackingButton
    func mapTrackingButton(isVisible visible: Bool) {
        self.isMyLocationButtonShowing = visible
        if visible {
            let image = UIImage(named: "outline_near_me")
            let locationButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
            locationButton.tag = BUTTON_IDS.LOCATION.rawValue
            locationButton.layer.cornerRadius = 5
            locationButton.frame = CGRect(origin: CGPoint(x: self.bounds.width - 45, y: self.bounds.height - 45), size: CGSize(width: 40, height: 40))
            locationButton.setImage(image, for: .normal)
            locationButton.backgroundColor = .white
            locationButton.alpha = 0.8
            locationButton.addTarget(self, action: #selector(centerMapOnUserButtonClicked), for:.touchUpInside)
            self.addSubview(locationButton)
        } else {
            if let _locationButton = self.viewWithTag(BUTTON_IDS.LOCATION.rawValue) {
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
        let locationOnMap = self.region.center // self.convert(locationInView, toCoordinateFrom: self)
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
                    let distance: Float = Float(distanceOf(pt: MKMapPointForCoordinate(coord), toPoly: overlay as! MKPolyline))
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

            distance = min(distance, MKMetersBetweenMapPoints(ptClosest, pt))
        }
        return distance
    }

    func meters(fromPixel px: Int, at pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = self.convert(pt, toCoordinateFrom: self)
        let coordB: CLLocationCoordinate2D = self.convert(ptB, toCoordinateFrom: self)
        return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB))
    }
}
