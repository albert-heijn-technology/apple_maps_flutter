// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'page.dart';

class PlaceAnnotationPage extends ExamplePage {
  PlaceAnnotationPage() : super(const Icon(Icons.place), 'Place annotation');

  @override
  Widget build(BuildContext context) {
    return const PlaceAnnotationBody();
  }
}

class PlaceAnnotationBody extends StatefulWidget {
  const PlaceAnnotationBody();

  @override
  State<StatefulWidget> createState() => PlaceAnnotationBodyState();
}

typedef Annotation AnnotationUpdateAction(Annotation annotation);

class PlaceAnnotationBodyState extends State<PlaceAnnotationBody> {
  PlaceAnnotationBodyState();
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  late AppleMapController controller;
  Uint8List? _imageBytes;
  Map<AnnotationId, Annotation> annotations = <AnnotationId, Annotation>{};
  late AnnotationId selectedAnnotationId;
  int _annotationIdCounter = 1;
  BitmapDescriptor? _annotationIcon;
  late BitmapDescriptor _iconFromBytes;
  double _devicePixelRatio = 3.0;

  void _onMapCreated(AppleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onAnnotationTapped(AnnotationId annotationId) {
    final Annotation? tappedAnnotation = annotations[annotationId];
    if (tappedAnnotation != null) {
      setState(() {
        if (annotations.containsKey(tappedAnnotation)) {
          final Annotation resetOld =
              annotations[selectedAnnotationId]!.copyWith();
          annotations[selectedAnnotationId] = resetOld;
        }
        selectedAnnotationId = annotationId;
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
                  : _annotationIcon!,
      position: LatLng(
        center.latitude + sin(_annotationIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_annotationIdCounter * pi / 6.0) / 20.0,
      ),
      zIndex: annotationCount.toDouble(),
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

  void _remove() {
    setState(() {
      if (annotations.containsKey(selectedAnnotationId)) {
        annotations.remove(selectedAnnotationId);
      }
    });
  }

  void _changePosition() {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    final LatLng current = annotation.position;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    setState(() {
      annotations[selectedAnnotationId] = annotation.copyWith(
        positionParam: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      );
    });
  }

  Future<void> _toggleDraggable() async {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    setState(() {
      annotations[selectedAnnotationId] = annotation.copyWith(
        draggableParam: !annotation.draggable,
      );
    });
  }

  Future<void> _changeInfo() async {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    final String newSnippet = annotation.infoWindow.snippet! +
        (annotation.infoWindow.snippet!.length % 10 == 0 ? '\n' : '*');
    setState(() {
      annotations[selectedAnnotationId] = annotation.copyWith(
        infoWindowParam: annotation.infoWindow.copyWith(
          snippetParam: newSnippet,
        ),
      );
    });
  }

  Future<void> _changeAlpha() async {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    final double current = annotation.alpha;
    setState(() {
      annotations[selectedAnnotationId] = annotation.copyWith(
        alphaParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  Future<void> _toggleVisible() async {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    setState(() {
      annotations[selectedAnnotationId] = annotation.copyWith(
        visibleParam: !annotation.visible,
      );
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

  Future<void> _showInfoWindow() async {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    await this.controller.showMarkerInfoWindow(annotation.annotationId);
  }

  Future<void> _hideInfoWindow() async {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    this.controller.hideMarkerInfoWindow(annotation.annotationId);
  }

  Future<bool> _isInfoWindowShown() async {
    final Annotation annotation = annotations[selectedAnnotationId]!;
    print(
        'Is InfowWindow visible: ${await this.controller.isMarkerInfoWindowShown(annotation.annotationId)}');
    return (await this
        .controller
        .isMarkerInfoWindowShown(annotation.annotationId))!;
  }

  Future<void> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    _iconFromBytes = BitmapDescriptor.fromBytes(
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List());
  }

  Future<void> _changeZIndex(AnnotationId annotationId) async {
    final Annotation annotation = annotations[annotationId]!;
    final double current = annotation.zIndex;
    setState(() {
      annotations[annotationId] = annotation.copyWith(
        zIndexParam: current >= 12.0 ? 0.0 : current + 1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _createAnnotationImageFromAsset(context, _devicePixelRatio);
    _getBytesFromAsset('assets/creator.png', 160);
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: AppleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11,
              ),
              annotations: Set<Annotation>.of(annotations.values),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text('add defaultAnnotation'),
                  onPressed: () => _add('pin'),
                ),
                TextButton(
                  child: const Text('add markerAnnotation'),
                  onPressed: () => _add('marker'),
                ),
                TextButton(
                  child: const Text('add customAnnotation'),
                  onPressed: () => _add('customAnnotation'),
                ),
                TextButton(
                  child: const Text('customAnnotation from bytes'),
                  onPressed: () => _add('customAnnotationFromBytes'),
                ),
                TextButton(
                  child: const Text('remove'),
                  onPressed: _remove,
                ),
                TextButton(
                  child: const Text('change info'),
                  onPressed: _changeInfo,
                ),
                TextButton(
                  child: const Text('infoWindow is shown?s'),
                  onPressed: _isInfoWindowShown,
                ),
                TextButton(
                  child: const Text('change alpha'),
                  onPressed: _changeAlpha,
                ),
                TextButton(
                  child: const Text('toggle draggable'),
                  onPressed: _toggleDraggable,
                ),
                TextButton(
                  child: const Text('change position'),
                  onPressed: _changePosition,
                ),
                TextButton(
                  child: const Text('toggle visible'),
                  onPressed: _toggleVisible,
                ),
                TextButton(
                  child: const Text('show infoWindow'),
                  onPressed: _showInfoWindow,
                ),
                TextButton(
                  child: const Text('hide infoWindow'),
                  onPressed: _hideInfoWindow,
                ),
                TextButton(
                  child: const Text('change zIndex'),
                  onPressed: () => _changeZIndex(selectedAnnotationId),
                ),
                TextButton(
                  child: Text('Take a snapshot'),
                  onPressed: () async {
                    final imageBytes = await this.controller.takeSnapshot();
                    setState(() {
                      _imageBytes = imageBytes;
                    });
                  },
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.blueGrey[50]),
                  height: 180,
                  child:
                      _imageBytes != null ? Image.memory(_imageBytes!) : null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
