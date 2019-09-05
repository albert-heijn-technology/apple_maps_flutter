// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// Type of map tiles to display.
// Enum constants must be indexed to match the corresponding int constants of
// the Android platform API, see
// <https://developers.google.com/android/reference/com/google/android/gms/maps/AppleMap.html#MAP_TYPE_NORMAL>
enum MapType {
  /// Normal tiles (traffic and labels, subtle terrain information).
  standard,

  /// Satellite imaging tiles (aerial photos)
  satellite,

  /// Hybrid tiles (satellite images with some labels/overlays)
  hybrid,
}

enum TrackingMode {
  // the user's location is not followed
  none,

  // the map follows the user's location
  follow,

  // the map follows the user's location and heading
  followWithHeading,
}

/// Bounds for the map camera target.
// Used with [AppleMapOptions] to wrap a [LatLngBounds] value. This allows
// distinguishing between specifying an unbounded target (null `LatLngBounds`)
// from not specifying anything (null `CameraTargetBounds`).
class CameraTargetBounds {
  /// Creates a camera target bounds with the specified bounding box, or null
  /// to indicate that the camera target is not bounded.
  const CameraTargetBounds(this.bounds);

  /// The geographical bounding box for the map camera target.
  ///
  /// A null value means the camera target is unbounded.
  final LatLngBounds bounds;

  /// Unbounded camera target.
  static const CameraTargetBounds unbounded = CameraTargetBounds(null);

  dynamic _toJson() => <dynamic>[bounds?._toList()];

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraTargetBounds typedOther = other;
    return bounds == typedOther.bounds;
  }

  @override
  int get hashCode => bounds.hashCode;

  @override
  String toString() {
    return 'CameraTargetBounds(bounds: $bounds)';
  }
}

/// Exception when a map style is invalid or was unable to be set.
///
/// See also: `setStyle` on [AppleMapController] for why this exception
/// might be thrown.
class MapStyleException implements Exception {
  const MapStyleException(this.cause);

  final String cause;
}
