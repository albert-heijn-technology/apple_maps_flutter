// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

typedef void MapCreatedCallback(AppleMapController controller);

/// Callback that receives updates to the camera position.
///
/// This callback is triggered when the platform Google Map
/// registers a camera movement.
///
/// This is used in [AppleMap.onCameraMove].
typedef void CameraPositionCallback(CameraPosition position);

class AppleMap extends StatefulWidget {
  const AppleMap({
    Key key,
    @required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.trafficEnabled = false,
    this.mapType = MapType.standard,
    this.trackingMode = TrackingMode.none,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.pitchGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.markers,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  })  : assert(initialCameraPosition != null),
        super(key: key);

  final MapCreatedCallback onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should display the current traffic.
  final bool trafficEnabled;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// The mode used to track the user location.
  final TrackingMode trackingMode;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool pitchGesturesEnabled;

  /// Markers to be placed on the map.
  final Set<Marker> markers;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback onCameraIdle;

  /// Called every time a [AppleMap] is tapped.
  final ArgumentCallback<LatLng> onTap;

  /// Called every time a [AppleMap] is long pressed.
  final ArgumentCallback<LatLng> onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State createState() => _AppleMapState();
}

class _AppleMapState extends State<AppleMap> {
  final Completer<AppleMapController> _controller =
      Completer<AppleMapController>();

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  _AppleMapOptions _appleMapOptions;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition?._toMap(),
      'options': _appleMapOptions.toMap(),
      'markersToAdd': _serializeMarkerSet(widget.markers),
    };
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.flutter.io/apple_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }

  @override
  void initState() {
    super.initState();
    _appleMapOptions = _AppleMapOptions.fromWidget(widget);
    _markers = _keyByMarkerId(widget.markers);
  }

  @override
  void didUpdateWidget(AppleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
    _updateMarkers();
  }

  void _updateOptions() async {
    final _AppleMapOptions newOptions = _AppleMapOptions.fromWidget(widget);
    final Map<String, dynamic> updates =
        _appleMapOptions.updatesMap(newOptions);
    if (updates.isEmpty) {
      return;
    }
    final AppleMapController controller = await _controller.future;
    controller._updateMapOptions(updates);
    _appleMapOptions = newOptions;
  }

  void _updateMarkers() async {
    final AppleMapController controller = await _controller.future;
    controller._updateMarkers(
        _MarkerUpdates.from(_markers.values.toSet(), widget.markers));
    _markers = _keyByMarkerId(widget.markers);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final AppleMapController controller = await AppleMapController.init(
      id,
      widget.initialCameraPosition,
      this,
    );
    _controller.complete(controller);
    if (widget.onMapCreated != null) {
      widget.onMapCreated(controller);
    }
  }

  void onMarkerTap(String markerIdParam) {
    assert(markerIdParam != null);
    final MarkerId markerId = MarkerId(markerIdParam);
    if (_markers[markerId]?.onTap != null) {
      _markers[markerId].onTap();
    }
  }

  void onMarkerDragEnd(String markerIdParam, LatLng position) {
    assert(markerIdParam != null);
    final MarkerId markerId = MarkerId(markerIdParam);
    if (_markers[markerId]?.onDragEnd != null) {
      _markers[markerId].onDragEnd(position);
    }
  }

  void onInfoWindowTap(String markerIdParam) {
    assert(markerIdParam != null);
    final MarkerId markerId = MarkerId(markerIdParam);
    if (_markers[markerId]?.infoWindow?.onTap != null) {
      _markers[markerId].infoWindow.onTap();
    }
  }

  void onTap(LatLng position) {
    assert(position != null);
    if (widget.onTap != null) {
      widget.onTap(position);
    }
  }

  void onLongPress(LatLng position) {
    assert(position != null);
    if (widget.onLongPress != null) {
      widget.onLongPress(position);
    }
  }
}

/// Configuration options for the AppleMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class _AppleMapOptions {
  _AppleMapOptions({
    this.compassEnabled,
    this.trafficEnabled,
    this.mapType,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.pitchGesturesEnabled,
    this.trackingMode,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
  });

  static _AppleMapOptions fromWidget(AppleMap map) {
    return _AppleMapOptions(
      compassEnabled: map.compassEnabled,
      trafficEnabled: map.trafficEnabled,
      mapType: map.mapType,
      rotateGesturesEnabled: map.rotateGesturesEnabled,
      scrollGesturesEnabled: map.scrollGesturesEnabled,
      pitchGesturesEnabled: map.pitchGesturesEnabled,
      trackingMode: map.trackingMode,
      zoomGesturesEnabled: map.zoomGesturesEnabled,
      myLocationEnabled: map.myLocationEnabled,
      myLocationButtonEnabled: map.myLocationButtonEnabled,
    );
  }

  final bool compassEnabled;

  final bool trafficEnabled;

  final MapType mapType;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  final bool pitchGesturesEnabled;

  final TrackingMode trackingMode;

  final bool zoomGesturesEnabled;

  final bool myLocationEnabled;

  final bool myLocationButtonEnabled;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    addIfNonNull('compassEnabled', compassEnabled);
    addIfNonNull('trafficEnabled', trafficEnabled);
    addIfNonNull('mapType', mapType?.index);
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('pitchGesturesEnabled', pitchGesturesEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('trackingMode', trackingMode?.index);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationButtonEnabled', myLocationButtonEnabled);
    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_AppleMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();

    return newOptions.toMap()
      ..removeWhere(
          (String key, dynamic value) => prevOptionsMap[key] == value);
  }
}
