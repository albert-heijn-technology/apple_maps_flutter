// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apple_maps_flutter_example/padding.dart';
import 'package:apple_maps_flutter_example/place_annotation.dart';
import 'package:apple_maps_flutter_example/place_polyline.dart';
import 'package:apple_maps_flutter_example/place_polygon.dart';
import 'package:apple_maps_flutter_example/scrolling_map.dart';
import 'package:flutter/material.dart';
import 'animate_camera.dart';
import 'map_click.dart';
import 'map_coordinates.dart';
import 'map_ui.dart';
import 'annotation_icons.dart';
import 'move_camera.dart';
import 'page.dart';

final List<Page> _allPages = <Page>[
  MapUiPage(),
  MapCoordinatesPage(),
  MapClickPage(),
  AnimateCameraPage(),
  MoveCameraPage(),
  PaddingPage(),
  PlaceAnnotationPage(),
  AnnotationIconsPage(),
  PlacePolylinePage(),
  PlacePolygonPage(),
  ScrollingMapPage(),
];

class MapsDemo extends StatelessWidget {
  void _pushPage(BuildContext context, Page page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppleMaps examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MapsDemo()));
}
