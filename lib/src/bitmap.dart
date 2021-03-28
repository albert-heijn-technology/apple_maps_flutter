// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

enum AnnotationColor {
  RED,
  GREEN,
  PURPLE,
}

/// Defines a bitmap image. For a annotation, this class can be used to set the
/// image of the annotation icon. For a ground overlay, it can be used to set the
/// image to place on the surface of the earth.
class BitmapDescriptor {
  const BitmapDescriptor._(this._json);

  /// Creates a BitmapDescriptor that refers to the default/Pin annotation image.
  static const BitmapDescriptor defaultAnnotation =
      BitmapDescriptor._(<dynamic>['defaultAnnotation']);

  /// Creates a BitmapDescriptor that refers to the marker annotation image.
  static const BitmapDescriptor markerAnnotation =
      BitmapDescriptor._(<dynamic>['markerAnnotation']);

  /// Creates a BitmapDescriptor that refers to a colorization of the marker
  /// annotation image. For convenience, there is a predefined set of [AnnotationColors].
  /// See e.g. [AnnotationColor.RED].
  static BitmapDescriptor markerAnnotationWithColor(AnnotationColor color) {
    return BitmapDescriptor._(<dynamic>['markerAnnotation', color.index]);
  }

  /// Creates a BitmapDescriptor that refers to a colorization of the default/Pin
  /// annotation image. For convenience, there is a predefined set of [AnnotationColors].
  /// See e.g. [AnnotationColor.RED].
  static BitmapDescriptor defaultAnnotationWithColor(AnnotationColor color) {
    return BitmapDescriptor._(<dynamic>['defaultAnnotation', color.index]);
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// Asset images in flutter are stored per:
  /// https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets
  /// This method takes into consideration various asset resolutions
  /// and scales the images to the right resolution depending on the dpi.
  static Future<BitmapDescriptor> fromAssetImage(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    bool mipmaps = true,
  }) async {
    if (!mipmaps && configuration.devicePixelRatio != null) {
      return BitmapDescriptor._(<dynamic>[
        'fromAssetImage',
        assetName,
        configuration.devicePixelRatio,
      ]);
    }
    final AssetImage assetImage =
        AssetImage(assetName, package: package, bundle: bundle);
    final AssetBundleImageKey assetBundleImageKey =
        await assetImage.obtainKey(configuration);
    return BitmapDescriptor._(<dynamic>[
      'fromAssetImage',
      assetBundleImageKey.name,
      assetBundleImageKey.scale,
    ]);
  }

  /// Creates a BitmapDescriptor using an array of bytes that must be encoded
  /// as PNG.
  static BitmapDescriptor fromBytes(Uint8List byteData) {
    return BitmapDescriptor._(<dynamic>['fromBytes', byteData]);
  }

  final dynamic _json;

  dynamic _toJson() => _json;
}
