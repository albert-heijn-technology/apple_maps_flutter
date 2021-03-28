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

class MapClickPage extends ExamplePage {
  MapClickPage() : super(const Icon(Icons.mouse), 'Map click');

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: const _MapClickBody());
  }
}

class _MapClickBody extends StatefulWidget {
  const _MapClickBody();

  @override
  State<StatefulWidget> createState() => _MapClickBodyState();
}

class _MapClickBodyState extends State<_MapClickBody> {
  _MapClickBodyState();

  AppleMapController? mapController;
  LatLng? _lastTap;
  LatLng? _lastLongPress;

  @override
  Widget build(BuildContext context) {
    final AppleMap appleMap = AppleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      onTap: (LatLng pos) {
        setState(() {
          _lastTap = pos;
        });
      },
      onLongPress: (LatLng pos) {
        setState(() {
          _lastLongPress = pos;
        });
      },
    );

    final List<Widget> columnChildren = <Widget>[Expanded(child: appleMap)];

    if (mapController != null) {
      final String lastTap = 'Tap:\n${_lastTap ?? ""}\n';
      final String lastLongPress = 'Long press:\n${_lastLongPress ?? ""}';
      columnChildren.add(Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(lastTap, textAlign: TextAlign.center),
            Text(lastLongPress, textAlign: TextAlign.center)
          ],
        ),
      ));
    }

    return Column(children: columnChildren);
  }

  void onMapCreated(AppleMapController controller) async {
    setState(() {
      mapController = controller;
    });
  }
}
