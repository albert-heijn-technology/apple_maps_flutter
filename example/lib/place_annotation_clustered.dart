// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/services.dart';

import 'page.dart';
import 'dart:ui' as ui;

class PlaceAnnotationClusteredPage extends ExamplePage {
  PlaceAnnotationClusteredPage()
      : super(const Icon(Icons.place), 'Place annotation clustered');

  @override
  Widget build(BuildContext context) {
    return const PlaceAnnotationClusteredBody();
  }
}

class PlaceAnnotationClusteredBody extends StatefulWidget {
  const PlaceAnnotationClusteredBody();

  @override
  State<StatefulWidget> createState() => PlaceAnnotationClusteredBodyState();
}

typedef Annotation AnnotationUpdateAction(Annotation annotation);

class PlaceAnnotationClusteredBodyState
    extends State<PlaceAnnotationClusteredBody> {
  PlaceAnnotationClusteredBodyState();
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  AppleMapController controller;
  Map<AnnotationId, Annotation> annotations = <AnnotationId, Annotation>{};
  AnnotationId selectedAnnotation;
  int _annotationIdCounter = 1;
  BitmapDescriptor _annotationIcon;
  BitmapDescriptor _iconFromBytes;
  double _devicePixelRatio = 3.0;

  void _onMapCreated(AppleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onAnnotationTapped(AnnotationId annotationId) {
    final Annotation tappedAnnotation = annotations[annotationId];
    if (tappedAnnotation != null) {
      setState(() {
        if (annotations.containsKey(selectedAnnotation)) {
          final Annotation resetOld =
              annotations[selectedAnnotation].copyWith();
          annotations[selectedAnnotation] = resetOld;
        }
        selectedAnnotation = annotationId;
      });
    }
  }

  void _add(String iconType) {
    final int annotationCount = annotations.length;

    if (annotationCount == 12) {
      return;
    }

    final String annotationIdVal = 'annotation_id_$_annotationIdCounter';
    _annotationIdCounter++;
    final AnnotationId annotationId = AnnotationId(annotationIdVal);

    final Annotation annotation = Annotation(
      annotationId: annotationId,
      icon: iconType == 'marker'
          ? BitmapDescriptor.markerAnnotation
          : iconType == 'pin'
              ? BitmapDescriptor.defaultAnnotation
              : iconType == 'customAnnotationFromBytes'
                  ? _iconFromBytes
                  : _annotationIcon,
      position: LatLng(
        center.latitude + sin(_annotationIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_annotationIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(
          title: annotationIdVal,
          anchor: Offset(0.5, 0.0),
          snippet: '*',
          onTap: () => print('InfowWindow of id: $annotationId tapped.')),
      onTap: () {
        _onAnnotationTapped(annotationId);
      },
    );

    setState(() {
      annotations[annotationId] = annotation;
    });
  }

  Future<void> _createAnnotationImageFromAsset(
      BuildContext context, double devicelPixelRatio) async {
    if (_annotationIcon == null) {
      final ImageConfiguration imageConfiguration =
          ImageConfiguration(devicePixelRatio: devicelPixelRatio);
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

  Future<void> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    _iconFromBytes = BitmapDescriptor.fromBytes(
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))
            .buffer
            .asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    _createAnnotationImageFromAsset(context, _devicePixelRatio);
    _getBytesFromAsset('assets/red_square.png', 40);
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              child: AppleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-33.852, 151.211),
                  zoom: 11,
                ),
                annotations: Set<Annotation>.of(annotations.values),
                enableClustering: true,
              ),
            ),
          ),
          FlatButton(
            child: const Text('customAnnotation from bytes'),
            onPressed: () => _add('customAnnotationFromBytes'),
          ),
        ]);
  }
}
