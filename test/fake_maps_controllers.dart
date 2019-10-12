// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

class FakePlatformAppleMap {
  FakePlatformAppleMap(int id, Map<dynamic, dynamic> params) {
    cameraPosition = CameraPosition.fromMap(params['initialCameraPosition']);
    channel = MethodChannel(
        'plugins.flutter.io/apple_maps_$id', const StandardMethodCodec());
    channel.setMockMethodCallHandler(onMethodCall);
    updateOptions(params['options']);
    updateAnnotations(params);
  }

  MethodChannel channel;

  CameraPosition cameraPosition;

  bool compassEnabled;

  MapType mapType;

  MinMaxZoomPreference minMaxZoomPreference;

  bool rotateGesturesEnabled;

  bool scrollGesturesEnabled;

  bool pitchGesturesEnabled;

  bool zoomGesturesEnabled;

  bool trackCameraPosition;

  bool myLocationEnabled;

  bool myLocationButtonEnabled;

  Set<AnnotationId> annotationIdsToRemove;

  Set<Annotation> annotationsToAdd;

  Set<Annotation> annotationsToChange;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'map#update':
        updateOptions(call.arguments['options']);
        return Future<void>.sync(() {});
      case 'annotations#update':
        updateAnnotations(call.arguments);
        return Future<void>.sync(() {});
    }
  }

  void updateAnnotations(Map<dynamic, dynamic> annotationUpdates) {
    if (annotationUpdates == null) {
      return;
    }
    annotationsToAdd =
        _deserializeAnnotations(annotationUpdates['annotationsToAdd']);
    annotationIdsToRemove =
        _deserializeAnnotationIds(annotationUpdates['annotationIdsToRemove']);
    annotationsToChange =
        _deserializeAnnotations(annotationUpdates['annotationsToChange']);
  }

  Set<AnnotationId> _deserializeAnnotationIds(List<dynamic> annotationIds) {
    if (annotationIds == null) {
      return Set<AnnotationId>();
    }
    return annotationIds
        .map((dynamic annotationId) => AnnotationId(annotationId))
        .toSet();
  }

  Set<Annotation> _deserializeAnnotations(dynamic annotations) {
    if (annotations == null) {
      return Set<Annotation>();
    }
    final List<dynamic> annotationsData = annotations;
    final Set<Annotation> result = Set<Annotation>();
    for (Map<dynamic, dynamic> annotationData in annotationsData) {
      final String annotationId = annotationData['annotationId'];
      final bool draggable = annotationData['draggable'];
      final bool visible = annotationData['visible'];

      final dynamic infoWindowData = annotationData['infoWindow'];
      InfoWindow infoWindow = InfoWindow.noText;
      if (infoWindowData != null) {
        final Map<dynamic, dynamic> infoWindowMap = infoWindowData;
        infoWindow = InfoWindow(
          title: infoWindowMap['title'],
          snippet: infoWindowMap['snippet'],
        );
      }

      result.add(Annotation(
        annotationId: AnnotationId(annotationId),
        draggable: draggable,
        infoWindow: infoWindow,
      ));
    }

    return result;
  }

  void updateOptions(Map<dynamic, dynamic> options) {
    if (options.containsKey('compassEnabled')) {
      compassEnabled = options['compassEnabled'];
    }
    if (options.containsKey('mapType')) {
      mapType = MapType.values[options['mapType']];
    }
    if (options.containsKey('minMaxZoomPreference')) {
      final List<dynamic> minMaxZoomList = options['minMaxZoomPreference'];
      minMaxZoomPreference =
          MinMaxZoomPreference(minMaxZoomList[0], minMaxZoomList[1]);
    }
    if (options.containsKey('rotateGesturesEnabled')) {
      rotateGesturesEnabled = options['rotateGesturesEnabled'];
    }
    if (options.containsKey('scrollGesturesEnabled')) {
      scrollGesturesEnabled = options['scrollGesturesEnabled'];
    }
    if (options.containsKey('pitchGesturesEnabled')) {
      pitchGesturesEnabled = options['pitchGesturesEnabled'];
    }
    if (options.containsKey('trackCameraPosition')) {
      trackCameraPosition = options['trackCameraPosition'];
    }
    if (options.containsKey('zoomGesturesEnabled')) {
      zoomGesturesEnabled = options['zoomGesturesEnabled'];
    }
    if (options.containsKey('myLocationEnabled')) {
      myLocationEnabled = options['myLocationEnabled'];
    }
    if (options.containsKey('myLocationButtonEnabled')) {
      myLocationButtonEnabled = options['myLocationButtonEnabled'];
    }
  }
}

class FakePlatformViewsController {
  FakePlatformAppleMap lastCreatedView;

  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        final Map<dynamic, dynamic> args = call.arguments;
        final Map<dynamic, dynamic> params = _decodeParams(args['params']);
        lastCreatedView = FakePlatformAppleMap(
          args['id'],
          params,
        );
        return Future<int>.sync(() => 1);
      default:
        return Future<void>.sync(() {});
    }
  }

  void reset() {
    lastCreatedView = null;
  }
}

Map<dynamic, dynamic> _decodeParams(Uint8List paramsMessage) {
  final ByteBuffer buffer = paramsMessage.buffer;
  final ByteData messageBytes = buffer.asByteData(
    paramsMessage.offsetInBytes,
    paramsMessage.lengthInBytes,
  );
  return const StandardMessageCodec().decodeMessage(messageBytes);
}
