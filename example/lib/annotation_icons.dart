// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

class AnnotationIconsPage extends ExamplePage {
  AnnotationIconsPage() : super(const Icon(Icons.image), 'Annotation icons');

  @override
  Widget build(BuildContext context) {
    return const AnnotationIconsBody();
  }
}

class AnnotationIconsBody extends StatefulWidget {
  const AnnotationIconsBody();

  @override
  State<StatefulWidget> createState() => AnnotationIconsBodyState();
}

const LatLng _kMapCenter = LatLng(52.707755, -2.7540658);

class AnnotationIconsBodyState extends State<AnnotationIconsBody> {
  late AppleMapController controller;
  BitmapDescriptor? _annotationIcon;

  @override
  Widget build(BuildContext context) {
    _createAnnotationImageFromAsset(context);
    return SafeArea(
      child: AppleMap(
        initialCameraPosition: const CameraPosition(
          target: _kMapCenter,
          zoom: 8,
        ),
        annotations: _createAnnotation(),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  Set<Annotation> _createAnnotation() {
    return <Annotation>[
      Annotation(
        annotationId: AnnotationId("annotation_1"),
        anchor: Offset(0.5, -4),
        position: LatLng(52.707755, -2.7540658),
        icon: _annotationIcon ?? BitmapDescriptor.defaultAnnotation,
      ),
    ].toSet();
  }

  Future<void> _createAnnotationImageFromAsset(BuildContext context) async {
    if (_annotationIcon == null) {
      final ImageConfiguration imageConfiguration =
          new ImageConfiguration(devicePixelRatio: 1.0);
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/test_marker.png')
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _annotationIcon = bitmap;
    });
  }

  void _onMapCreated(AppleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
  }
}
