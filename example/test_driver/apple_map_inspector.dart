// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/services.dart';

/// Inspect Apple Maps state using the platform SDK.
///
/// This class is primarily used for testing. The methods on this
/// class should call "getters" on the AppleMap object or equivalent
/// on the platform side.
class AppleMapInspector {
  AppleMapInspector(this._channel);

  final MethodChannel _channel;

  Future<bool?> isCompassEnabled() async {
    return await _channel.invokeMethod<bool>('map#isCompassEnabled');
  }

  Future<MinMaxZoomPreference> getMinMaxZoomLevels() async {
    final List<double> zoomLevels =
        (await _channel.invokeMethod<List<dynamic>>('map#getMinMaxZoomLevels'))!
            .cast<double>();
    return MinMaxZoomPreference(zoomLevels[0], zoomLevels[1]);
  }

  Future<bool?> isZoomGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isZoomGesturesEnabled');
  }

  Future<bool?> isRotateGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isRotateGesturesEnabled');
  }

  Future<bool?> isPitchGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isPitchGesturesEnabled');
  }

  Future<bool?> isScrollGesturesEnabled() async {
    return await _channel.invokeMethod<bool>('map#isScrollGesturesEnabled');
  }

  Future<bool?> isMyLocationButtonEnabled() async {
    return await _channel.invokeMethod<bool>('map#isMyLocationButtonEnabled');
  }
}
