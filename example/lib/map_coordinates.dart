// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'page.dart';

const CameraPosition _kInitialPosition = CameraPosition(
  target: LatLng(-33.852, 151.211),
  zoom: 11,
);

class MapCoordinatesPage extends ExamplePage {
  MapCoordinatesPage() : super(const Icon(Icons.map), 'Map coordinates');

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: const _MapCoordinatesBody());
  }
}

class _MapCoordinatesBody extends StatefulWidget {
  const _MapCoordinatesBody();

  @override
  State<StatefulWidget> createState() => _MapCoordinatesBodyState();
}

class _MapCoordinatesBodyState extends State<_MapCoordinatesBody> {
  _MapCoordinatesBodyState();

  AppleMapController? mapController;
  LatLngBounds _visibleRegion = LatLngBounds(
    southwest: const LatLng(0, 0),
    northeast: const LatLng(0, 0),
  );

  @override
  Widget build(BuildContext context) {
    final AppleMap appleMap = AppleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
    );

    final List<Widget> columnChildren = <Widget>[Expanded(child: appleMap)];

    if (mapController != null) {
      final String currentVisibleRegion = 'VisibleRegion:'
          '\nnortheast: ${_visibleRegion.northeast},'
          '\nsouthwest: ${_visibleRegion.southwest}';
      columnChildren.add(Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Center(child: Text(currentVisibleRegion)),
            _getVisibleRegionButton(),
          ],
        ),
      ));
    }

    return Column(children: columnChildren);
  }

  void onMapCreated(AppleMapController controller) async {
    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    setState(() {
      mapController = controller;
      _visibleRegion = visibleRegion;
    });
  }

  Widget _getVisibleRegionButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text('Get Visible Region Bounds'),
        onPressed: () async {
          final LatLngBounds visibleRegion =
              (await mapController?.getVisibleRegion())!;
          setState(() {
            _visibleRegion = visibleRegion;
          });
        },
      ),
    );
  }
}
