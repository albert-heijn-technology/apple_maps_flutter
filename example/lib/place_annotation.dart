// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

import 'page.dart';

class PlaceAnnotationPage extends Page {
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

  AppleMapController controller;
  Map<AnnotationId, Annotation> annotations = <AnnotationId, Annotation>{};
  AnnotationId selectedAnnotation;
  int _annotationIdCounter = 1;

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
          final Annotation resetOld = annotations[selectedAnnotation]
              .copyWith(iconParam: BitmapDescriptor.defaultAnnotation);
          annotations[selectedAnnotation] = resetOld;
        }
        selectedAnnotation = annotationId;
        final Annotation newAnnotation = tappedAnnotation.copyWith(
          iconParam: BitmapDescriptor.defaultAnnotationWithColor(
            AnnatationColor.GREEN,
          ),
        );
        annotations[annotationId] = newAnnotation;
      });
    }
  }

  void _add() {
    final int annotationCount = annotations.length;

    if (annotationCount == 12) {
      return;
    }

    final String annotationIdVal = 'annotation_id_$_annotationIdCounter';
    _annotationIdCounter++;
    final AnnotationId annotationId = AnnotationId(annotationIdVal);

    final Annotation annotation = Annotation(
      annotationId: annotationId,
      position: LatLng(
        center.latitude + sin(_annotationIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_annotationIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: annotationIdVal, snippet: '*'),
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
      if (annotations.containsKey(selectedAnnotation)) {
        annotations.remove(selectedAnnotation);
      }
    });
  }

  void _changePosition() {
    final Annotation annotation = annotations[selectedAnnotation];
    final LatLng current = annotation.position;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    setState(() {
      annotations[selectedAnnotation] = annotation.copyWith(
        positionParam: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      );
    });
  }

  Future<void> _changeInfoAnchor() async {
    final Annotation annotation = annotations[selectedAnnotation];
    final Offset currentAnchor = annotation.infoWindow.anchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    setState(() {
      annotations[selectedAnnotation] = annotation.copyWith(
        infoWindowParam: annotation.infoWindow.copyWith(
          anchorParam: newAnchor,
        ),
      );
    });
  }

  Future<void> _toggleDraggable() async {
    final Annotation annotation = annotations[selectedAnnotation];
    setState(() {
      annotations[selectedAnnotation] = annotation.copyWith(
        draggableParam: !annotation.draggable,
      );
    });
  }

  Future<void> _changeInfo() async {
    final Annotation annotation = annotations[selectedAnnotation];
    final String newSnippet = annotation.infoWindow.snippet + '*';
    setState(() {
      annotations[selectedAnnotation] = annotation.copyWith(
        infoWindowParam: annotation.infoWindow.copyWith(
          snippetParam: newSnippet,
        ),
      );
    });
  }

  Future<void> _changeAlpha() async {
    final Annotation annotation = annotations[selectedAnnotation];
    final double current = annotation.alpha;
    setState(() {
      annotations[selectedAnnotation] = annotation.copyWith(
        alphaParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: AppleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11,
              ),
              annotations: Set<Annotation>.of(annotations.values),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('add'),
                          onPressed: _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: _remove,
                        ),
                        FlatButton(
                          child: const Text('change info'),
                          onPressed: _changeInfo,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change alpha'),
                          onPressed: _changeAlpha,
                        ),
                        FlatButton(
                          child: const Text('toggle draggable'),
                          onPressed: _toggleDraggable,
                        ),
                        FlatButton(
                          child: const Text('change position'),
                          onPressed: _changePosition,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
