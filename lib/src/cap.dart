// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// Cap that can be applied at the start or end vertex of a [Polyline].
@immutable
class Cap {
  const Cap._(this._json);

  /// Cap that is squared off exactly at the start or end vertex of a [Polyline]
  /// with solid stroke pattern, equivalent to having no additional cap beyond
  /// the start or end vertex.
  ///
  /// This is the default cap type at start and end vertices of Polylines with
  /// solid stroke pattern.
  static const Cap buttCap = Cap._('buttCap');

  /// Cap that is a semicircle with radius equal to half the stroke width,
  /// centered at the start or end vertex of a [Polyline] with solid stroke
  /// pattern.
  static const Cap roundCap = Cap._('roundCap');

  /// Cap that is squared off after extending half the stroke width beyond the
  /// start or end vertex of a [Polyline] with solid stroke pattern.
  static const Cap squareCap = Cap._('squareCap');

  final dynamic _json;

  dynamic _toJson() => _json;
}
