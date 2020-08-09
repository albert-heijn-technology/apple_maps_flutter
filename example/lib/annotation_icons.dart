// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

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

const LatLng _kMapCenter = LatLng(52.4478, -3.5402);

class AnnotationIconsBodyState extends State<AnnotationIconsBody> {
  AppleMapController controller;
  BitmapDescriptor _annotationIcon;

  @override
  Widget build(BuildContext context) {
    _createAnnotationImageFromAsset(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 350.0,
            height: 300.0,
            child: AppleMap(
              initialCameraPosition: const CameraPosition(
                target: _kMapCenter,
                zoom: 7,
              ),
              annotations: _createAnnotation(),
              onMapCreated: _onMapCreated,
            ),
          ),
        )
      ],
    );
  }

  Set<Annotation> _createAnnotation() {
    return <Annotation>[
      Annotation(
        annotationId: AnnotationId("annotation_1"),
        position: _kMapCenter,
        icon: _annotationIcon,
      ),
    ].toSet();
  }

  Future<void> _createAnnotationImageFromAsset(BuildContext context) async {
    if (_annotationIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/red_square.png')
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
