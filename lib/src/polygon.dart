// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// Uniquely identifies a [Polygon] among [AppleMap] polygons.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class PolygonId {
  /// Creates an immutable identifier for a [Polygon].
  PolygonId(this.value);

  /// value of the [PolygonId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PolygonId) return false;
    final PolygonId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'PolygonId{value: $value}';
  }
}

/// Draws a polygon through geographical locations on the map.
@immutable
class Polygon {
  /// Creates an immutable representation of a polygon through geographical locations on the map.
  const Polygon({
    required this.polygonId,
    this.consumeTapEvents = false,
    this.fillColor = Colors.black,
    this.points = const <LatLng>[],
    this.strokeColor = Colors.black,
    this.strokeWidth = 10,
    this.visible = true,
    this.zIndex,
    this.onTap,
  });

  /// Uniquely identifies a [Polygon].
  final PolygonId polygonId;

  /// True if the [Polygon] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Fill color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color fillColor;

  /// The vertices of the polygon to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polygon is not closed by
  /// default; to form a closed polygon, the start and end points must be the same.
  final List<LatLng> points;

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the polygon, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int? zIndex;

  /// Line color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color strokeColor;

  /// Width of the polygon, used to define the width of the line to be drawn.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final int strokeWidth;

  /// Callbacks to receive tap events for polygon placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Polygon] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polygon copyWith({
    bool? consumeTapEventsParam,
    List<LatLng>? pointsParam,
    Color? strokeColorParam,
    Color? fillColorParam,
    int? strokeWidthParam,
    bool? visibleParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
  }) {
    return Polygon(
      polygonId: polygonId,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      points: pointsParam ?? points,
      strokeColor: strokeColorParam ?? strokeColor,
      fillColor: fillColorParam ?? fillColor,
      strokeWidth: strokeWidthParam ?? strokeWidth,
      visible: visibleParam ?? visible,
      zIndex: zIndexParam ?? zIndex,
      onTap: onTapParam ?? onTap,
    );
  }

  /// Creates a new [Polygon] object whose values are the same as this instance.
  Polygon clone() {
    return copyWith(pointsParam: List<LatLng>.of(points));
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('polygonId', polygonId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('fillColor', fillColor.value);
    addIfPresent('strokeColor', strokeColor.value);
    addIfPresent('strokeWidth', strokeWidth);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

    json['points'] = _pointsToJson();

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Polygon) return false;
    final Polygon typedOther = other;
    return polygonId == typedOther.polygonId &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        fillColor == typedOther.fillColor &&
        listEquals(points, typedOther.points) &&
        visible == typedOther.visible &&
        strokeColor == typedOther.strokeColor &&
        strokeWidth == typedOther.strokeWidth &&
        zIndex == typedOther.zIndex &&
        onTap == typedOther.onTap;
  }

  @override
  int get hashCode => polygonId.hashCode;

  dynamic _pointsToJson() {
    final List<dynamic> result = <dynamic>[];
    for (final LatLng point in points) {
      result.add(point._toJson());
    }
    return result;
  }
}

Map<PolygonId, Polygon> _keyByPolygonId(Iterable<Polygon>? polygons) {
  if (polygons == null) {
    return <PolygonId, Polygon>{};
  }
  return Map<PolygonId, Polygon>.fromEntries(polygons.map((Polygon polygon) =>
      MapEntry<PolygonId, Polygon>(polygon.polygonId, polygon.clone())));
}

List<Map<String, dynamic>>? _serializePolygonSet(Set<Polygon>? polygons) {
  if (polygons == null) {
    return null;
  }
  return polygons
      .map<Map<String, dynamic>>((Polygon p) => p._toJson())
      .toList();
}
