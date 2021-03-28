// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'page.dart';

class ScrollingMapPage extends ExamplePage {
  ScrollingMapPage() : super(const Icon(Icons.map), 'Scrolling map');

  @override
  Widget build(BuildContext context) {
    return const ScrollingMapBody();
  }
}

class ScrollingMapBody extends StatelessWidget {
  const ScrollingMapBody();

  final LatLng center = const LatLng(32.080664, 34.9563837);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Text('This map consumes all touch events.'),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: AppleMap(
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 11.0,
                      ),
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  const Text('This map doesn\'t consume the vertical drags.'),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Text(
                        'It still gets other gestures (e.g scale or tap).'),
                  ),
                  Center(
                    child: SizedBox(
                      height: 300.0,
                      child: AppleMap(
                        initialCameraPosition: CameraPosition(
                          target: center,
                          zoom: 11.0,
                        ),
                        annotations: Set<Annotation>.of(
                          <Annotation>[
                            Annotation(
                              annotationId: AnnotationId("test_Annotation_id"),
                              position: LatLng(
                                center.latitude,
                                center.longitude,
                              ),
                              infoWindow: const InfoWindow(
                                title: 'An interesting location',
                                snippet: '*',
                              ),
                            )
                          ],
                        ),
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>[
                          Factory<OneSequenceGestureRecognizer>(
                            () => ScaleGestureRecognizer(),
                          ),
                        ].toSet(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
