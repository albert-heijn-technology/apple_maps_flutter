// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// Bounds for the map camera target.
// Used with [AppleMapOptions] to wrap a [LatLngBounds] value. This allows
// distinguishing between specifying an unbounded target (null `LatLngBounds`)
// from not specifying anything (null `CameraTargetBounds`).
class CameraTargetBounds {
  /// Unbounded camera target.
  static const CameraTargetBounds unbounded = CameraTargetBounds(null);

  /// The geographical bounding box for the map camera target.
  ///
  /// A null value means the camera target is unbounded.
  final LatLngBounds? bounds;

  /// Creates a camera target bounds with the specified bounding box, or null
  /// to indicate that the camera target is not bounded.
  const CameraTargetBounds(this.bounds);

  @override
  int get hashCode => bounds.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraTargetBounds typedOther = other;
    return bounds == typedOther.bounds;
  }

  @override
  String toString() {
    return 'CameraTargetBounds(bounds: $bounds)';
  }
}

/// Type of map tiles to display.
enum MapType {
  /// Normal tiles (traffic and labels, subtle terrain information).
  standard,

  /// Satellite imaging tiles (aerial photos)
  satellite,

  /// Hybrid tiles (satellite images with some labels/overlays)
  hybrid,
}

class MinMaxZoomPreference {
  /// Unbounded zooming.
  static const MinMaxZoomPreference unbounded =
      MinMaxZoomPreference(null, null);

  /// The preferred minimum zoom level or null, if unbounded from below.
  final double? minZoom;

  /// The preferred maximum zoom level or null, if unbounded from above.
  final double? maxZoom;

  const MinMaxZoomPreference(this.minZoom, this.maxZoom)
      : assert(minZoom == null || maxZoom == null || minZoom <= maxZoom);

  @override
  int get hashCode => Object.hash(minZoom, maxZoom);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final MinMaxZoomPreference typedOther = other;
    return minZoom == typedOther.minZoom && maxZoom == typedOther.maxZoom;
  }

  @override
  String toString() {
    return 'MinMaxZoomPreference(minZoom: $minZoom, maxZoom: $maxZoom)';
  }

  dynamic _toJson() => <dynamic>[minZoom, maxZoom];
}

enum TrackingMode {
  // the user's location is not followed
  none,

  // the map follows the user's location
  follow,

  // the map follows the user's location and heading
  followWithHeading,
}
