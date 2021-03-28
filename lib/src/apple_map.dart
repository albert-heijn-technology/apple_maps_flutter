// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

typedef void MapCreatedCallback(AppleMapController controller);

/// Callback that receives updates to the camera position.
///
/// This callback is triggered when the platform Apple Map
/// registers a camera movement.
///
/// This is used in [AppleMap.onCameraMove].
typedef void CameraPositionCallback(CameraPosition position);

class AppleMap extends StatefulWidget {
  const AppleMap({
    Key? key,
    required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.trafficEnabled = false,
    this.mapType = MapType.standard,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.trackingMode = TrackingMode.none,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.pitchGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.padding = EdgeInsets.zero,
    this.annotations,
    this.polylines,
    this.circles,
    this.polygons,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final MapCreatedCallback? onMapCreated;

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

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool pitchGesturesEnabled;

  /// Annotations to be placed on the map.
  final Set<Annotation>? annotations;

  /// Polylines to be placed on the map.
  final Set<Polyline>? polylines;

  /// Circles to be placed on the map.
  final Set<Circle>? circles;

  /// Polygons to be placed on the map.
  final Set<Polygon>? polygons;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or annotation clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [AppleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [AppleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

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
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// The padding used on the map
  ///
  /// The amount of additional space (measured in screen points) used for padding for the
  /// native controls.
  final EdgeInsets padding;

  @override
  State createState() => _AppleMapState();
}

class _AppleMapState extends State<AppleMap> {
  final Completer<AppleMapController> _controller =
      Completer<AppleMapController>();

  Map<AnnotationId, Annotation> _annotations = <AnnotationId, Annotation>{};
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};
  Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  late _AppleMapOptions _appleMapOptions;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition._toMap(),
      'options': _appleMapOptions.toMap(),
      'annotationsToAdd': _serializeAnnotationSet(widget.annotations),
      'polylinesToAdd': _serializePolylineSet(widget.polylines),
      'polygonsToAdd': _serializePolygonSet(widget.polygons),
      'circlesToAdd': _serializeCircleSet(widget.circles),
    };
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'apple_maps_plugin.luisthein.de/apple_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the apple maps plugin');
  }

  @override
  void initState() {
    super.initState();
    _appleMapOptions = _AppleMapOptions.fromWidget(widget);
    _annotations = _keyByAnnotationId(widget.annotations);
    _polylines = _keyByPolylineId(widget.polylines);
    _polygons = _keyByPolygonId(widget.polygons);
    _circles = _keyByCircleId(widget.circles);
  }

  @override
  void didUpdateWidget(AppleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
    _updateAnnotations();
    _updatePolylines();
    _updatePolygons();
    _updateCircles();
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

  void _updateAnnotations() async {
    final AppleMapController controller = await _controller.future;
    controller._updateAnnotations(_AnnotationUpdates.from(
        _annotations.values.toSet(), widget.annotations));
    _annotations = _keyByAnnotationId(widget.annotations);
  }

  void _updatePolylines() async {
    final AppleMapController controller = await _controller.future;
    controller._updatePolylines(
        _PolylineUpdates.from(_polylines.values.toSet(), widget.polylines));
    _polylines = _keyByPolylineId(widget.polylines);
  }

  void _updatePolygons() async {
    final AppleMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updatePolygons(
        _PolygonUpdates.from(_polygons.values.toSet(), widget.polygons));
    _polygons = _keyByPolygonId(widget.polygons);
  }

  void _updateCircles() async {
    final AppleMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updateCircles(
        _CircleUpdates.from(_circles.values.toSet(), widget.circles));
    _circles = _keyByCircleId(widget.circles);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final AppleMapController controller = await AppleMapController.init(
      id,
      widget.initialCameraPosition,
      this,
    );
    _controller.complete(controller);
    widget.onMapCreated?.call(controller);
  }

  void onAnnotationTap(String annotationIdParam) {
    final AnnotationId annotationId = AnnotationId(annotationIdParam);
    _annotations[annotationId]?.onTap?.call();
  }

  void onAnnotationDragEnd(String annotationIdParam, LatLng position) {
    final AnnotationId annotationId = AnnotationId(annotationIdParam);
    _annotations[annotationId]?.onDragEnd?.call(position);
  }

  void onPolylineTap(String polylineIdParam) {
    final PolylineId polylineId = PolylineId(polylineIdParam);
    _polylines[polylineId]?.onTap?.call();
  }

  void onPolygonTap(String polygonIdParam) {
    final PolygonId polygonId = PolygonId(polygonIdParam);
    _polygons[polygonId]?.onTap?.call();
  }

  void onCircleTap(String circleIdParam) {
    final CircleId circleId = CircleId(circleIdParam);
    _circles[circleId]?.onTap?.call();
  }

  void onInfoWindowTap(String annotationIdParam) {
    final AnnotationId annotationId = AnnotationId(annotationIdParam);
    _annotations[annotationId]?.infoWindow.onTap?.call();
  }

  void onTap(LatLng position) {
    widget.onTap?.call(position);
  }

  void onLongPress(LatLng position) {
    widget.onLongPress?.call(position);
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
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.pitchGesturesEnabled,
    this.trackingMode,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.padding,
  });

  static _AppleMapOptions fromWidget(AppleMap map) {
    return _AppleMapOptions(
      compassEnabled: map.compassEnabled,
      trafficEnabled: map.trafficEnabled,
      mapType: map.mapType,
      minMaxZoomPreference: map.minMaxZoomPreference,
      rotateGesturesEnabled: map.rotateGesturesEnabled,
      scrollGesturesEnabled: map.scrollGesturesEnabled,
      pitchGesturesEnabled: map.pitchGesturesEnabled,
      trackingMode: map.trackingMode,
      zoomGesturesEnabled: map.zoomGesturesEnabled,
      myLocationEnabled: map.myLocationEnabled,
      myLocationButtonEnabled: map.myLocationButtonEnabled,
      padding: map.padding,
    );
  }

  final bool? compassEnabled;

  final bool? trafficEnabled;

  final MapType? mapType;

  final MinMaxZoomPreference? minMaxZoomPreference;

  final bool? rotateGesturesEnabled;

  final bool? scrollGesturesEnabled;

  final bool? pitchGesturesEnabled;

  final TrackingMode? trackingMode;

  final bool? zoomGesturesEnabled;

  final bool? myLocationEnabled;

  final bool? myLocationButtonEnabled;

  final EdgeInsets? padding;

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
    addIfNonNull('minMaxZoomPreference', minMaxZoomPreference?._toJson());
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('pitchGesturesEnabled', pitchGesturesEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('trackingMode', trackingMode?.index);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationButtonEnabled', myLocationButtonEnabled);
    addIfNonNull('padding', _serializePadding(padding));
    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_AppleMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();

    return newOptions.toMap()
      ..removeWhere(
          (String key, dynamic value) => prevOptionsMap[key] == value);
  }

  List<double>? _serializePadding(EdgeInsets? insets) {
    if (insets == null) return null;

    return [insets.top, insets.left, insets.bottom, insets.right];
  }
}
